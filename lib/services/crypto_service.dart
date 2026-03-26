import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/responses/crypto_response_model.dart';

class CryptoService extends BaseService {
  Future<List<CryptoResponse>> fetchCryptoData() async {
    final response = await get(
      'https://api.coingecko.com/api/v3/coins/markets',
      queryParameters: {
        'vs_currency': 'usd',
        'ids':
            'tether,bitcoin,ethereum,binancecoin,matic-network,tron,hongkong-dollar-token',
        'sparkline': true,
      },
    );

    return (response as List)
        .map((item) => CryptoResponse.fromJson(item))
        .toList();
  }
}
