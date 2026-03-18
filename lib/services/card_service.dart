import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:comecomepay/models/card_apply_progress_model.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/models/physical_upgrade_fee_info_model.dart';
import 'package:dio/dio.dart';

class CardService extends BaseService {
  CardService() {
    // 修改baseUrl而不是创建新的Dio实例，这样可以保留父类的拦截器（包括token）
    dio.options.baseUrl = 'http://149.88.65.193:8010/api/v1';
  }

  /// 申请卡片
  /// [request] 卡片申请请求模型
  Future<CardApplyResponseModel> applyCard(
      CardApplyRequestModel request) async {
    try {
      final response = await post('/card/apply', data: request.toJson());

      if (response['status'] == 'success' && response['data'] != null) {
        return CardApplyResponseModel.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Failed to apply card');
      }
    } catch (e) {
      print('Error applying card: $e');
      rethrow;
    }
  }

  /// 获取实体卡升级费用信息
  Future<PhysicalUpgradeFeeInfoModel> getPhysicalUpgradeFeeInfo() async {
    try {
      final response = await get('/card/physical/upgrade/fee-info');

      if (response['code'] == 200 && response['data'] != null) {
        return PhysicalUpgradeFeeInfoModel.fromJson(response['data']);
      } else {
        throw Exception(
            response['errstr'] ?? 'Failed to get physical upgrade fee info');
      }
    } catch (e) {
      print('Error getting physical upgrade fee info: $e');
      rethrow;
    }
  }

  /// 发送实体卡升级邮箱验证码
  Future<void> sendPhysicalUpgradeEmailCode(
      String publicToken, String email) async {
    try {
      final response = await post(
        '/card/physical/upgrade/email-code/send',
        data: {
          'email': email,
          'public_token': publicToken,
          'scene': 'physical_upgrade',
        },
      );

      if (response['code'] != 200) {
        throw Exception(response['message'] ?? response['errstr'] ?? '发送验证码失败');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map)
          ? (data['message'] ?? data['errstr'] ?? '发送验证码失败')
          : '发送验证码失败';
      throw Exception(msg);
    } catch (e) {
      print('Error sending physical upgrade email code: $e');
      rethrow;
    }
  }

