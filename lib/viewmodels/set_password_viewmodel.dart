import 'package:flutter/material.dart';
import 'package:Demo/core/base_viewmodel.dart';
import 'package:Demo/models/responses/set_password_response_model.dart';
import 'package:Demo/models/responses/login_response_model.dart';
import 'package:Demo/services/global_service.dart';
import 'package:Demo/services/hive_storage_service.dart';
import 'package:Demo/utils/service_locator.dart';

// Response types for set password
class SetPasswordResult {
  final bool success;
  final String? message;
  final SetPasswordResponseType responseType;

  SetPasswordResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum SetPasswordResponseType {
  success,
  error,
}

class SetPasswordViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  SetPasswordResponseModel? _setPasswordResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  SetPasswordResponseModel? get setPasswordResponse => _setPasswordResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<SetPasswordResult> setPassword({
    required String email,
    required String password,
  }) async {
    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email and password cannot be empty';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Invalid email format';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    if (password.length < 8) {
      _errorMessage = 'Password must be at least 8 characters long';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage = 'Password must contain an uppercase letter';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage = 'Password must contain a number';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _errorMessage = 'Password must contain a special character';
      notifyListeners();
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Call service
      final response = await _globalService.setPassword(email, password);

      // Handle different response types
      if (response is SetPasswordResponseModel) {
        // Set password berhasil
        _setPasswordResponse = response;
        _errorMessage = null;

        print('Raw Users : ${response.user.toJson()}');

        // Simpan data authentication ke Hive seperti login
        final rawUser = UserModel.fromJson(response.user.toJson());

        final modifiedUser = UserModel(
          id: rawUser.id,
          email: rawUser.email,
          firstName:
              rawUser.firstName?.isEmpty ?? true ? '' : rawUser.firstName ?? '',
          lastName:
              rawUser.lastName?.isEmpty ?? true ? '' : rawUser.lastName ?? '',
          phone: rawUser.phone ?? '',
          status: rawUser.status ?? '',
          walletId: rawUser.walletId ?? '',
          kycLevel: rawUser.kycLevel ?? 0,
          kycStatus: rawUser.kycStatus ?? '',
          createdAt: rawUser.createdAt ?? DateTime.now(),
          accountType: rawUser.accountType ?? '',
          referralCode: rawUser.referralCode ?? '',
        );
        final loginResponse = LoginResponseModel(
          accessToken: response.accessToken ?? '',
          refreshToken: response.refreshToken ?? '',
          message: response.message ?? '',
          status: response.status ?? '',
          user: modifiedUser,
        );
        print('Saving login response to Hive: $loginResponse');
        await HiveStorageService.saveAuthData(loginResponse);

        setBusy(false);
        return SetPasswordResult(
          success: true,
          message: response.message,
          responseType: SetPasswordResponseType.success,
        );
      } else if (response is SetPasswordErrorModel) {
        // Set password error
        _errorMessage = response.error;
        _setPasswordResponse = null;
        setBusy(false);
        return SetPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: SetPasswordResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'An unexpected error occurred';
        _setPasswordResponse = null;
        setBusy(false);
        return SetPasswordResult(
          success: false,
          message: _errorMessage,
          responseType: SetPasswordResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _setPasswordResponse = null;
      setBusy(false);
      return SetPasswordResult(
        success: false,
        message: _errorMessage,
        responseType: SetPasswordResponseType.error,
      );
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Method untuk get set password data
  String? get accessToken => _setPasswordResponse?.accessToken;
  String? get refreshToken => _setPasswordResponse?.refreshToken;
  String? get nextStep => _setPasswordResponse?.nextStep;
}
