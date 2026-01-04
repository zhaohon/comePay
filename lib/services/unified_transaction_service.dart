import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/unified_transaction_model.dart';

/// 统一交易记录服务
/// 调用 /wallet/unified-transactions API
class UnifiedTransactionService extends BaseService {
  /// 获取统一交易记录列表
  ///
  /// [page] 页码，从1开始，默认1
  /// [pageSize] 每页数量，1-100，默认20
  /// [type] 交易类型筛选（可选）：deposit, withdraw, swap, card_fee, commission, transfer, fee
  /// [status] 交易状态筛选（可选）：pending, completed, failed, cancelled, approved, rejected, credited
  /// [startDate] 开始日期，格式YYYY-MM-DD（可选）
  /// [endDate] 结束日期，格式YYYY-MM-DD（可选）
  Future<UnifiedTransactionApiResponse> fetchUnifiedTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
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
      final response = await dio.get(
        '/wallet/unified-transactions',
        queryParameters: queryParameters,
      );

      // 使用BaseService的handleResponse处理响应
      final data = handleResponse(response);
      return UnifiedTransactionApiResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch unified transactions: ${e.toString()}');
    }
  }

  /// 获取最新的N条交易记录
  ///
  /// [limit] 获取的记录数量
  Future<List<UnifiedTransaction>> fetchLatestTransactions({
    int limit = 10,
  }) async {
    try {
      final response = await fetchUnifiedTransactions(
        page: 1,
        pageSize: limit,
      );
      return response.data.items;
    } catch (e) {
      throw Exception('Failed to fetch latest transactions: ${e.toString()}');
    }
  }
}