  /// 校验实体卡升级邮箱验证码
  Future<String> verifyPhysicalUpgradeEmailCode(
      String publicToken, String code) async {
    try {
      final response = await post(
        '/card/physical/upgrade/email-code/verify',
        data: {
          'code': code,
          'public_token': publicToken,
          'scene': 'physical_upgrade',
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['verify_token'] as String;
      } else {
        throw Exception(response['message'] ?? response['errstr'] ?? '验证码校验失败');
      }
    } on DioException catch (e) {
      // 后端通过非 2xx 状态码返回错误时，Dio 会抛出 DioException
      // 从 response body 里取友好的 message
      final data = e.response?.data;
      final msg = (data is Map)
          ? (data['message'] ?? data['errstr'] ?? '验证码校验失败')
          : '验证码校验失败';
      throw Exception(msg);
    } catch (e) {
      print('Error verifying physical upgrade email code: $e');
      rethrow;
    }
  }

  /// 提交虚拟卡升级实体卡申请（PUT /card/convertToPhysical）
  /// 需先完成邮箱验证获取 verify_token，请求头携带 Idempotency-Key 防重复提交
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
    try {
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
      final response = await dio.put(
        '/card/convertToPhysical',
        data: body,
        options: Options(
          headers: {'Idempotency-Key': idempotencyKey},
        ),
      );
      final data = response.data is Map
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      if (data['code'] == 200 && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception(data['errstr'] ?? data['message'] ?? '提交失败');
    } on DioException catch (e) {
      final resData = e.response?.data;
      final msg = (resData is Map)
          ? (resData['errstr'] ?? resData['message'] ?? '提交失败')
          : '提交失败';
      throw Exception(msg);
    } catch (e) {
      print('Error submitting physical upgrade: $e');
      rethrow;
    }
  }

  /// 查询开卡进度
  /// [taskId] 任务ID（从申请卡片接口返回）
  Future<CardApplyProgressModel> getApplyProgress(int taskId) async {
    try {
      final response = await get('/card/apply/progress/$taskId');

      if (response['status'] == 'success' && response['data'] != null) {
        return CardApplyProgressModel.fromJson(response);
      } else {
        throw Exception('Failed to get apply progress');
      }
    } catch (e) {
      print('Error getting apply progress: $e');
      rethrow;
    }
  }

  /// 获取卡片列表
  Future<CardListResponseModel> getCardList() async {
    try {
      final response = await get('/card/list');

      if (response['status'] == 'success') {
        // 即使data为null或total=0，也返回一个有效的对象
        if (response['data'] != null) {
          return CardListResponseModel.fromJson(response);
        } else {
          // 如果没有data，返回空列表
          return CardListResponseModel(total: 0, cards: []);
        }
      } else {
        // 如果status不是success，返回空列表而不是抛错
        print(
            'Card list API returned non-success status: ${response['status']}');
        return CardListResponseModel(total: 0, cards: []);
      }
    } catch (e) {
      print('Error getting card list: $e');
      // 接口报错时，返回空列表而不是抛错，这样UI可以显示申请页面
      return CardListResponseModel(total: 0, cards: []);
    }
  }

  /// 获取卡片详情（含余额）
  /// [publicToken] 卡片唯一标识
  Future<CardAccountDetailsModel> getCardAccountDetails(
      String publicToken) async {
    try {
      final response = await get(
        '/card/account-details',
        queryParameters: {'public_token': publicToken},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return CardAccountDetailsModel.fromJson(response);
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get card account details');
      }
    } catch (e) {
      print('Error getting card account details: $e');
      rethrow;
    }
  }

  /// 查询卡片状态
  /// [publicToken] 卡片唯一标识
  Future<Map<String, dynamic>> getCardStatus(String publicToken) async {
    try {
      final response = await get(
        '/card/status',
        queryParameters: {'public_token': publicToken},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to get card status');
      }
    } catch (e) {
      print('Error getting card status: $e');
      rethrow;
    }
  }

  /// 获取交易记录
  /// [publicToken] 卡片唯一标识
  /// [page] 页码，从1开始
  /// [limit] 每页数量，最大100
  Future<Map<String, dynamic>> getTransactionHistory({
    required String publicToken,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await get(
        '/card/transaction-history',
        queryParameters: {
          'public_token': publicToken,
          'page': page,
          'limit': limit,
        },
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get transaction history');
      }
    } catch (e) {
      print('Error getting transaction history: $e');
      rethrow;
    }
  }

  /// 获取CVV
  /// [publicToken] 卡片唯一标识
  Future<String> getCvv(String publicToken) async {
    try {
      final response = await get(
        '/card/cvv',
        queryParameters: {'public_token': publicToken},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['cvv'] as String? ?? '';
      } else {
        throw Exception(response['message'] ?? 'Failed to get CVV');
      }
    } catch (e) {
      print('Error getting CVV: $e');
      rethrow;
    }
  }

  /// 获取PIN
  /// [publicToken] 卡片唯一标识
  Future<String> getPin(String publicToken) async {
    try {
      final response = await get('/card/$publicToken/pin');

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['pin'] as String? ?? '';
      } else {
        throw Exception(
            response['errstr'] ?? response['message'] ?? 'Failed to get PIN');
      }
    } catch (e) {
      print('Error getting PIN: $e');
      rethrow;
    }
  }

  /// 获取完整卡号
  /// [publicToken] 卡片唯一标识
  Future<Map<String, String>> getFullCardNumber(String publicToken) async {
    try {
      final response = await post(
        '/card/full-number',
        data: {'public_token': publicToken},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return {
          'card_number': data['card_number'] as String? ?? '',
          'cvv': data['cvv'] as String? ?? '',
        };
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get full card number');
      }
    } catch (e) {
      print('Error getting full card number: $e');
      rethrow;
    }
  }

  /// 修改卡片状态
  /// [publicToken] 卡片唯一标识
  /// [statusCode] 状态码：00激活，G1冻结（锁卡）
  Future<Map<String, dynamic>> modifyCardStatus(
      String publicToken, String statusCode) async {
    try {
      final response = await put(
        '/card/status',
        data: {
          'public_token': publicToken,
          'card_status_code': statusCode,
        },
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message'] ?? 'Failed to modify card status');
      }
    } catch (e) {
      print('Error modifying card status: $e');
      rethrow;
    }
  }
}
