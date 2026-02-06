import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/responses/app_version_response_model.dart';
import 'package:dio/dio.dart';

/// 应用版本检查服务
class AppVersionService extends BaseService {
  /// 获取最新应用版本信息
  ///
  /// 参数:
  /// - platform: 平台类型，例如 "android" 或 "ios"
  ///
  /// 返回:
  /// - AppVersionResponseModel: 包含版本信息的响应模型
  Future<AppVersionResponseModel> getLatestVersion({
    String platform = 'android',
  }) async {
    try {
      final response = await dio.get(
        '/app-version',
        queryParameters: {
          'platform': platform,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      return AppVersionResponseModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
