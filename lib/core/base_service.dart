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
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => message;
}

class ServerErrorException implements Exception {
  final String message;
  ServerErrorException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
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

  // 🛡️ Flag to prevent multiple redundant redirections to login page
  static bool _isNavigatingToLogin = false;

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
          final String? savedLang = settingsBox.get('language');
          final String lang = savedLang ?? 'en';

          // Debugging log
          print(
              '🌐 [BaseService] Language from Hive: $savedLang, Using: $lang');

          options.headers['Accept-Language'] = lang;
        } catch (e) {
          print(
              '🌐 [BaseService] Error fetching language: $e. Falling back to en.');
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
          // Prevent refresh endpoint from triggering another refresh
          if (error.requestOptions.path.contains('/auth/refresh')) {
            _apiLogger.logError(error, StackTrace.current);

            // ⚠️ CRITICAL: Clear auth data when refresh token is expired
            await _handleRefreshFailure();

            // Reject with error to stop subsequent API calls
            return handler.reject(error);
          }

          final refreshToken = HiveStorageService.getRefreshToken();

          if (refreshToken != null && refreshToken.isNotEmpty) {
            // 🔒 Check if refresh is already in progress using Completer
            if (_refreshCompleter != null) {
              try {
                // Wait for the ongoing refresh to complete
                final newTokens = await _refreshCompleter!.future;

                // Retry the original request with new token
                final options = error.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${newTokens['access_token']}';
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            }

            // 🔒 Create new Completer to lock the refresh process
            _refreshCompleter = Completer<Map<String, dynamic>>();

            try {
              // Attempt to refresh the token
              final newTokens = await _refreshAccessToken(refreshToken);

              // Update stored tokens
              await HiveStorageService.updateTokens(
                newTokens['access_token'],
                newTokens['refresh_token'],
              );

              // Complete the Completer to notify waiting requests
              _refreshCompleter!.complete(newTokens);

              // Retry the original request with new token
              final options = error.requestOptions;
              options.headers['Authorization'] =
                  'Bearer ${newTokens['access_token']}';

              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (refreshError) {
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
              return handler.reject(error);
            } finally {
              // Clear the Completer
              _refreshCompleter = null;
            }
          } else {
            // No refresh token available
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
            throw AppException(message);
          }
        }
        return data;
      case 400:
        throw AppException('${data['message'] ?? 'Invalid request'}');
      case 401:
        // ⚠️ DO NOT throw here! Let the interceptor's onError handle 401
        throw UnauthorizedException(data['message'] ?? 'Invalid credentials');
      case 403:
        throw ForbiddenException(
            data['message'] ?? 'Access denied - OTP required');
      case 404:
        throw AppException('${data['message'] ?? 'Resource not found'}');
      case 422:
        throw AppException('${data['message'] ?? 'Invalid data'}');
      case 429:
        throw AppException('${data['message'] ?? 'Rate limit exceeded'}');
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerErrorException(data['message'] ?? 'Server error occurred');
      default:
        throw AppException(
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
    try {
      await HiveStorageService.clearAuthData();

      // Fire session expired event
      _fireSessionExpiredEvent();
    } catch (e) {
      // Error clearing auth data
    }
  }

  /// Fire session expired event to notify the app
  void _fireSessionExpiredEvent() {
    // 🛡️ Guard against multiple redundant redirections
    if (_isNavigatingToLogin) {
      developer.log(
          '🚫 [BaseService] Redirection to login already in progress, skipping.',
          name: 'auth');
      return;
    }

    _isNavigatingToLogin = true;

    // Post event to DevTools
    developer.postEvent('SessionExpired', {
      'message': '会话已过期，请重新登录',
      'timestamp': DateTime.now().toIso8601String(),
    });

    final context = MyApp.navigatorKey.currentContext;

    if (context != null) {
      try {
        developer.log(
            '🚀 [BaseService] Navigating to login screen (/create_account)',
            name: 'auth');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/create_account',
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        developer.log('❌ [BaseService] Navigation failed: $e', name: 'auth');
        _isNavigatingToLogin =
            false; // Reset on failure so we can try again if another error hits
      }
    } else {
      _isNavigatingToLogin = false; // Reset if context is not available
    }

    // Reset the flag after a delay to allow for future redirections if a new session expires
    // 5 seconds is more than enough for the navigation to complete and the UI to settle
    Future.delayed(const Duration(seconds: 5), () {
      _isNavigatingToLogin = false;
    });
  }
}
