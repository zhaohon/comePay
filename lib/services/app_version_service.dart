import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/responses/app_version_response_model.dart';

/// 应用版本检查服务
class AppVersionService extends BaseService {
  /// 获取最新应用版本信息
  Future<AppVersionResponseModel> getLatestVersion({
    required String platform,
  }) async {
    final response = await get(
      '/app-version',
      queryParameters: {
        'platform': platform,
      },
    );

    return AppVersionResponseModel.fromJson(response);
  }
}
