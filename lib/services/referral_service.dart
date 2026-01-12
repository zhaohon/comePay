import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/utils/logger.dart';

class ReferralService extends BaseService {
  /// Get referral code
  /// GET /user/referral-code
  Future<String> getReferralCode() async {
    try {
      final response = await get('/user/referral-code');
      if (response['status'] == 'success') {
        return response['referral_code'] ?? '';
      } else {
        throw Exception(response['message'] ?? 'Failed to get referral code');
      }
    } catch (e) {
      Logger.error(
          'getReferralCode', '/user/referral-code', e, StackTrace.current);
      rethrow;
    }
  }

  /// Get user tier info
  /// GET /user/tier
  Future<Map<String, dynamic>> getUserTier() async {
    try {
      final response = await get('/user/tier');
      if (response['status'] == 'success') {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to get user tier');
      }
    } catch (e) {
      Logger.error('getUserTier', '/user/tier', e, StackTrace.current);
      rethrow;
    }
  }

  /// Get user tier progress
  /// GET /user/tier/progress
  Future<Map<String, dynamic>> getUserTierProgress() async {
    try {
      final response = await get('/user/tier/progress');
      if (response['status'] == 'success') {
        return response['data'] ?? {};
      } else {
        throw Exception(
            response['message'] ?? 'Failed to get user tier progress');
      }
    } catch (e) {
      Logger.error(
          'getUserTierProgress', '/user/tier/progress', e, StackTrace.current);
      rethrow;
    }
  }

  /// Get all tier configs (for slider cards)
  /// GET /tier-configs
  Future<List<dynamic>> getTierConfigs() async {
    try {
      final response = await get('/tier-configs');
      if (response['status'] == 'success' && response['data'] != null) {
        return response['data']['configs'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to get tier configs');
      }
    } catch (e) {
      Logger.error('getTierConfigs', '/tier-configs', e, StackTrace.current);
      rethrow;
    }
  }

  /// Get referral stats (overview)
  /// GET /user/referral-stats
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await get('/user/referral-stats');
      if (response['status'] == 'success') {
        return response['stats'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to get referral stats');
      }
    } catch (e) {
      // Return empty stats if error, to allow UI to render zeros
      Logger.error(
          'getReferralStats', '/user/referral-stats', e, StackTrace.current);
      return {};
    }
  }

  /// Get referrals list
  /// GET /user/referrals
  /// level: 0=all, 1=level1, 2=level2
  Future<Map<String, dynamic>> getReferrals(
      {int level = 0, int page = 1, int pageSize = 20}) async {
    try {
      final response = await get('/user/referrals', queryParameters: {
        'level': level,
        'page': page,
        'page_size': pageSize,
        // 'start_date': ..., // Pending backend support
        // 'end_date': ...
      });
      if (response['status'] == 'success') {
        return {
          'referrals': response['referrals'] ?? [],
          'pagination': response['pagination'] ?? {}
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to get referrals');
      }
    } catch (e) {
      Logger.error('getReferrals', '/user/referrals', e, StackTrace.current);
      return {'referrals': [], 'pagination': {}};
    }
  }

  /// Get commissions history
  /// GET /user/commissions
  Future<Map<String, dynamic>> getCommissions(
      {int page = 1, int pageSize = 20, String? type, int? level}) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'page_size': pageSize,
        "commission_type": "transaction"
      };
      // These params are currently proposed in API Gap Analysis,
      // adding them now as placeholders or if backend implicitly supports them.
      if (type != null) params['type'] = type;
      if (level != null) params['level'] = level;

      final response = await get('/user/commissions', queryParameters: params);

      if (response['status'] == 'success') {
        // Mocking a 'summary' field if backend doesn't provide it yet,
        // so ViewModel can handle it or expected UI won't crash.
        return {
          'commissions': response['commissions'] ?? [],
          'pagination': response['pagination'] ?? {},
          'summary': response['summary'] // Proposed field
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to get commissions');
      }
    } catch (e) {
      Logger.error(
          'getCommissions', '/user/commissions', e, StackTrace.current);
      return {'commissions': [], 'pagination': {}};
    }
  }
}
