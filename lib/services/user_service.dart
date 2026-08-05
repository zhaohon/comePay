import 'package:comecomepay/core/base_service.dart';

/// 用户服务 - 用于获取用户相关信息
class UserService extends BaseService {
  UserService() {
    dio.options.baseUrl = 'https://app.comecomepay.com/api/v1';
  }

  /// 获取交易密码设置状态
  Future<bool> getTransactionPasswordStatus() async {
    final response = await get('/user/transaction-password/status');
    return response['is_set'] == true;
  }

  /// 获取合作方链接
  Future<Map<String, String>?> getPartnerLink() async {
    try {
      final response = await get('/partner-link');
      if (response != null && response is Map<String, dynamic>) {
        // 如果后端包了一层 data，解开它
        final Map<String, dynamic> data =
            response.containsKey('data') ? response['data'] : response;

        final name = data['name']?.toString() ?? '';
        final url = data['url']?.toString() ?? '';

        if (name.isNotEmpty && url.isNotEmpty) {
          return {
            'name': name,
            'url': url,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 请求注销账号 (Request deactivation OTP)
  Future<Map<String, dynamic>> requestAccountDeactivation() async {
    final response = await post('/user/deactivate/request');
    return response as Map<String, dynamic>;
  }

  /// 确认注销账号 (Submit deactivation OTP)
  Future<Map<String, dynamic>> submitAccountDeactivation(String otpCode) async {
    final response = await post('/user/deactivate', data: {
      'otp_code': otpCode,
    });
    return response as Map<String, dynamic>;
  }
}
