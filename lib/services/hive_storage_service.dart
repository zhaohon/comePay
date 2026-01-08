import 'package:hive/hive.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/models/responses/set_password_response_model.dart';
import 'package:comecomepay/models/responses/get_profile_response_model.dart';

class HiveStorageService {
  static const String _authBoxName = 'auth_box';
  static const String _authDataKey = 'auth_data';

  // Initialize Hive box
  static Future<void> init() async {
    try {
      await Hive.openBox(_authBoxName);
    } catch (e) {
      // If there's an error opening the box (likely due to model changes),
      // delete the box and recreate it
      await Hive.deleteBoxFromDisk(_authBoxName);
      await Hive.openBox(_authBoxName);
    }
  }

  // Get auth box instance
  static Box get _authBox => Hive.box(_authBoxName);

  // Save authentication data
  static Future<void> saveAuthData(LoginResponseModel authData) async {
    try {
      await _authBox.put(_authDataKey, authData);
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
  }

  // Get authentication data
  static LoginResponseModel? getAuthData() {
    try {
      final data = _authBox.get(_authDataKey);
      return data;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in (has valid auth data)
  static bool isLoggedIn() {
    try {
      final authData = getAuthData();
      return authData != null &&
          authData.accessToken.isNotEmpty &&
          authData.refreshToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get access token
  static String? getAccessToken() {
    try {
      final authData = getAuthData();
      return authData?.accessToken;
    } catch (e) {
      return null;
    }
  }

  // Get refresh token
  static String? getRefreshToken() {
    try {
      final authData = getAuthData();
      return authData?.refreshToken;
    } catch (e) {
      return null;
    }
  }

  // Get user data
  static UserModel? getUser() {
    try {
      final authData = getAuthData();
      return authData?.user;
    } catch (e) {
      return null;
    }
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      await _authBox.delete(_authDataKey);
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }

  // Clear all profile data
  static Future<void> clearProfileData() async {
    try {
      var box = await Hive.openBox(_profileBoxName);
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear profile data: $e');
    }
  }

  // Clear all data (auth and profile)
  static Future<void> clearAllData() async {
    try {
      await clearAuthData();
      await clearProfileData();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  // Check if auth data exists (even if tokens might be expired)
  static bool hasAuthData() {
    try {
      final authData = getAuthData();
      return authData != null;
    } catch (e) {
      return false;
    }
  }

  // Update only tokens (keep user data)
  static Future<void> updateTokens(
      String accessToken, String refreshToken) async {
    try {
      final currentAuthData = getAuthData();
      if (currentAuthData != null) {
        final updatedAuthData = LoginResponseModel(
          accessToken: accessToken,
          refreshToken: refreshToken,
          message: currentAuthData.message,
          status: currentAuthData.status,
          user: currentAuthData.user,
        );
        await saveAuthData(updatedAuthData);
      }
    } catch (e) {
      throw Exception('Failed to update tokens: $e');
    }
  }

  // Save set password authentication data
  static Future<void> saveSetPasswordAuthData(
      SetPasswordResponseModel authData) async {
    try {
      await _authBox.put(_authDataKey, authData);
    } catch (e) {
      throw Exception('Failed to save set password auth data: $e');
    }
  }

  // Save profile data to Hive in a new box/table "getprofil"
  static const String _profileBoxName = 'getprofil';
  static const String _profileDataKey = 'profile_data';

  static Future<void> saveProfileData(
      GetProfileResponseModel profileData) async {
    try {
      var box = await Hive.openBox(_profileBoxName);
      await box.put(_profileDataKey, profileData.toJson());
    } catch (e) {
      throw Exception('Failed to save profile data: $e');
    }
  }

  static Future<GetProfileResponseModel?> getProfileData() async {
    try {
      var box = await Hive.openBox(_profileBoxName);
      final data = box.get(_profileDataKey);
      if (data != null) {
        return GetProfileResponseModel.fromJson(
            Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Save temp hash for transaction password
  static const String _tempHashKey = 'temp_hash';

  static Future<void> saveTempHash(String tempHash) async {
    try {
      await _authBox.put(_tempHashKey, tempHash);
    } catch (e) {
      throw Exception('Failed to save temp hash: $e');
    }
  }

  // Get temp hash
  static String? getTempHash() {
    try {
      return _authBox.get(_tempHashKey);
    } catch (e) {
      return null;
    }
  }

  // Clear temp hash
  static Future<void> clearTempHash() async {
    try {
      await _authBox.delete(_tempHashKey);
    } catch (e) {
      throw Exception('Failed to clear temp hash: $e');
    }
  }

  // Get combined user data from auth and profile
  static Future<Map<String, dynamic>?> getCombinedUserData() async {
    try {
      final user = getUser();
      final profile = await getProfileData();

      if (user == null) return null;

      final combined = {
        'id': user.id,
        'email': user.email,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phone': user.phone,
        'accountType': user.accountType,
        'status': user.status,
        'walletId': user.walletId,
        'kycLevel': user.kycLevel,
        'kycStatus': user.kycStatus,
        'createdAt': user.createdAt,
        'referralCode': user.referralCode,
        // Extended from profile
        'address': profile?.user.address ?? 'Default Address',
        'areaCode': profile?.user.areaCode ?? '86',
        'billCountryCode': profile?.user.billCountryCode ?? 'CN',
        'city': profile?.user.city ?? 'Default City',
        'postCode': profile?.user.postCode ?? '000000',
        'state': profile?.user.state ?? 'Default State',
        'dateOfBirth': profile?.user.dateOfBirth,
        'isActive': profile?.user.isActive ?? true,
        'referredBy': profile?.user.referredBy ?? '',
        'twoFactorEnabled': profile?.user.twoFactorEnabled ?? false,
        'updatedAt': profile?.user.updatedAt,
      };

      return combined;
    } catch (e) {
      return null;
    }
  }

  // Version update dialog state management
  static const String _versionDialogShownKey = 'version_dialog_shown';

  /// 保存版本更新弹窗显示状态
  static Future<void> saveVersionDialogShown(bool shown) async {
    try {
      await _authBox.put(_versionDialogShownKey, shown);
    } catch (e) {
      throw Exception('Failed to save version dialog shown state: $e');
    }
  }

  /// 获取版本更新弹窗显示状态
  static bool getVersionDialogShown() {
    try {
      return _authBox.get(_versionDialogShownKey, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// 清除版本更新弹窗显示状态（应用重启时调用）
  static Future<void> clearVersionDialogShown() async {
    try {
      await _authBox.delete(_versionDialogShownKey);
    } catch (e) {
      throw Exception('Failed to clear version dialog shown state: $e');
    }
  }
}
