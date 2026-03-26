import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/transaction_record_model.dart';
import 'package:dio/dio.dart';

class TransactionRecordService extends BaseService {
  Future<TransactionRecordResponse> fetchTransactionRecords(
      {int page = 1, int limit = 10}) async {
    final response = await get(
      'http://149.88.65.193:8010/api/transaction-record',
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
