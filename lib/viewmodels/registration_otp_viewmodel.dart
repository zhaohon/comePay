// import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/registration_otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/registration_otp_verification_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Response types for different scenarios
class RegistrationOtpResult {
  final bool success;
  final String? message;
  final RegistrationOtpResponseType responseType;

  RegistrationOtpResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum RegistrationOtpResponseType {
  success,
  error,
}

class RegistrationOtpViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  RegistrationOtpVerificationResponseModel? _otpResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  RegistrationOtpVerificationResponseModel? get otpResponse => _otpResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<RegistrationOtpResult> resendOtp(
      String email, AppLocalizations l10n) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Call service
      final response = await _globalService.resendOtp(email);

      // Success
      _errorMessage = null;
      setBusy(false);
      return RegistrationOtpResult(
        success: true,
        message: response['message'] ?? 'New OTP sent to your email',
        responseType: RegistrationOtpResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }
  }

  // Business logic methods
  Future<RegistrationOtpResult> verifyRegistrationOtp({
    required String email,
    required String otpCode,
    required AppLocalizations l10n,
  }) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    if (otpCode.isEmpty || otpCode.length != 5) {
      _errorMessage = l10n.otpCodeMustBe5Digits;
      notifyListeners();
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = RegistrationOtpVerificationRequestModel(
        email: email,
        otpCode: otpCode,
      );

      // Call service
      final response = await _globalService.verifyRegistrationOtp(request);

      // Success
      _otpResponse = response as RegistrationOtpVerificationResponseModel;
      _errorMessage = null;

      setBusy(false);
      return RegistrationOtpResult(
        success: true,
        message: _otpResponse!.message,
        responseType: RegistrationOtpResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _otpResponse = null;
      setBusy(false);
      return RegistrationOtpResult(
        success: false,
        message: _errorMessage,
        responseType: RegistrationOtpResponseType.error,
      );
    }
  }
}
