import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';

class SwapService extends BaseService {
  SwapService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 获取特定货币对的汇率
  /// GET /wallet/exchange-rate?from={from_currency}&to={to_currency}
  Future<Map<String, dynamic>> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await dio.get(
        '/wallet/exchange-rate',
        queryParameters: {
          'from': fromCurrency,
          'to': toCurrency,
        },
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('获取汇率失败: ${e.toString()}');
    }
  }

  /// 创建兑换预览/报价
  /// POST /wallet/swap/preview
  Future<Map<String, dynamic>> createPreview({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final response = await dio.post(
        '/wallet/swap/preview',
        data: {
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'amount': amount,
        },
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('创建报价失败: ${e.toString()}');
    }
  }

  /// 执行兑换
  /// POST /wallet/swap
  Future<Map<String, dynamic>> executeSwap({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    String? quoteId,
    int? cardId, // 当涉及HKD时必填
  }) async {
    try {
      final requestData = {
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'amount': amount,
      };

      if (quoteId != null) {
        requestData['quote_id'] = quoteId;
      }

      // 当涉及HKD时，card_id是必填的
      if (cardId != null) {
        requestData['card_id'] = cardId;
      }

      final response = await dio.post(
        '/wallet/swap',
        data: requestData,
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('执行兑换失败: ${e.toString()}');
    }
  }

  /// 获取兑换历史
  /// GET /wallet/swap/history?page={page}&limit={limit}
  Future<Map<String, dynamic>> getSwapHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/wallet/swap/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('获取兑换历史失败: ${e.toString()}');
    }
  }
}
