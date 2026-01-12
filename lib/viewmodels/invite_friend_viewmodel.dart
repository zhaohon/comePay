import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/services/referral_service.dart';
import 'package:comecomepay/utils/logger.dart';
import 'package:flutter/services.dart';

class InviteFriendViewModel extends BaseViewModel {
  final ReferralService _referralService = ReferralService();

  String referralCode = '';
  // share_link is not used in the new design according to the screenshot dialog,
  // but we might need it for the copy link function.
  // The API doesn't seem to return a specific "share link" in getReferralCode directly in the doc
  // but we can construct it or get it if the API supports it.
  // Based on the previous code, there was a share_link.
  // Let's assume we construct it or use what's available.
  // Wait, previous code got share_link from createReferral.
  // The new Plan uses getReferralCode. The doc for getReferralCode only returns referral_code.
  // However, I can use the base URL + referral code or just keep it empty if not provided.
  // The user asked for "Invitation Links" copy button.
  // I will check if getReferralCode response has more data or if I need to construct it.
  // For now, I will store what I get.

  // Actually, the new service method getReferralCode only returns String.
  // I should probably change the service to return the map if I need more data.
  // But the doc says: GET /user/referral-code returns { "referral_code": "ABC123", "status": "success" }
  // So likely the link needs to be constructed.
  // I'll add a helper to construct the link.

  Map<String, dynamic> userTier = {};
  Map<String, dynamic> tierProgress = {};
  List<dynamic> tierConfigs = [];

  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadData() async {
    Logger.businessLogic('InviteFriendViewModel', 'Starting to load all data');

    isLoading = true;
    errorMessage = '';
    notifyListeners();
    setBusy(true);

    try {
      // Execute in parallel
      final results = await Future.wait([
        _referralService.getReferralCode(),
        _referralService.getUserTier(),
        _referralService.getUserTierProgress(),
        _referralService.getTierConfigs(),
      ]);

      referralCode = results[0] as String;
      userTier = results[1] as Map<String, dynamic>;
      tierProgress = results[2] as Map<String, dynamic>;
      tierConfigs = results[3] as List<dynamic>;

      Logger.businessLogic('InviteFriendViewModel', 'Data loaded successfully');
    } catch (e) {
      errorMessage = 'Failed to load data. Please check your network.';
      Logger.businessLogic('InviteFriendViewModel', 'Failed to load data',
          data: {
            'error': e.toString(),
          });
    } finally {
      setBusy(false);
      isLoading = false;
      notifyListeners();
    }
  }

  String getReferralLink() {
    // Assuming a standard format if not provided by backend.
    // Adjust domain as needed or if config provides it.
    return "https://comecomepay.com/register?ref=$referralCode";
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Logger.businessLogic('InviteFriendViewModel', 'Copied to clipboard: $text');
  }
}
