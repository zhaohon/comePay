import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:comecomepay/main.dart';
import 'package:comecomepay/utils/constants.dart';
import 'package:comecomepay/services/api_logger_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:hive/hive.dart';

// Custom exception classes for different HTTP status codes
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => 'Unauthorized: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => 'Forbidden: $message';
}

class ServerErrorException implements Exception {
  final String message;
  ServerErrorException(this.message);
  @override
  String toString() => 'Server Error: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'Network Error: $message';
}

abstract class BaseService {
  final ApiLoggerService _apiLogger = ApiLoggerService();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    // ⚠️ CRITICAL: Must return false for 401 to trigger onError interceptor for token refresh
    // Return true for other status codes to handle them in handleResponse
    validateStatus: (status) {
      if (status == 401) {
        // Return false to trigger DioException and onError interceptor
        // This allows automatic token refresh to work
        return false;
      }
      // Accept all other status codes (including errors) for custom handling
      return true;
    },
  ));

  // Token refresh lock mechanism using Completer for true mutex behavior
  // Prevents race conditions when multiple 401 errors arrive simultaneously
  Completer<Map<String, dynamic>>? _refreshCompleter;
  final List<Function> _pendingRequests = [];

  BaseService() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add timestamp for duration calculation
        options.extra['request_start_time'] =
            DateTime.now().millisecondsSinceEpoch;

        // 自动添加Authorization token
        final token = HiveStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // 添加语言请求头 Accept-Language
        try {
          final settingsBox = Hive.box('settings');
          final String lang = settingsBox.get('language', defaultValue: 'en');
          options.headers['Accept-Language'] = lang;
        } catch (e) {
          // Fallback to en if box access fails
          options.headers['Accept-Language'] = 'en';
        }

        // 添加 DevTools Network 监控支持
        developer.Timeline.startSync(
          'HTTP ${options.method}',
          arguments: {
            'method': options.method,
            'url': options.uri.toString(),
          },
        );

        _apiLogger.logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime =
            response.requestOptions.extra['request_start_time'] as int?;
        final duration = startTime != null
            ? DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(startTime))
            : Duration.zero;
        _apiLogger.logResponse(response, duration);

        // 结束 DevTools Timeline 追踪
        developer.Timeline.finishSync();

        // 发送网络事件到 DevTools
        developer.postEvent('HTTP Response', {
          'method': response.requestOptions.method,
          'url': response.requestOptions.uri.toString(),
          'statusCode': response.statusCode.toString(),
          'duration': '${duration.inMilliseconds}ms',
        });

        handler.next(response);
      },
      onError: (error, handler) async {
        _apiLogger.logError(error, error.stackTrace);

        // 结束 DevTools Timeline 追踪
        developer.Timeline.finishSync();

        // 发送错误事件到 DevTools
        developer.postEvent('HTTP Error', {
          'method': error.requestOptions.method,
          'url': error.requestOptions.uri.toString(),
          'error': error.message ?? 'Unknown error',
        });

        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          developer.log('🔴 ========== 检测到401错误 ==========',
              name: 'TokenRefresh');
          developer.log('🔴 请求URL: ${error.requestOptions.uri.toString()}',
              name: 'TokenRefresh');
          developer.log('🔴 请求方法: ${error.requestOptions.method}',
              name: 'TokenRefresh');

          // Prevent refresh endpoint from triggering another refresh
          if (error.requestOptions.path.contains('/auth/refresh')) {
            developer.log('❌ 这是refresh接口本身返回401', name: 'TokenRefresh');
            developer.log('❌ Refresh Token已过期，需要重新登录', name: 'TokenRefresh');
            developer.log('🔄 准备清除认证数据并跳转登录页...', name: 'TokenRefresh');
            _apiLogger.logError(error, StackTrace.current);

            // ⚠️ CRITICAL: Clear auth data when refresh token is expired
            developer.log('📞 调用 _handleRefreshFailure()...',
                name: 'TokenRefresh');
            await _handleRefreshFailure();
            developer.log('✅ _handleRefreshFailure() 调用完成',
                name: 'TokenRefresh');

            // Reject with error to stop subsequent API calls
            developer.log('🔴 返回错误，停止后续API调用', name: 'TokenRefresh');
            return handler.reject(error);
          }

          final refreshToken = HiveStorageService.getRefreshToken();
          developer.log(
              '📋 Refresh Token是否存在: ${refreshToken != null && refreshToken.isNotEmpty}',
              name: 'TokenRefresh');

          if (refreshToken != null && refreshToken.isNotEmpty) {
            developer.log('✅ 有有效的Refresh Token，准备刷新', name: 'TokenRefresh');

            // 🔒 Check if refresh is already in progress using Completer
            if (_refreshCompleter != null) {
              developer.log('⏳ 已经在刷新中，等待刷新完成...', name: 'TokenRefresh');
              try {
                // Wait for the ongoing refresh to complete
                final newTokens = await _refreshCompleter!.future;
                developer.log('✅ 等待刷新完成，使用新Token重试', name: 'TokenRefresh');

                // Retry the original request with new token
                final options = error.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${newTokens['access_token']}';
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                developer.log('❌ 等待刷新失败: $e', name: 'TokenRefresh');
                return handler.reject(error);
              }
            }

            // 🔒 Create new Completer to lock the refresh process
            _refreshCompleter = Completer<Map<String, dynamic>>();
            developer.log('🔒 已创建刷新锁，开始刷新Access Token...',
                name: 'TokenRefresh');

            try {
              // Attempt to refresh the token
              developer.log('📞 调用 /auth/refresh 接口...', name: 'TokenRefresh');
              final newTokens = await _refreshAccessToken(refreshToken);

              developer.log('✅ Token刷新成功！', name: 'TokenRefresh');

              // Update stored tokens
              await HiveStorageService.updateTokens(
                newTokens['access_token'],
                newTokens['refresh_token'],
              );

              developer.log('✅ 新Token已保存到本地存储', name: 'TokenRefresh');

              // Complete the Completer to notify waiting requests
              _refreshCompleter!.complete(newTokens);

              // Retry the original request with new token
              final options = error.requestOptions;
              options.headers['Authorization'] =
                  'Bearer ${newTokens['access_token']}';

              developer.log('🔄 使用新Token重试原始请求: ${options.uri}',
                  name: 'TokenRefresh');

              final response = await _dio.fetch(options);
              developer.log('✅ 原始请求重试成功！', name: 'TokenRefresh');
              developer.log('🟢 ========== 401处理完成 ==========',
                  name: 'TokenRefresh');
              return handler.resolve(response);
            } catch (refreshError) {
              developer.log('❌ Token刷新失败: $refreshError', name: 'TokenRefresh');
              _apiLogger.logError(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: refreshError,
                  ),
                  StackTrace.current);

              // Complete with error to notify waiting requests
              if (!_refreshCompleter!.isCompleted) {
                _refreshCompleter!.completeError(refreshError);
              }

              // ⚠️ DO NOT clear auth data - preserve tokens!
              developer.log('🔴 ========== Token刷新失败，保留原Token ==========',
                  name: 'TokenRefresh');
              return handler.reject(error);
            } finally {
              // Clear the Completer
              _refreshCompleter = null;
            }
          } else {
            // No refresh token available
            developer.log('❌ 没有Refresh Token', name: 'TokenRefresh');
            developer.log('❌ 需要重新登录', name: 'TokenRefresh');
            _apiLogger.logError(error, StackTrace.current);
            await _handleRefreshFailure();
            return handler.reject(error);
          }
        }

        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // Common error handling method
  dynamic handleResponse(Response response) {
    // Handle cases where response.data might be a String instead of Map
    dynamic data = response.data;
    if (data is String) {
      // Try to parse as JSON if it's a string
      try {
        // For 404 responses that are plain text, create a proper error structure
        if (response.statusCode == 404) {
          data = {'message': data, 'status': 'error'};
        } else {
          // For other cases, try to parse JSON
          data = jsonDecode(data);
        }
      } catch (e) {
        // If parsing fails, wrap in a map
        data = {'message': data.toString(), 'status': 'error'};
      }
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 202: // Accept
        // Check for business-level errors if it's a map
        if (data is Map) {
          final status = data['status'];
          if (status == 'error' || status == 'fail' || status == 'failed') {
            final message = data['message'] ??
                data['msg'] ??
                data['error'] ??
                'Unknown business error';

            // Special handling for 403-like business errors (e.g. OTP required)
            // But if it's already a 200, we check if it's meant to be an error
            throw Exception(message);
          }
        }
        return data;
      case 400:
        throw Exception('${data['message'] ?? 'Invalid request'}');
      case 401:
        // ⚠️ DO NOT throw here! Let the interceptor's onError handle 401
        // The interceptor will handle token refresh automatically
        // If we throw here, the error won't reach the interceptor
        developer.log(
            '⚠️ handleResponse got 401 - should not reach here if interceptor works',
            name: 'TokenRefresh');
        throw UnauthorizedException(data['message'] ?? 'Invalid credentials');
      case 403:
        throw ForbiddenException(
            data['message'] ?? 'Access denied - OTP required');
      case 404:
        throw Exception('${data['message'] ?? 'Resource not found'}');
      case 422:
        throw Exception('${data['message'] ?? 'Invalid data'}');
      case 429:
        throw Exception('${data['message'] ?? 'Rate limit exceeded'}');
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerErrorException(data['message'] ?? 'Server error occurred');
      default:
        throw Exception(
            'HTTP ${response.statusCode}: ${data['message'] ?? 'Unknown error'}');
    }
  }

  // Common error handling for Dio exceptions
  dynamic handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
            'Connection timeout: Please check your internet connection');
      case DioExceptionType.badResponse:
        return handleResponse(e.response!);
      case DioExceptionType.cancel:
        throw Exception('Request cancelled');
      default:
        throw NetworkException('Network error: ${e.message}');
    }
  }

  // Common method for making GET requests
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making POST requests
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making PUT requests
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making DELETE requests
  Future<dynamic> delete(
    String endpoint, {
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ========== Token Refresh Helper Methods ==========

  /// Refresh the access token using refresh token
  Future<dynamic> _refreshAccessToken(String refreshToken) async {
    try {
      _apiLogger.logMethodEntry('_refreshAccessToken', parameters: {
        'refresh_token': '***HIDDEN***',
      });

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == 'success' || data['access_token'] != null) {
          _apiLogger.logSuccess(
              '_refreshAccessToken', 'Token refresh successful');
          return data;
        }
      }

      throw Exception('Token refresh failed: ${response.data}');
    } catch (e) {
      _apiLogger.logFailure('_refreshAccessToken', 'Token refresh failed',
          error: e.toString());
      rethrow;
    }
  }

  /// Add request to pending queue while token is being refreshed
  Future<void> _addRequestToQueue(
      DioException error, ErrorInterceptorHandler handler) async {
    final completer = Completer<void>();

    _pendingRequests.add(() async {
      try {
        final options = error.requestOptions;
        final newToken = HiveStorageService.getAccessToken();
        options.headers['Authorization'] = 'Bearer $newToken';

        final response = await _dio.fetch(options);
        handler.resolve(response);
        completer.complete();
      } catch (e) {
        handler.reject(error);
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Resolve all pending requests after successful token refresh
  void _resolvePendingRequests() {
    for (var request in _pendingRequests) {
      request();
    }
    _pendingRequests.clear();
  }

  /// Reject all pending requests when refresh fails
  void _rejectPendingRequests(DioException error) {
    _pendingRequests.clear();
  }

  /// Handle refresh failure - clear auth data and notify app
  Future<void> _handleRefreshFailure() async {
    developer.log('⚠️⚠️⚠️ ========== _handleRefreshFailure 开始 ==========',
        name: 'TokenRefresh');
    try {
      developer.log('🗑️ 清除认证数据...', name: 'TokenRefresh');
      await HiveStorageService.clearAuthData();
      developer.log('✅ 认证数据已清除', name: 'TokenRefresh');

      // Fire session expired event
      developer.log('📢 触发 SessionExpired 事件...', name: 'TokenRefresh');
      _fireSessionExpiredEvent();
      developer.log('✅ SessionExpired 事件已触发', name: 'TokenRefresh');
    } catch (e) {
      developer.log('❌ Error clearing auth data: $e', name: 'TokenRefresh');
    }
    developer.log('⚠️⚠️⚠️ ========== _handleRefreshFailure 完成 ==========',
        name: 'TokenRefresh');
  }

  /// Fire session expired event to notify the app
  void _fireSessionExpiredEvent() {
    developer.log('🔔 ========== _fireSessionExpiredEvent 开始 ==========',
        name: 'TokenRefresh');

    // Post event to DevTools
    developer.postEvent('SessionExpired', {
      'message': '会话已过期，请重新登录',
      'timestamp': DateTime.now().toIso8601String(),
    });
    developer.log('✅ DevTools事件已发送', name: 'TokenRefresh');

    developer.log('🔍 获取Navigator context...', name: 'TokenRefresh');
    final context = MyApp.navigatorKey.currentContext;

    if (context != null) {
      developer.log('✅ Context获取成功', name: 'TokenRefresh');
      developer.log('🚀 准备跳转到 CreateAccountScreen...', name: 'TokenRefresh');

      try {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/create_account',
          (Route<dynamic> route) => false,
        );
        developer.log('✅ 导航命令已发送', name: 'TokenRefresh');
      } catch (e) {
        developer.log('❌ 导航失败: $e', name: 'TokenRefresh');
      }
    } else {
      developer.log('❌ Context为null，无法导航', name: 'TokenRefresh');
      developer.log('⚠️ MyApp.navigatorKey.currentContext = null',
          name: 'TokenRefresh');
    }

    developer.log('🔔 ========== _fireSessionExpiredEvent 完成 ==========',
        name: 'TokenRefresh');
  }
}
