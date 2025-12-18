import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/card_trade_model.dart';

class CardTradeService extends BaseService {
  Future<CardTradeResponse> fetchCardTrades({
    required String publicToken,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        'http://31.97.222.142:2050/api/v1/card/trade',
        queryParameters: {
          'publicToken': publicToken,
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      return CardTradeResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch card trades: ${e.toString()}');
    }
  }
}
