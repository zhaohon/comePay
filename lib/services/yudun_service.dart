import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';

class YudunService extends BaseService {
  /// 获取支持的币种列表（带余额）
  /// GET /api/v1/yudun/coins?show_balance=true
  Future<Map<String, dynamic>> getCoins({bool showBalance = true}) async {
    try {
      final response = await dio.get(
        '/yudun/coins',
        queryParameters: {
          'show_balance': showBalance,
        },
      );

      final data = handleResponse(response);
      return data;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('获取币种列表失败: ${e.toString()}');
    }
  }
}

