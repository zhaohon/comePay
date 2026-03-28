import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/three_ds_record_model.dart';

class ThreeDSService extends BaseService {
  Future<GetThreeDSRecordsResponse> getMyRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await get(
      '/3ds/my-records',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    return GetThreeDSRecordsResponse.fromJson(response['data']);
  }
}
