import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/card_fee_config_model.dart';
import 'package:comecomepay/models/payment_currency_model.dart';
import 'package:comecomepay/models/card_fee_payment_model.dart';
import 'package:comecomepay/models/responses/card_fee_status_response_model.dart';
import 'package:comecomepay/models/responses/card_fee_stats_response_model.dart';

class CardFeeService extends BaseService {
  CardFeeService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 获取开卡费配置
  Future<CardFeeConfigModel> getConfig(String cardType) async {
    final response = await get(
      '/CardFee/GetConfig',
      queryParameters: {'card_type': cardType},
    );

    if (response['status'] == 'success' && response['config'] != null) {
      return CardFeeConfigModel.fromJson(response['config']);
    } else {
      throw Exception('Failed to get card fee config');
    }
  }

  /// 获取支持的支付币种列表 (USDT/USDC)
  Future<List<PaymentCurrencyModel>> getCurrencies() async {
    final response = await get('/CardFee/GetCurrencies');

    if (response['status'] == 'success' && response['currencies'] != null) {
      final currencies = response['currencies'] as List;
      return currencies
          .map((json) => PaymentCurrencyModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get payment currencies');
    }
  }

  /// 创建开卡费支付订单
  Future<CardFeePaymentModel> createPayment({
    required String cardType,
    String? couponCode,
  }) async {
    final data = {
      'card_type': cardType,
      if (couponCode != null && couponCode.isNotEmpty)
        'coupon_code': couponCode,
    };

    final response = await post('/CardFee/CreatePayment', data: data);

    if (response['status'] == 'success' && response['payment'] != null) {
      return CardFeePaymentModel.fromJson(response['payment']);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to create card fee payment');
    }
  }

  /// 完成支付（从用户钱包扣款）
  Future<CardFeePaymentModel> completePayment({
    required String transactionRef,
    required String paymentCurrency,
  }) async {
    final data = {
      'payment_currency': paymentCurrency,
    };

    final response = await post(
      '/CardFee/CompletePayment/$transactionRef',
      data: data,
    );

    if (response['status'] == 'success' && response['payment'] != null) {
      return CardFeePaymentModel.fromJson(response['payment']);
    } else {
      throw Exception(
          response['message'] ?? 'Failed to complete card fee payment');
    }
  }

  /// 查询当前用户的支付状态 (New Interface)
  Future<CardFeeStatusResponseModel> getPaymentStatus() async {
    final response = await get('/CardFee/GetPaymentStatus');

    if (response['status'] == 'success') {
      return CardFeeStatusResponseModel.fromJson(response);
    } else {
      throw Exception('Failed to get payment status');
    }
  }

  /// 获取更详细的开卡统计信息 (New API 2026-01-28)
  Future<CardFeeStatsResponseModel> getCardStats() async {
    final response = await get('/CardFee/GetStats');

    if (response['status'] == 'success') {
      return CardFeeStatsResponseModel.fromJson(response);
    } else {
      throw Exception('Failed to get card stats');
    }
  }

  /// 查询支付历史记录
  Future<List<CardFeePaymentModel>> getPaymentHistory({
    required int page,
    required int pageSize,
  }) async {
    final response = await get(
      '/CardFee/GetPaymentHistory',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    if (response['status'] == 'success' && response['payments'] != null) {
      final payments = response['payments'] as List;
      return payments
          .map((json) => CardFeePaymentModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get payment history');
    }
  }
}
