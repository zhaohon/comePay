import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/transaction_record_model.dart';
import 'package:dio/dio.dart';

class TransactionRecordService extends BaseService {
  Future<TransactionRecordResponse> fetchTransactionRecords(
      {int page = 1, int limit = 10}) async {
    final response = await get(
      'http://8.163.2.250/api/transaction-record',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      options: Options(
        headers: {
          'demo': 'true',
        },
      ),
    );

    return TransactionRecordResponse.fromJson(response);
  }
}
