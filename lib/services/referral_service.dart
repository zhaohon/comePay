import 'package:dio/dio.dart';
import 'package:comecomepay/utils/logger.dart';

class ReferralService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://31.97.222.142:2050',
    headers: {
      'Content-Type': 'application/json',
      'id_user': '42',
    },
  ));

  Future<Map<String, dynamic>> createReferral() async {
    const String method = 'POST';
    const String url = '/api/referral/create';
    final Map<String, dynamic> body = {
      'friend_email': 'friend@example.com',
      'base_url': 'https://app.example.com'
    };

    Logger.request(method, url, body: body);

    try {
      final startTime = DateTime.now();
      final response = await _dio.post(url, data: body);
      final duration = DateTime.now().difference(startTime);

      Logger.response(method, url, response.statusCode ?? 0, response.data, duration);

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      Logger.error(method, url, e, stackTrace);
      rethrow;
    }
  }
}
