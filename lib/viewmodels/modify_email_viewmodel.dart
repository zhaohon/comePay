import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/change_email_request_model.dart';
import 'package:comecomepay/models/responses/change_email_response_model.dart';
import 'package:comecomepay/models/requests/verify_new_email_request_model.dart';
import 'package:comecomepay/models/responses/verify_new_email_response_model.dart';
import 'package:comecomepay/models/requests/complete_change_email_request_model.dart';
import 'package:comecomepay/models/responses/complete_change_email_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

// Result types for change email scenarios
class ChangeEmailResult {
  final bool success;
  final String? message;
  final ChangeEmailResponseType responseType;
  final String? newEmail;
  final String? otp;
  final String? nextStep;

  ChangeEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.newEmail,
    this.otp,
    this.nextStep,
  });
}

enum ChangeEmailResponseType {
  success,
  otpSent,
  error,
}

class VerifyNewEmailResult {
  final bool success;
  final String? message;
  final VerifyNewEmailResponseType responseType;
  final String? currentEmail;
  final String? otp;
  final String? nextStep;

  VerifyNewEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.currentEmail,
    this.otp,
    this.nextStep,
  });
}

enum VerifyNewEmailResponseType {
  success,
  otpSentToCurrent,
  error,
}

class CompleteChangeEmailResult {
  final bool success;
  final String? message;
  final CompleteChangeEmailResponseType responseType;
  final String? newEmail;

  CompleteChangeEmailResult({
    required this.success,
    this.message,
    required this.responseType,
    this.newEmail,
  });
}

enum CompleteChangeEmailResponseType {
  success,
  error,
}

class ModifyEmailViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  ChangeEmailResponseModel? _changeEmailResponse;
  bool _isEmailValid = false;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  ChangeEmailResponseModel? get changeEmailResponse => _changeEmailResponse;
  bool get isEmailValid => _isEmailValid;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<ChangeEmailResult> requestChangeEmail(
      String newEmail, AppLocalizations l10n) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = l10n.newEmailCannotBeEmpty;
      notifyListeners();
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;
    _isEmailValid = true;

    try {
      final request = ChangeEmailRequestModel(newEmail: newEmail);
      final response = await _globalService.changeEmail(request);

      // Success
      _changeEmailResponse = response as ChangeEmailResponseModel;
      setBusy(false);
      return ChangeEmailResult(
        success: true,
        message: _changeEmailResponse!.message,
        responseType: ChangeEmailResponseType.otpSent,
        newEmail: _changeEmailResponse!.newEmail,
        otp: _changeEmailResponse!.otp,
        nextStep: _changeEmailResponse!.nextStep,
      );
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      return ChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: ChangeEmailResponseType.error,
      );
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Method untuk validate email on change
  void validateEmail(String email) {
    _isEmailValid = isValidEmail(email) && email.isNotEmpty;
    notifyListeners();
  }

  // Method untuk reset state
  void reset() {
    _errorMessage = null;
    _changeEmailResponse = null;
    _isEmailValid = false;
    notifyListeners();
  }

  // Business logic methods for verify new email OTP
  Future<VerifyNewEmailResult> verifyNewEmailOtp(
      String newEmail, String otpCode, AppLocalizations l10n) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = l10n.newEmailCannotBeEmpty;
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (otpCode.isEmpty) {
      _errorMessage = l10n.otpCodeCannotBeEmpty;
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    if (otpCode.length != 5) {
      _errorMessage = l10n.otpCodeMustBe5Digits;
      notifyListeners();
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      final request = VerifyNewEmailRequestModel(
        newEmail: newEmail,
        otpCode: otpCode,
      );

      final response = await _globalService.verifyNewEmail(request);

      // Success
      final verifyResponse = response as VerifyNewEmailResponseModel;
      setBusy(false);
      return VerifyNewEmailResult(
        success: true,
        message: verifyResponse.message,
        responseType: VerifyNewEmailResponseType.otpSentToCurrent,
        currentEmail: verifyResponse.currentEmail,
        otp: verifyResponse.otp,
        nextStep: verifyResponse.nextStep,
      );
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      return VerifyNewEmailResult(
        success: false,
        message: _errorMessage,
        responseType: VerifyNewEmailResponseType.error,
      );
    }
  }

  // Business logic methods for complete change email
  Future<CompleteChangeEmailResult> completeChangeEmail(
      String newEmail, String oldEmailOtp, AppLocalizations l10n) async {
    // Validasi input
    if (newEmail.isEmpty) {
      _errorMessage = l10n.newEmailCannotBeEmpty;
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
        newEmail: null,
      );
    }

    if (!isValidEmail(newEmail)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
        newEmail: null,
      );
    }

    if (oldEmailOtp.isEmpty) {
      _errorMessage = l10n.oldEmailOtpCannotBeEmpty;
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
        newEmail: null,
      );
    }

    if (oldEmailOtp.length != 5) {
      _errorMessage = l10n.otpCodeMustBe5Digits;
      notifyListeners();
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
        newEmail: null,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      final request = CompleteChangeEmailRequestModel(
        newEmail: newEmail,
        oldEmailOtp: oldEmailOtp,
      );

      final response = await _globalService.completeChangeEmail(request);

      // Success
      final completeResponse = response as CompleteChangeEmailResponseModel;
      setBusy(false);
      return CompleteChangeEmailResult(
        success: true,
        message: completeResponse.message,
        responseType: CompleteChangeEmailResponseType.success,
        newEmail: completeResponse.newEmail,
      );
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      setBusy(false);
      return CompleteChangeEmailResult(
        success: false,
        message: _errorMessage,
        responseType: CompleteChangeEmailResponseType.error,
        newEmail: null,
      );
    }
  }
}
