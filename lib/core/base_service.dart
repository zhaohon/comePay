import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:comecomepay/utils/constants.dart';
import 'package:comecomepay/services/api_logger_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

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
    // Accept all status codes so our custom exception handling can work
    validateStatus: (status) => true,
  ));

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
      onError: (error, handler) {
        final startTime =
            error.requestOptions?.extra['request_start_time'] as int?;
        final duration = startTime != null
            ? DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(startTime))
            : Duration.zero;
        _apiLogger.logError(error, error.stackTrace);

        // 结束 DevTools Timeline 追踪
        developer.Timeline.finishSync();

        // 发送错误事件到 DevTools
        developer.postEvent('HTTP Error', {
          'method': error.requestOptions.method,
          'url': error.requestOptions.uri.toString(),
          'error': error.message ?? 'Unknown error',
        });

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
        return data;
      case 400:
        throw Exception('Bad Request: ${data['message'] ?? 'Invalid request'}');
      case 401:
        throw UnauthorizedException(data['message'] ?? 'Invalid credentials');
      case 403:
        throw ForbiddenException(
            data['message'] ?? 'Access denied - OTP required');
      case 404:
        throw Exception(
            'Not Found: ${data['message'] ?? 'Resource not found'}');
      case 422:
        throw Exception(
            'Validation Error: ${data['message'] ?? 'Invalid data'}');
      case 429:
        throw Exception(
            'Too Many Requests: ${data['message'] ?? 'Rate limit exceeded'}');
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
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making POST requests
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making PUT requests
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Common method for making DELETE requests
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
