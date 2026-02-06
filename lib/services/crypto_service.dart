import 'package:Demo/core/base_service.dart';
import 'package:Demo/models/responses/crypto_response_model.dart';

class CryptoService extends BaseService {
  Future<List<CryptoResponse>> fetchCryptoData() async {
    try {
      final response = await dio.get(
        'https://api.coingecko.com/api/v3/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids':
              'tether,bitcoin,ethereum,binancecoin,matic-network,tron,hongkong-dollar-token',
          // 'ids': 'bitcoin,ethereum,tether,usd-coin,hongkong-dollar-token',
          'sparkline': true,
        },
      );

      final data = handleResponse(response);
      return (data as List)
          .map((item) => CryptoResponse.fromJson(item))
          .toList();
    } catch (e) {
      throw e;
    }
  }
}
