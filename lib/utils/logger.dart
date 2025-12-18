import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _apiPrefix = '[API]';
  static const String _requestPrefix = '[REQUEST]';
  static const String _responsePrefix = '[RESPONSE]';
  static const String _errorPrefix = '[ERROR]';

  static void _log(LogLevel level, String prefix, String message,
      {dynamic data}) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    String logMessage = '[$timestamp] $levelStr $prefix $message';

    if (data != null && kDebugMode) {
      logMessage += '\nData: ${data.toString()}';
    }

    // Print to console
    if (kDebugMode) {
      debugPrint(logMessage);
    }

    // In production, you might want to send logs to a service
    // For now, we'll just use debugPrint for development
  }

  static void apiInfo(String message, {dynamic data}) {
    _log(LogLevel.info, _apiPrefix, message, data: data);
  }

  static void request(String method, String url,
      {dynamic headers, dynamic body}) {
    String message = '$method $url';
    Map<String, dynamic> logData = {
      'method': method,
      'url': url,
    };

    if (headers != null) {
      logData['headers'] = headers;
    }

    if (body != null) {
      // Don't log sensitive data like passwords
      final safeBody = _sanitizeData(body);
      logData['body'] = safeBody;
    }

    _log(LogLevel.info, _requestPrefix, message, data: logData);
  }

  static void response(String method, String url, int statusCode,
      dynamic response, Duration duration) {
    String message =
        '$method $url - Status: $statusCode - Duration: ${duration.inMilliseconds}ms';
    Map<String, dynamic> logData = {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'duration': '${duration.inMilliseconds}ms',
    };

    if (response != null) {
      logData['response'] = response;
    }

    _log(statusCode >= 400 ? LogLevel.warning : LogLevel.info, _responsePrefix,
        message,
        data: logData);
  }

  static void error(
      String method, String url, dynamic error, StackTrace? stackTrace) {
    String message = '$method $url - Error: ${error.toString()}';
    Map<String, dynamic> logData = {
      'method': method,
      'url': url,
      'error': error.toString(),
    };

    if (stackTrace != null) {
      logData['stackTrace'] = stackTrace.toString();
    }

    _log(LogLevel.error, _errorPrefix, message, data: logData);
  }

  static void businessLogic(String method, String message, {dynamic data}) {
    _log(LogLevel.info, '[BUSINESS]', '$method: $message', data: data);
  }

  // Sanitize sensitive data before logging
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      Map<String, dynamic> sanitized = {};
      data.forEach((key, value) {
        // Don't log sensitive fields
        if (key.toLowerCase().contains('password') ||
            key.toLowerCase().contains('token') ||
            key.toLowerCase().contains('secret') ||
            key.toLowerCase().contains('key')) {
          sanitized[key] = '***HIDDEN***';
        } else {
          sanitized[key] = _sanitizeData(value);
        }
      });
      return sanitized;
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    } else {
      return data;
    }
  }
}
