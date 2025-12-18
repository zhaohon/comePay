import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/responses/get_profile_response_model.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/models/requests/update_profile_request_model.dart';
import 'package:comecomepay/models/requests/didit_initialize_token_request_model.dart';
import 'package:comecomepay/models/responses/didit_initialize_token_response_model.dart';
import 'package:comecomepay/models/responses/didit_initialize_token_error_model.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:intl/intl.dart';

import '../models/carddetail_response_model.dart' show CarddetailResponseModel;

class ProfileScreenViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  GetProfileResponseModel? _profileResponse;
  String? _errorMessage;

  GetProfileResponseModel? get profileResponse => _profileResponse;
  String? get errorMessage => _errorMessage;

  Future<bool> getProfile(String accessToken) async {
    setBusy(true);
    _errorMessage = null;

    try {
      final response = await _globalService.getProfile(accessToken);

      if (response is Map<String, dynamic> && response['status'] == 'success') {
        _profileResponse = GetProfileResponseModel.fromJson(response);
        // Save to Hive in table "getprofil"
        await HiveStorageService.saveProfileData(_profileResponse!);
        setBusy(false);
        notifyListeners();
        return true;
      } else if (response is Map<String, dynamic> &&
          response['error'] != null) {
        _errorMessage = response['error'];
        setBusy(false);
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'Failed to get profile';
        setBusy(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Exception: ${e.toString()}';
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(UpdateProfileRequestModel request) async {
    setBusy(true);
    _errorMessage = null;

    try {
      final response = await _globalService.updateProfile(request);

      if (response is GetProfileResponseModel) {
        _profileResponse = response;
        // Save to Hive in table "getprofil"
        await HiveStorageService.saveProfileData(_profileResponse!);
        // Update the user in auth data with new values
        final currentAuth = HiveStorageService.getAuthData();
        if (currentAuth != null && currentAuth.user != null) {
          final updatedUser = UserModel(
            id: _profileResponse!.user.id,
            email: _profileResponse!.user.email,
            firstName: _profileResponse!.user.firstName,
            lastName: _profileResponse!.user.lastName,
            phone: _profileResponse!.user.phone ?? currentAuth.user!.phone,
            accountType: _profileResponse!.user.accountType,
            status: _profileResponse!.user.status,
            walletId: _profileResponse!.user.walletId,
            kycLevel: _profileResponse!.user.kycLevel,
            kycStatus: _profileResponse!.user.kycStatus,
            createdAt: _profileResponse!.user.createdAt,
            referralCode: _profileResponse!.user.referralCode,
          );
          final updatedAuth = LoginResponseModel(
            accessToken: currentAuth.accessToken,
            refreshToken: currentAuth.refreshToken,
            message: currentAuth.message,
            status: currentAuth.status,
            user: updatedUser,
          );
          await HiveStorageService.saveAuthData(updatedAuth);
        }
        setBusy(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update profile';
        setBusy(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Exception: ${e.toString()}';
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  String generateCustomUuid(String firstName, String lastName) {
  final now = DateTime.now();
  final timestamp = DateFormat('yyyyMMddHHmmss').format(now);
  return '${firstName.toUpperCase()}_${lastName.toUpperCase()}_$timestamp';
}

  Future<dynamic> initializeDiditToken([DiditInitializeTokenRequestModel? request]) async {
    setBusy(true);
    _errorMessage = null;

    try {
      DiditInitializeTokenRequestModel finalRequest;

      if (request != null) {
        // Use provided request from form data
        finalRequest = request;
      } else {
        // Fallback to original logic with Hive data
        final user = HiveStorageService.getUser();
        final profile = await HiveStorageService.getProfileData();

        if (user == null) {
          _errorMessage = 'User data not found';
          setBusy(false);
          notifyListeners();
          return null;
        }

        finalRequest = DiditInitializeTokenRequestModel(
          address: profile?.user.address ?? 'Default Address',
          agentUid: generateCustomUuid(user.firstName, user.lastName),
          areaCode: profile?.user.areaCode ?? '86',
          billCountryCode: profile?.user.billCountryCode ?? 'CN',
          city: profile?.user.city ?? 'Default City',
          email: user.email,
          firstEnName: user.firstName.toUpperCase() ?? 'JHON',
          lastEnName: user.lastName.toUpperCase() ?? 'DOE',
          phone: user.phone,
          postCode: profile?.user.postCode ?? '000000',
          returnUrl: 'https://yourapp.com/kyc/didit/callback',
          state: profile?.user.state ?? 'Default State',
        );
      }

      final response = await _globalService.initializeDiditToken(finalRequest);

      if (response is DiditInitializeTokenResponseModel) {
        setBusy(false);
        notifyListeners();
        return response;
      } else if (response is DiditInitializeTokenErrorModel) {
        _errorMessage = response.message;
        setBusy(false);
        notifyListeners();
        return null;
      } else {
        _errorMessage = 'Failed to initialize Didit token';
        setBusy(false);
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Exception: ${e.toString()}';
      setBusy(false);
      notifyListeners();
      return null;
    }
  }

  Future<CarddetailResponseModel?> getCardData(int kyc_id) async {
    try {
      final result = await _globalService.initGetCard(kyc_id);

      if (result != null && result.data != null) {
        return result;
      } else {
        return null;
      }

    } catch (e) {
      print('ViewModel: Failed to get card data: $e');
      return null;
    }
  }

  Future<bool> createCard(List<KycModel> kycData, GetProfileResponseModel profile) async {
    try {
      // Build card data from kycData and profile
      final cardData = {
        "area_code": profile.user.areaCode ?? "+1",
        "card_product_id": 1,
        "kyc_ids": kycData.map((kyc) => kyc?.id).where((id) => id != null).toList(), // e.g., [kycData[0].id]
        "phone": profile.user.phone ?? "",
        "physical": true,
        "postal_address": profile.user.address ?? "",
        "postal_city": profile.user.city ?? "",
        "postal_code": profile.user.postCode ?? "",
        "postal_country": profile.user.billCountryCode ?? "",
        "recipient": "${profile.user.firstName} ${profile.user.lastName}",
        "name_on_card": "${profile.user.firstName?.toUpperCase() ?? ''} ${profile.user.lastName?.toUpperCase() ?? ''}".trim()
      };

      final userId = profile.user.id.toString();
      final result = await _globalService.createCard(cardData, userId);

      if (result != null && result['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('ViewModel: Failed to create card: $e');
      return false;
    }
  }

}
