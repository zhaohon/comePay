import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

class SwapService extends BaseService {
  Future<Map<String, dynamic>> getExchangeRate({
    required String srcCurrencyCode,
    required String dstCurrencyCode,
  }) async {
    try {
      final token = HiveStorageService.getAccessToken();
      final response = await dio.get(
        'https://testagent.pokepay.cc/api/v1/system/currencySimple',
        queryParameters: {
          'src_currency_code': srcCurrencyCode,
          'dst_currency_code': dstCurrencyCode,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch exchange rate: ${e.toString()}');
    }
  }
}
