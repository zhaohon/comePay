import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:comecomepay/models/card_apply_progress_model.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';

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
      final response = await get(
        '/card/pin',
        queryParameters: {'public_token': publicToken},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['pin'] as String? ?? '';
      } else {
        throw Exception(response['message'] ?? 'Failed to get PIN');
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
}
