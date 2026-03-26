import 'package:comecomepay/core/base_service.dart';

class SwapService extends BaseService {
  SwapService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 获取特定货币对的汇率
  Future<Map<String, dynamic>> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final response = await get(
      '/wallet/exchange-rate',
      queryParameters: {
        'from': fromCurrency,
        'to': toCurrency,
      },
    );
    return response;
  }

  /// 创建兑换预览/报价
  Future<Map<String, dynamic>> createPreview({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    final response = await post(
      '/wallet/swap/preview',
      data: {
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'amount': amount,
      },
    );
    return response;
  }

  /// 执行兑换
  Future<Map<String, dynamic>> executeSwap({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    String? quoteId,
    int? cardId,
  }) async {
    final requestData = {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'amount': amount,
    };

    if (quoteId != null) {
      requestData['quote_id'] = quoteId;
    }

    if (cardId != null) {
      requestData['card_id'] = cardId;
    }

    final response = await post(
      '/wallet/swap',
      data: requestData,
    );
    return response;
  }

  /// 获取兑换历史
  Future<Map<String, dynamic>> getSwapHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      '/wallet/swap/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response;
  }
}
