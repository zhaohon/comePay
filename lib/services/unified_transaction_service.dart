import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/unified_transaction_model.dart';

/// 统一交易记录服务
class UnifiedTransactionService extends BaseService {
  /// 获取统一交易记录列表
  Future<UnifiedTransactionApiResponse> fetchUnifiedTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    // 构建查询参数
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    // 添加可选的筛选参数
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParameters['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParameters['end_date'] = endDate;
    }

    // 调用API
    final response = await get(
      '/wallet/unified-transactions',
      queryParameters: queryParameters,
    );

    return UnifiedTransactionApiResponse.fromJson(response);
  }

  /// 获取最新的N条交易记录
  Future<List<UnifiedTransaction>> fetchLatestTransactions({
    int limit = 10,
  }) async {
    final response = await fetchUnifiedTransactions(
      page: 1,
      pageSize: limit,
    );
    return response.data.items;
  }
}
