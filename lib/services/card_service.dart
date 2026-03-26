import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:comecomepay/models/card_apply_progress_model.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/models/physical_upgrade_fee_info_model.dart';
import 'package:comecomepay/models/physical_upgrade_progress_model.dart';
import 'package:dio/dio.dart';

class CardService extends BaseService {
  CardService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 申请卡片
  Future<CardApplyResponseModel> applyCard(
      CardApplyRequestModel request) async {
    final response = await post('/card/apply', data: request.toJson());
    return CardApplyResponseModel.fromJson(response);
  }

  /// 获取实体卡升级费用信息
  Future<PhysicalUpgradeFeeInfoModel> getPhysicalUpgradeFeeInfo() async {
    final response = await get('/card/physical/upgrade/fee-info');
    return PhysicalUpgradeFeeInfoModel.fromJson(response['data']);
  }

  /// 查询实体卡升级进度
  Future<PhysicalUpgradeProgressData?> getPhysicalUpgradeProgress(
      String publicToken) async {
    final response = await get(
      '/card/physical/upgrade/progress',
      queryParameters: {'public_token': publicToken},
    );
    return response['data'] != null
        ? PhysicalUpgradeProgressData.fromJson(response['data'])
        : null;
  }

  /// 发送实体卡升级邮箱验证码
  Future<void> sendPhysicalUpgradeEmailCode(
      String publicToken, String email) async {
    await post(
      '/card/physical/upgrade/email-code/send',
      data: {
        'email': email,
        'public_token': publicToken,
        'scene': 'physical_upgrade',
      },
    );
  }

  /// 校验实体卡升级邮箱验证码
  Future<String> verifyPhysicalUpgradeEmailCode(
      String publicToken, String code) async {
    final response = await post(
      '/card/physical/upgrade/email-code/verify',
      data: {
        'code': code,
        'public_token': publicToken,
        'scene': 'physical_upgrade',
      },
    );
    return response['data']['verify_token'] as String;
  }

  /// 提交虚拟卡升级实体卡申请（PUT /card/convertToPhysical）
  Future<Map<String, dynamic>> submitPhysicalUpgrade({
    required String publicToken,
    required String verifyToken,
    required String recipient,
    required String nameOnCard,
    required String areaCode,
    required String phone,
    required String postalCountry,
    required String postalState,
    required String postalCity,
    required String postalAddress,
    required String postalCode,
    required String paymentCurrency,
  }) async {
    final idempotencyKey =
        'phy_${DateTime.now().millisecondsSinceEpoch}_${publicToken.length > 20 ? publicToken.substring(0, 20) : publicToken}';
    final body = {
      'public_token': publicToken,
      'verify_token': verifyToken,
      'recipient': recipient,
      'name_on_card': nameOnCard,
      'area_code': areaCode,
      'phone': phone,
      'postal_country': postalCountry,
      'postal_state': postalState,
      'postal_city': postalCity,
      'postal_address': postalAddress,
      'postal_code': postalCode,
      'payment_currency': paymentCurrency,
    };
    final responseData = await put(
      '/card/convertToPhysical',
      data: body,
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    return responseData['data'] as Map<String, dynamic>;
  }

  /// 查询开卡进度
  Future<CardApplyProgressModel> getApplyProgress(int taskId) async {
    final response = await get('/card/apply/progress/$taskId');
    return CardApplyProgressModel.fromJson(response);
  }

  /// 获取卡片列表
  Future<CardListResponseModel> getCardList() async {
    try {
      final response = await get('/card/list');
      if (response['status'] == 'success' && response['data'] != null) {
        return CardListResponseModel.fromJson(response);
      }
      return CardListResponseModel(total: 0, cards: []);
    } catch (e) {
      // 接口报错时，返回空列表而不是抛错，这样UI可以显示申请页面
      return CardListResponseModel(total: 0, cards: []);
    }
  }

  /// 获取卡片详情（含余额）
  Future<CardAccountDetailsModel> getCardAccountDetails(
      String publicToken) async {
    final response = await get(
      '/card/account-details',
      queryParameters: {'public_token': publicToken},
    );
    return CardAccountDetailsModel.fromJson(response);
  }

  /// 查询卡片状态
  Future<Map<String, dynamic>> getCardStatus(String publicToken) async {
    final response = await get(
      '/card/status',
      queryParameters: {'public_token': publicToken},
    );
    return response['data'] as Map<String, dynamic>;
  }

  /// 获取交易记录
  Future<Map<String, dynamic>> getTransactionHistory({
    required String publicToken,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      '/card/transaction-history',
      queryParameters: {
        'public_token': publicToken,
        'page': page,
        'limit': limit,
      },
    );
    return response['data'] as Map<String, dynamic>;
  }

  /// 获取CVV
  Future<String> getCvv(String publicToken) async {
    final response = await get(
      '/card/cvv',
      queryParameters: {'public_token': publicToken},
    );
    final data = response['data'] as Map<String, dynamic>;
    return data['cvv'] as String? ?? '';
  }

  /// 发送卡片PIN邮箱验证码
  Future<void> sendPinCode(String publicToken, String purpose) async {
    await post(
      '/card/$publicToken/pin/code/send',
      data: {'purpose': purpose},
    );
  }

  /// 获取PIN
  Future<String> getPin(String publicToken, String otpCode) async {
    final response = await get(
      '/card/$publicToken/pin',
      queryParameters: {'otp_code': otpCode},
    );
    final data = response['data'] as Map<String, dynamic>;
    return data['pin'] as String? ?? '';
  }

  /// 设置/重置卡片PIN码
  Future<void> setPin(String publicToken, String pin, String otpCode) async {
    await post(
      '/card/$publicToken/pin',
      data: {
        'pin': pin,
        'otp_code': otpCode,
      },
    );
  }

  /// 获取完整卡号
  Future<Map<String, String>> getFullCardNumber(String publicToken) async {
    final response = await post(
      '/card/full-number',
      data: {'public_token': publicToken},
    );
    final data = response['data'] as Map<String, dynamic>;
    return {
      'card_number': data['card_number'] as String? ?? '',
      'cvv': data['cvv'] as String? ?? '',
    };
  }

  /// 修改卡片状态
  Future<Map<String, dynamic>> modifyCardStatus(
      String publicToken, String statusCode) async {
    final response = await put(
      '/card/status',
      data: {
        'public_token': publicToken,
        'card_status_code': statusCode,
      },
    );
    return response['data'] as Map<String, dynamic>;
  }
}
