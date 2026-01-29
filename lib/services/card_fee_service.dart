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
  /// [cardType] 卡片类型: 'virtual' 或 'physical'
  Future<CardFeeConfigModel> getConfig(String cardType) async {
    try {
      final response = await get(
        '/CardFee/GetConfig',
        queryParameters: {'card_type': cardType},
      );

      if (response['status'] == 'success' && response['config'] != null) {
        return CardFeeConfigModel.fromJson(response['config']);
      } else {
        throw Exception('Failed to get card fee config');
      }
    } catch (e) {
      print('Error getting card fee config: $e');
      rethrow;
    }
  }

  /// 获取支持的支付币种列表 (USDT/USDC)
  Future<List<PaymentCurrencyModel>> getCurrencies() async {
    try {
      final response = await get('/CardFee/GetCurrencies');

      if (response['status'] == 'success' && response['currencies'] != null) {
        final currencies = response['currencies'] as List;
        return currencies
            .map((json) => PaymentCurrencyModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get payment currencies');
      }
    } catch (e) {
      print('Error getting payment currencies: $e');
      rethrow;
    }
  }

  /// 创建开卡费支付订单
  /// [cardType] 卡片类型: 'virtual' 或 'physical'
  /// [couponCode] 可选的优惠券码
  Future<CardFeePaymentModel> createPayment({
    required String cardType,
    String? couponCode,
  }) async {
    try {
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
    } catch (e) {
      print('Error creating card fee payment: $e');
      rethrow;
    }
  }

  /// 完成支付（从用户钱包扣款）
  /// [transactionRef] 交易参考号（从createPayment返回）
  /// [paymentCurrency] 支付币种名称，如 "USDT-TRC20"
  Future<CardFeePaymentModel> completePayment({
    required String transactionRef,
    required String paymentCurrency,
  }) async {
    try {
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
    } catch (e) {
      print('Error completing card fee payment: $e');
      rethrow;
    }
  }

  /// 查询当前用户的支付状态 (New Interface)
  Future<CardFeeStatusResponseModel> getPaymentStatus() async {
    try {
      // Endpoint from ccp (6).md
      // Note: BaseUrl is likely .../api/v1
      final response = await get('/CardFee/GetPaymentStatus');

      if (response['status'] == 'success') {
        return CardFeeStatusResponseModel.fromJson(response);
      } else {
        throw Exception('Failed to get payment status');
      }
    } catch (e) {
      print('Error getting payment status: $e');
      rethrow;
    }
  }

  /// 获取更详细的开卡统计信息 (New API 2026-01-28)
  Future<CardFeeStatsResponseModel> getCardStats() async {
    try {
      final response = await get('/CardFee/GetStats');

      if (response['status'] == 'success') {
        return CardFeeStatsResponseModel.fromJson(response);
      } else {
        throw Exception('Failed to get card stats');
      }
    } catch (e) {
      print('Error getting card stats: $e');
      rethrow;
    }
  }

  /// 查询支付历史记录
  /// [page] 页码，从1开始
  /// [pageSize] 每页条数
  Future<List<CardFeePaymentModel>> getPaymentHistory({
    required int page,
    required int pageSize,
  }) async {
    try {
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
    } catch (e) {
      print('Error getting payment history: $e');
      rethrow;
    }
  }
}
