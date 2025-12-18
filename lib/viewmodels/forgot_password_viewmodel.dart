import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/reset_password_otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/forgot_password_response_model.dart';
import 'package:comecomepay/models/responses/forgot_password_error_model.dart';
import 'package:comecomepay/models/responses/reset_password_otp_verification_response_model.dart';

import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/utils/logger.dart';

enum ResetPasswordCreatePasswordResponseType {
  success,
  error,
}

class ResetPasswordCreatePasswordResult {
  final bool success;
  final String? message;
  final ResetPasswordCreatePasswordResponseType responseType;

  ResetPasswordCreatePasswordResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

class ForgotPasswordViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  ForgotPasswordResponseModel? _forgotPasswordResponse;
  String? _errorMessage;

  ForgotPasswordResponseModel? get forgotPasswordResponse =>
      _forgotPasswordResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => busy;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ForgotPasswordResponseModel?> forgotPassword(String email) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      Logger.businessLogic('forgotPassword', 'Email is empty');
      notifyListeners();
      return null;
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
      Logger.businessLogic('forgotPassword', 'Invalid email format');
      notifyListeners();
      return null;
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;
    Logger.businessLogic(
        'forgotPassword', 'Starting forgot password for email: $email');

    try {
      // Call service with email string directly
      final response = await _globalService.forgotPassword(email);

      // Handle different response types
      if (response is Map &&
          response.containsKey('status') &&
          response['status'] == 'success') {
        // Forgot password berhasil
        _forgotPasswordResponse = ForgotPasswordResponseModel(
          email: email,
          message: response['message'] ?? 'Password reset email sent',
          otp: response['otp'] ?? '',
          status: 'success',
          name: response['name'],
        );
        _errorMessage = null;
        Logger.businessLogic(
            'forgotPassword', 'Success - ${response['message']}');
        setBusy(false);
        return _forgotPasswordResponse;
      } else if (response is ForgotPasswordErrorModel) {
        // Forgot password gagal
        _errorMessage = response.error;
        _forgotPasswordResponse = null;
        Logger.businessLogic('forgotPassword', 'Error - ${response.error}');
        setBusy(false);
        return null;
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _forgotPasswordResponse = null;
        Logger.businessLogic(
            'forgotPassword', 'Unexpected response - $response');
        setBusy(false);
        return null;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _forgotPasswordResponse = null;
      Logger.businessLogic('forgotPassword', 'Exception - ${e.toString()}');
      setBusy(false);
      return null;
    }
  }

  Future<ResetPasswordCreatePasswordResult> resetPasswordCreatePassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('Email: $email, Password: $newPassword, Confirm: $confirmPassword');

