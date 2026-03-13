import 'package:comecomepay/core/base_service.dart';

/// 用户服务 - 用于获取用户相关信息
class UserService extends BaseService {
  UserService() {
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 获取交易密码设置状态
  /// 返回 true 表示已设置，false 表示未设置
  Future<bool> getTransactionPasswordStatus() async {
    try {
      final response = await get('/user/transaction-password/status');

      if (response['status'] == 'success') {
        return response['is_set'] == true;
      }
      return false;
    } catch (e) {
      print('Error fetching transaction password status: $e');
      rethrow;
    }
  }
}
