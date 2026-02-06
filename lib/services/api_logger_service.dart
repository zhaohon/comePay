import 'package:dio/dio.dart';
import 'package:Demo/utils/logger.dart';

class ApiLoggerService {
  static final ApiLoggerService _instance = ApiLoggerService._internal();

  factory ApiLoggerService() {
    return _instance;
  }

  ApiLoggerService._internal();

  // Log API request
  void logRequest(RequestOptions options) {
    Logger.request(
      options.method,
      options.uri.toString(),
      headers: options.headers,
      body: options.data,
    );
  }

  // Log API response
  void logResponse(Response response, Duration duration) {
    Logger.response(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      response.statusCode ?? 0,
      response.data,
      duration,
    );
  }

  // Log API error
  void logError(DioException error, StackTrace? stackTrace) {
    String method = 'UNKNOWN';
    String url = 'UNKNOWN';

    if (error.requestOptions != null) {
      method = error.requestOptions.method;
      url = error.requestOptions.uri.toString();
    }

    Logger.error(method, url, error, stackTrace);
  }

  // Log business logic method calls
  void logBusinessMethod(String methodName, String action,
      {dynamic parameters}) {
    Logger.businessLogic(methodName, action, data: parameters);
  }

  // Log method entry
  void logMethodEntry(String methodName, {dynamic parameters}) {
    Logger.businessLogic(methodName, 'ENTRY', data: parameters);
  }

  // Log method exit
  void logMethodExit(String methodName, {dynamic result}) {
    Logger.businessLogic(methodName, 'EXIT', data: result);
  }

  // Log successful operation
  void logSuccess(String methodName, String operation, {dynamic data}) {
    Logger.businessLogic(methodName, 'SUCCESS: $operation', data: data);
  }

  // Log failed operation
  void logFailure(String methodName, String operation, {dynamic error}) {
    Logger.businessLogic(methodName, 'FAILED: $operation', data: error);
  }
}
