import 'package:comecomepay/core/base_service.dart';

class ReferralService extends BaseService {
  /// Get referral code
  Future<String> getReferralCode() async {
    final response = await get('/user/referral-code');
    return response['referral_code'] ?? '';
  }

  /// Get user tier info
  Future<Map<String, dynamic>> getUserTier() async {
    final response = await get('/user/tier');
    return response['data'] ?? {};
  }

  /// Get user tier progress
  Future<Map<String, dynamic>> getUserTierProgress() async {
    final response = await get('/user/tier/progress');
    return response['data'] ?? {};
  }

  /// Get all tier configs (for slider cards)
  Future<List<dynamic>> getTierConfigs() async {
    final response = await get('/tier-configs');
    return response['data']?['configs'] ?? [];
  }

  /// Get referral stats (overview)
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await get('/user/referral-stats');
      return response['stats'] ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Get referrals list
  Future<Map<String, dynamic>> getReferrals(
      {int level = 0, int page = 1, int pageSize = 20}) async {
    try {
      final response = await get('/user/referrals', queryParameters: {
        'level': level,
        'page': page,
        'page_size': pageSize,
      });
      return {
        'referrals': response['referrals'] ?? [],
        'pagination': response['pagination'] ?? {}
      };
    } catch (e) {
      return {'referrals': [], 'pagination': {}};
    }
  }

  /// Get commissions history
  Future<Map<String, dynamic>> getCommissions(
      {int page = 1, int pageSize = 20, String? type, int? level}) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'page_size': pageSize,
      };
      if (type != null) params['type'] = type;
      if (level != null) params['level'] = level;

      final response = await get('/user/commissions', queryParameters: params);

      return {
        'commissions': response['commissions'] ?? [],
        'pagination': response['pagination'] ?? {},
      };
    } catch (e) {
      return {'commissions': [], 'pagination': {}};
    }
  }
}
