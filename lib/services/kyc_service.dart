import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/models/kyc_eligibility_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class KycService extends BaseService {
  // Override dio to use different baseUrl for KYC API
  @override
  Dio get dio => Dio(BaseOptions(
        baseUrl: 'http://149.88.65.193:8010/api',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true,
      ));

  Future<Map<String, dynamic>> getUserKyc(String email) async {
    print('Starting KYC request for email: $email');
    final token = HiveStorageService.getAccessToken();

    if (token == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }

    final endpoint = '/kyc';
    final queryParams = {
      'page': 1,
      'limit': 10,
      'email': email,
    };

    final response = await dio.get(endpoint,
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}));

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
  }

  /// 检查用户是否有资格进行KYC认证
  /// 返回资格状态，包括是否已支付开卡费
  Future<KycEligibilityModel> checkEligibility() async {
    print('Checking KYC eligibility...');
    final token = HiveStorageService.getAccessToken();

    if (token == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }

    final endpoint = '/v1/kyc/eligibility';

    final response = await dio.get(
      endpoint,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

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
