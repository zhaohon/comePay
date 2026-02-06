import 'package:Demo/core/base_service.dart';

/// 提现请求模型
class WithdrawRequestModel {
  final String currency;
  final double amount;
  final String address;
  final String network;

  WithdrawRequestModel({
    required this.currency,
    required this.amount,
    required this.address,
    required this.network,
  });

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'amount': amount,
      'address': address,
      'network': network,
    };
  }
}

/// 提现响应模型
class WithdrawResponseModel {
  final String status;
  final String message;
  final dynamic withdrawal; // 可能为 null

  WithdrawResponseModel({
    required this.status,
    required this.message,
    this.withdrawal,
  });

  factory WithdrawResponseModel.fromJson(Map<String, dynamic> json) {
    return WithdrawResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      withdrawal: json['withdrawal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'withdrawal': withdrawal,
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
      final response = await post('/wallet/withdrawal', data: request.toJson());

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

  /// 获取提现历史记录
  /// [page] 页码（默认1）
  /// [limit] 每页数量（默认20）
  /// [status] 提现状态（可选）
  Future<WithdrawHistoryResponseModel> getWithdrawHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response =
          await get('/wallet/withdrawals', queryParameters: queryParams);

      return WithdrawHistoryResponseModel.fromJson(response);
    } catch (e) {
      print('Error fetching withdrawal history: $e');
      rethrow;
    }
  }
}

/// 提现历史记录响应模型
class WithdrawHistoryResponseModel {
  final String status;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<dynamic> items; // 实际字段名是 items

  WithdrawHistoryResponseModel({
    required this.status,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory WithdrawHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return WithdrawHistoryResponseModel(
      status: json['status'] ?? '',
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      items: json['items'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
      'items': items,
    };
  }
}
