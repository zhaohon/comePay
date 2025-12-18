import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/services/referral_service.dart';
import 'package:comecomepay/utils/logger.dart';

class InviteFriendViewModel extends BaseViewModel {
  final ReferralService _referralService = ReferralService();

  String invitationCode = '';
  String invitationLink = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<bool> inviteFriend() async {
    Logger.businessLogic('inviteFriend', 'Starting to invite friend');

    isLoading = true;
    errorMessage = '';
    notifyListeners();
    setBusy(true);
    try {
      final response = await _referralService.createReferral();
      if (response['code'] == 200) {
        final referralData = response['data'];
        invitationCode = referralData['referral_code'] ?? '';
        invitationLink = referralData['share_link'] ?? '';

        Logger.businessLogic('inviteFriend', 'Referral created successfully', data: {
          'invitationCode': invitationCode,
          'invitationLink': invitationLink,
        });
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to create referral');
      }
    } catch (e) {
      errorMessage = 'Failed to invite friend. Please try again.';
      Logger.businessLogic('inviteFriend', 'Failed to invite friend', data: {
        'error': e.toString(),
      });
      return false;
    } finally {
      setBusy(false);
      isLoading = false;
      notifyListeners();

      Logger.businessLogic('inviteFriend', 'Finished inviting friend');
    }
  }

  Future<void> loadReferral() async {
    Logger.businessLogic('loadReferral', 'Starting to load referral data');

    isLoading = true;
    errorMessage = '';
    notifyListeners();
    setBusy(true);
    try {
      final response = await _referralService.createReferral();
      if (response['code'] == 200) {
        final referralData = response['data'];
        invitationCode = referralData['referral_code'] ?? '';
        invitationLink = referralData['share_link'] ?? '';

        Logger.businessLogic('loadReferral', 'Referral data loaded successfully', data: {
          'invitationCode': invitationCode,
          'invitationLink': invitationLink,
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to create referral');
      }
    } catch (e) {
      errorMessage = 'Failed to load referral data. Please try again.';
      Logger.businessLogic('loadReferral', 'Failed to load referral data', data: {
        'error': e.toString(),
      });
      // Keep empty on error
    } finally {
      setBusy(false);
      isLoading = false;
      notifyListeners();

      Logger.businessLogic('loadReferral', 'Finished loading referral data');
    }
  }
}
