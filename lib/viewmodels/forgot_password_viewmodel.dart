import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/reset_password_otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/forgot_password_response_model.dart';
import 'package:comecomepay/models/responses/reset_password_otp_verification_response_model.dart';

import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/utils/logger.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

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
  ResetPasswordOtpVerificationResponseModel? _otpResponse;

  ForgotPasswordResponseModel? get forgotPasswordResponse =>
      _forgotPasswordResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => busy;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ForgotPasswordResponseModel?> forgotPassword(
      String email, AppLocalizations l10n) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      Logger.businessLogic('forgotPassword', 'Email is empty');
      notifyListeners();
      return null;
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.pleaseEnterAValidEmailAddress;
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
      final response = await _globalService.forgotPassword(email);

      // response is already success Map because BaseService would throw otherwise
      _forgotPasswordResponse =
          ForgotPasswordResponseModel.fromJson({...response, 'email': email});
      setBusy(false);
      return _forgotPasswordResponse;
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      _forgotPasswordResponse = null;
      Logger.businessLogic('forgotPassword', 'Exception - ${e.toString()}');
      setBusy(false);
      return null;
    }
  }

  Future<ResetPasswordCreatePasswordResult> resetPasswordCreatePassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
    required AppLocalizations l10n,
  }) async {
    print('Email: $email, OTP: $otpCode, Password: $newPassword, Confirm: $confirmPassword');

    if (email.isEmpty || otpCode.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = l10n.allFieldsRequired;
      Logger.businessLogic('resetPasswordCreatePassword', 'Empty fields');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.pleaseEnterAValidEmailAddress;
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
      _errorMessage = l10n.passwordMustBeAtLeast8Characters;
      Logger.businessLogic('resetPasswordCreatePassword', 'Password too short');
      notifyListeners();
      return ResetPasswordCreatePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ResetPasswordCreatePasswordResponseType.error,
      );
    }

    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      _errorMessage = l10n.passwordMustContainUppercase;
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
      _errorMessage = l10n.passwordMustContainNumber;
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
      _errorMessage = l10n.passwordMustContainSpecial;
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
      _errorMessage = l10n.passwordsDoNotMatch;
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
          email, otpCode, newPassword, confirmPassword);

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
        _errorMessage = l10n.unexpectedError;
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
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
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

  Future<ResetPasswordOtpVerificationResponseModel?> verifyResetPasswordOtp(
      String email, String otpCode, AppLocalizations l10n) async {
    if (email.isEmpty || otpCode.isEmpty) {
      _errorMessage = l10n.allFieldsRequired;
      Logger.businessLogic('verifyResetPasswordOtp', 'Email or OTP is empty');
      notifyListeners();
      return null;
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.pleaseEnterAValidEmailAddress;
      Logger.businessLogic('verifyResetPasswordOtp', 'Invalid email format');
      notifyListeners();
      return null;
    }

    setBusy(true);
    _errorMessage = null;
    Logger.businessLogic(
        'verifyResetPasswordOtp', 'Verifying OTP for email: $email');

    try {
      final request = ResetPasswordOtpVerificationRequestModel(
        email: email,
        otpCode: otpCode,
      );

      final response = await _globalService.verifyResetPasswordOtp(request);

      // Success
      _otpResponse =
          ResetPasswordOtpVerificationResponseModel.fromJson(response);
      setBusy(false);
      return _otpResponse;
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      _otpResponse = null;
      Logger.businessLogic(
          'verifyResetPasswordOtp', 'Exception - ${e.toString()}');
      setBusy(false);
      return null;
    }
  }

  Future<bool> resendOtp(String email, AppLocalizations l10n) async {
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      Logger.businessLogic('resendOtp', 'Email is empty');
      notifyListeners();
      return false;
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.pleaseEnterAValidEmailAddress;
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
        _errorMessage = l10n.unexpectedError;
        Logger.businessLogic('resendOtp', 'Unexpected response - $response');
        setBusy(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      Logger.businessLogic('resendOtp', 'Exception - ${e.toString()}');
      setBusy(false);
      return false;
    }
  }

  // Method untuk send email
  Future<bool> sendEmail(String email, String name, String otp) async {
    try {
      final result = await _globalService.sendEmail(email, name, otp,
          isForgotPassword: true);
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
