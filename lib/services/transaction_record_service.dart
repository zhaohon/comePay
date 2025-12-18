import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/transaction_record_model.dart';

class TransactionRecordService extends BaseService {
  Future<TransactionRecordResponse> fetchTransactionRecords({int page = 1, int limit = 10}) async {
    try {
      final response = await dio.get(
        'http://31.97.222.142:2050/api/transaction-record',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'demo': 'true',
          },
        ),
      );

      final data = handleResponse(response);
      return TransactionRecordResponse.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch transaction records: ${e.toString()}');
    }
  }
}