    if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Email and passwords cannot be empty';
      Logger.businessLogic('resetPasswordCreatePassword', 'Empty fields');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Invalid email format';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Invalid email format');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (newPassword.length < 8) {
      _errorMessage = 'Password must be at least 8 characters long';
      Logger.businessLogic('resetPasswordCreatePassword', 'Password too short');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      _errorMessage = 'Password must contain an uppercase letter';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Password missing uppercase');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      _errorMessage = 'Password must contain a number';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Password missing number');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!newPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _errorMessage = 'Password must contain a special character';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Password missing special character');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Passwords do not match');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    setBusy(true);
    _errorMessage = null;
    Logger.businessLogic('resetPasswordCreatePassword',
        'Starting password reset for email: $email');

    try {
      final response = await _globalService.resetPasswordCreatePassword(
          email, newPassword, confirmPassword);

      if (response is Map &&
          response.containsKey('status') &&
          response['status'] == 'success') {
        Logger.businessLogic(
            'resetPasswordCreatePassword', 'Password reset successful');
        setBusy(false);
        return ResetPasswordCreatePasswordResult(
          success: true,
          message: response['message'] ?? 'Password reset successful',
          responseType: ResetPasswordCreatePasswordResponseType.success,
        );
      } else if (response is Map && response.containsKey('error')) {
        _errorMessage = response['error'];
        Logger.businessLogic(
            'resetPasswordCreatePassword', 'Error - $_errorMessage');
        setBusy(false);
        return ResetPasswordCreatePasswordResult(
          success: false,
          message: _errorMessage,
          responseType: ResetPasswordCreatePasswordResponseType.error,
        );
      } else {
        _errorMessage = 'Unexpected error occurred';
        Logger.businessLogic(
            'resetPasswordCreatePassword', 'Unexpected response - $response');
        setBusy(false);
        return ResetPasswordCreatePasswordResult(
          success: false,
          message: _errorMessage,
          responseType: ResetPasswordCreatePasswordResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Exception: ${e.toString()}';
      Logger.businessLogic(
          'resetPasswordCreatePassword', 'Exception - $_errorMessage');
      setBusy(false);
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }
  }

  Future<bool> verifyResetPasswordOtp(String email, String otpCode) async {
    if (email.isEmpty || otpCode.isEmpty) {
      _errorMessage = 'Email dan OTP tidak boleh kosong';
      Logger.businessLogic('verifyResetPasswordOtp', 'Email or OTP is empty');
      notifyListeners();
      return false;
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
      Logger.businessLogic('verifyResetPasswordOtp', 'Invalid email format');
      notifyListeners();
      return false;
    }

    setBusy(true);
    _errorMessage = null;
    Logger.businessLogic(
        'verifyResetPasswordOtp', 'Verifying OTP for email: $email');

    try {
      final requestModel = ResetPasswordOtpVerificationRequestModel(
        email: email,
        otpCode: otpCode,
      );

      final response =
          await _globalService.verifyResetPasswordOtp(requestModel);

      if (response is Map && response.containsKey('status')) {
        final otpResponse = ResetPasswordOtpVerificationResponseModel.fromJson(
            response as Map<String, dynamic>);

        if (otpResponse.status == 'success') {
          _errorMessage = null;
          Logger.businessLogic(
              'verifyResetPasswordOtp', 'OTP verification success');
          setBusy(false);
          return true;
        } else {
          _errorMessage = otpResponse.error ?? 'OTP verification failed';
          Logger.businessLogic('verifyResetPasswordOtp',
              'OTP verification failed: $_errorMessage');
          setBusy(false);
          return false;
        }
      } else {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        Logger.businessLogic(
            'verifyResetPasswordOtp', 'Unexpected response - $response');
        setBusy(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      Logger.businessLogic(
          'verifyResetPasswordOtp', 'Exception - ${e.toString()}');
      setBusy(false);
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      Logger.businessLogic('resendOtp', 'Email is empty');
      notifyListeners();
      return false;
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
      Logger.businessLogic('resendOtp', 'Invalid email format');
      notifyListeners();
      return false;
    }

    setBusy(true);
    _errorMessage = null;
    Logger.businessLogic('resendOtp', 'Resending OTP for email: $email');

    try {
      final response = await _globalService.resendOtp(email);

      if (response is Map<String, dynamic> && response['status'] == 'success') {
        _errorMessage = null;
        Logger.businessLogic('resendOtp', 'OTP resent successfully');
        setBusy(false);
        return true;
      } else if (response is Map<String, dynamic> &&
          response['error'] != null) {
        _errorMessage = response['error'];
        Logger.businessLogic(
            'resendOtp', 'Failed to resend OTP: $_errorMessage');
        setBusy(false);
        return false;
      } else {
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        Logger.businessLogic('resendOtp', 'Unexpected response - $response');
        setBusy(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      Logger.businessLogic('resendOtp', 'Exception - ${e.toString()}');
      setBusy(false);
      return false;
    }
  }

  // Method untuk send email
  Future<bool> sendEmail(String email, String name, String otp) async {
    try {
      final result = await _globalService.sendEmail(email, name, otp);
      return result;
    } catch (e) {
      Logger.businessLogic('sendEmail', 'Exception - ${e.toString()}');
      return false;
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
