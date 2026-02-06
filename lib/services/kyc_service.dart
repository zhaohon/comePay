import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/kyc_eligibility_model.dart';
import 'package:Demo/models/kyc_model.dart';
import 'package:Demo/models/responses/kyc_status_response_model.dart';

class KycService extends BaseService {
  KycService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api';
  }

  Future<Map<String, dynamic>> getUserKyc(String email) async {
    // User requested to disable this API call for now
    print('Starting KYC request for email: $email (DISABLED)');
    return {'total': 0, 'list': <KycModel>[]};

    /* 
    final endpoint = '/v1/kyc';
    final queryParams = {
      'page': 1,
      'limit': 10,
      'email': email,
    };

    // 不需要手动添加token，父类拦截器会自动处理
    final response = await dio.get(endpoint, queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == 200 && data['data'] != null) {
        final kycData = data['data'];
        final total = kycData['total'] as int;
        final list = (kycData['list'] as List)
            .map((json) => KycModel.fromJson(json))
            .toList();
        print('KYC data fetched successfully: total=$total');
        return {'total': total, 'list': list};
      } else {
        print('Error: Invalid response format or code not 200');
        throw Exception('Invalid response format or code not 200');
      }
    } else {
      print('Error: Failed to fetch KYC data: ${response.statusCode}');
      throw Exception('Failed to fetch KYC data: ${response.statusCode}');
    }
    */
  }

  /// 获取用户KYC状态（包括最新的KYC记录和失败原因）
  Future<KycStatusResponseModel> getKycStatus() async {
    print('Fetching user KYC status...');
    final endpoint = '/v1/didit/status';

    // Using BaseService get method which handles tokens and error logging if configured
    final response = await get(endpoint);

    if (response['status'] == 'success' ||
        response['user_kyc_status'] != null) {
      return KycStatusResponseModel.fromJson(response);
    } else {
      print('Error: Failed to fetch KYC status');
      throw Exception('Failed to fetch KYC status');
    }
  }

  /// 检查用户是否有资格进行KYC认证
  /// 返回资格状态，包括是否已支付开卡费
  Future<KycEligibilityModel> checkEligibility() async {
    print('Checking KYC eligibility...');

    final endpoint = '/v1/kyc/eligibility';

    // 不需要手动添加token，父类拦截器会自动处理
    final response = await dio.get(endpoint);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['status'] == 'success') {
        print('KYC eligibility checked: eligible=${data['eligible']}');
        return KycEligibilityModel.fromJson(data);
      } else {
        print('Error: Invalid eligibility response');
        throw Exception('Invalid eligibility response');
      }
    } else {
      print('Error: Failed to check eligibility: ${response.statusCode}');
      throw Exception('Failed to check eligibility: ${response.statusCode}');
    }
  }
}
