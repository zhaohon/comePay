import 'package:comecomepay/core/base_service.dart';

class YudunService extends BaseService {
  /// 获取支持的币种列表（带余额）
  Future<Map<String, dynamic>> getCoins({bool showBalance = true}) async {
    final response = await get(
      '/yudun/coins',
      queryParameters: {
        'show_balance': showBalance,
      },
    );
    return response;
  }
}
