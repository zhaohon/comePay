import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/kyc_eligibility_model.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/models/responses/kyc_status_response_model.dart';

class KycService extends BaseService {
  KycService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api';
  }

  Future<Map<String, dynamic>> getUserKyc(String email) async {
    // User requested to disable this API call for now
    return {'total': 0, 'list': <KycModel>[]};
  }

  /// 获取用户KYC状态（包括最新的KYC记录和失败原因）
  Future<KycStatusResponseModel> getKycStatus() async {
    final response = await get('/v1/didit/status');
    return KycStatusResponseModel.fromJson(response);
  }

  /// 检查用户是否有资格进行KYC认证
  Future<KycEligibilityModel> checkEligibility() async {
    final response = await get('/v1/kyc/eligibility');
    return KycEligibilityModel.fromJson(response);
  }
}
