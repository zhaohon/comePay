import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/three_ds_record_model.dart';

class ThreeDSService extends BaseService {
  Future<GetThreeDSRecordsResponse> getMyRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/3ds/my-records',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.data['status'] == 'success' &&
          response.data['data'] != null) {
        return GetThreeDSRecordsResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      rethrow;
    }
  }
}
