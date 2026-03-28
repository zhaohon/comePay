// import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/signup_request_model.dart';
import 'package:comecomepay/models/responses/signup_response_model.dart';
import 'package:comecomepay/models/requests/email_validation_request_model.dart';
import 'package:comecomepay/models/responses/email_validation_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Response types for different scenarios
class SignupResult {
  final bool success;
  final String? message;
  final SignupResponseType responseType;

  SignupResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum SignupResponseType {
  success,
  error,
}

class SignupViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  SignupResponseModel? _signupResponse;
  EmailValidationResponseModel? _emailValidationResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  SignupResponseModel? get signupResponse => _signupResponse;
  EmailValidationResponseModel? get emailValidationResponse =>
      _emailValidationResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<SignupResult> signup({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String accountType,
    required AppLocalizations l10n,
  }) async {
    // Validasi input
    if (email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        dateOfBirth.isEmpty) {
      _errorMessage = l10n.allFieldsRequired;
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }

    if (password.length < 6) {
      _errorMessage = l10n.passwordTooShort6;
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = SignupRequestModel(
        email: email.toString(),
        phone: phone.toString(),
        password: password.toString(),
        firstName: firstName.toString(),
        lastName: lastName.toString(),
        dateOfBirth: dateOfBirth.toString(),
        accountType: accountType.toString(),
      );

      // Call service
      final response = await _globalService.signup(request);

      // Success (BaseService handles failure by throwing)
      _signupResponse = response as SignupResponseModel;
      _errorMessage = null;

      setBusy(false);
      return SignupResult(
        success: true,
        message: _signupResponse!.message,
        responseType: SignupResponseType.success,
      );
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      _signupResponse = null;
      setBusy(false);
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Method untuk get signup data
  String? get otp => _signupResponse?.otp;
  String? get walletId => _signupResponse?.walletId;

  // Email validation method
  Future<SignupResult> validateEmail(String email, AppLocalizations l10n,
      {String? referralCode}) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = EmailValidationRequestModel(
        email: email,
        referralCode: referralCode,
      );

      // Call service
      final response = await _globalService.validateEmail(request);

      // Success
      _emailValidationResponse = response as EmailValidationResponseModel;
      _errorMessage = null;
      setBusy(false);
      notifyListeners();
      return SignupResult(
        success: true,
        message: _emailValidationResponse!.message,
        responseType: SignupResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return SignupResult(
        success: false,
        message: _errorMessage,
        responseType: SignupResponseType.error,
      );
    }
  }
}
