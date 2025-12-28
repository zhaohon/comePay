import 'package:comecomepay/core/base_service.dart';

/// 提现请求模型
class WithdrawRequestModel {
  final String address;
  final double amount;
  final String currency;
  final String memo;

  WithdrawRequestModel({
    required this.address,
    required this.amount,
    required this.currency,
    this.memo = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'amount': amount,
      'currency': currency,
      'memo': memo,
    };
  }
}

/// 提现响应模型
class WithdrawResponseModel {
  final String status;
  final String message;
  final int withdrawalId;
  final double amount;
  final String currency;
  final double fee;
  final String estimatedTime;

  WithdrawResponseModel({
    required this.status,
    required this.message,
    required this.withdrawalId,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.estimatedTime,
  });

  factory WithdrawResponseModel.fromJson(Map<String, dynamic> json) {
    return WithdrawResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      withdrawalId: json['withdrawal_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      fee: (json['fee'] ?? 0).toDouble(),
      estimatedTime: json['estimated_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'withdrawal_id': withdrawalId,
      'amount': amount,
      'currency': currency,
      'fee': fee,
      'estimated_time': estimatedTime,
    };
  }
}

/// 提现服务
class WithdrawService extends BaseService {
  WithdrawService() {
    // 设置baseUrl，保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 提交提现请求
  /// [request] 提现请求模型
  Future<WithdrawResponseModel> withdraw(WithdrawRequestModel request) async {
    try {
      final response = await post('/card/withdraw', data: request.toJson());

      if (response['status'] == 'success') {
        return WithdrawResponseModel.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Withdrawal failed');
      }
    } catch (e) {
      print('Error submitting withdrawal: $e');
      rethrow;
    }
  }
}
