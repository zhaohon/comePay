import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/change_phone_request_model.dart';
import 'package:comecomepay/models/responses/change_phone_response_model.dart';
import 'package:comecomepay/models/responses/change_phone_error_model.dart';
import 'package:comecomepay/models/requests/verify_new_phone_request_model.dart';
import 'package:comecomepay/models/responses/verify_new_phone_response_model.dart';
import 'package:comecomepay/models/requests/complete_change_phone_request_model.dart';
import 'package:comecomepay/models/responses/complete_change_phone_response_model.dart';
import 'package:comecomepay/models/responses/complete_change_phone_error_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

// Result types for change phone scenarios
class ChangePhoneResult {
  final bool success;
  final String? message;
  final ChangePhoneResponseType responseType;
  final String? newPhone;
  final String? otp;
  final String? nextStep;

  ChangePhoneResult({
    required this.success,
    this.message,
    required this.responseType,
    this.newPhone,
    this.otp,
    this.nextStep,
  });
}

enum ChangePhoneResponseType {
  success,
  error,
}

class BindPhoneViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;
  ChangePhoneResponseModel? _changePhoneResponse;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;
  ChangePhoneResponseModel? get changePhoneResponse => _changePhoneResponse;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<ChangePhoneResult> requestChangePhone(
      AppLocalizations l10n, String newPhone) async {
    // Validasi input
    if (newPhone.isEmpty) {
      _errorMessage = l10n.newPhoneCannotBeEmpty;
      notifyListeners();
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = ChangePhoneRequestModel(newPhone: newPhone);

      // Call service
      final response = await _globalService.changePhoneRequest(request);

      // Handle different response types
      if (response is ChangePhoneResponseModel) {
        // Change phone request berhasil
        _changePhoneResponse = response;
        _errorMessage = null;

        setBusy(false);
        return ChangePhoneResult(
          success: true,
          message: response.message,
          responseType: ChangePhoneResponseType.success,
          newPhone: response.newPhone,
          otp: response.otp,
          nextStep: response.nextStep,
        );
      } else if (response is ChangePhoneErrorModel) {
        // Change phone error
        _errorMessage = response.error;
        _changePhoneResponse = null;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: response.error,
          responseType: ChangePhoneResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = l10n.unexpectedResponse;
        _changePhoneResponse = null;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: _errorMessage,
          responseType: ChangePhoneResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      _changePhoneResponse = null;
      setBusy(false);
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }
  }

  // Method untuk verify new phone OTP
  Future<ChangePhoneResult> verifyNewPhoneOtp(AppLocalizations l10n,
      String email, String newPhone, String phoneOtp) async {
    // Validasi input
    if (email.isEmpty || newPhone.isEmpty || phoneOtp.isEmpty) {
      _errorMessage = l10n.emailPhoneOtpRequired;
      notifyListeners();
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = VerifyNewPhoneRequestModel(
        email: email,
        newPhone: newPhone,
        otpCode: phoneOtp,
      );

      // Call service
      final response = await _globalService.verifyNewPhone(request);

      // Handle different response types
      if (response is VerifyNewPhoneResponseModel) {
        // Verify new phone berhasil
        _errorMessage = null;

        setBusy(false);
        return ChangePhoneResult(
          success: true,
          message: response.message,
          responseType: ChangePhoneResponseType.success,
          otp: response.otp,
          nextStep: response.nextStep,
        );
      } else if (response is ChangePhoneErrorModel) {
        // Verify new phone error
        _errorMessage = response.error;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: response.error,
          responseType: ChangePhoneResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = l10n.unexpectedResponse;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: _errorMessage,
          responseType: ChangePhoneResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      setBusy(false);
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }
  }

  // Method untuk complete change phone
  Future<ChangePhoneResult> completeChangePhone(
      AppLocalizations l10n, String newPhone, String emailOtp) async {
    // Validasi input
    if (newPhone.isEmpty || emailOtp.isEmpty) {
      _errorMessage = l10n.newPhoneEmailOtpRequired;
      notifyListeners();
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = CompleteChangePhoneRequestModel(
        newPhone: newPhone,
        emailOtp: emailOtp,
      );

      // Call service
      final response = await _globalService.completeChangePhone(request);

      // Handle different response types
      if (response is CompleteChangePhoneResponseModel) {
        // Complete change phone berhasil
        _errorMessage = null;

        setBusy(false);
        return ChangePhoneResult(
          success: true,
          message: response.message,
          responseType: ChangePhoneResponseType.success,
          newPhone: response.phone,
        );
      } else if (response is CompleteChangePhoneErrorModel) {
        // Complete change phone error
        _errorMessage = response.error;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: response.error,
          responseType: ChangePhoneResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = l10n.unexpectedResponse;
        setBusy(false);
        return ChangePhoneResult(
          success: false,
          message: _errorMessage,
          responseType: ChangePhoneResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      return ChangePhoneResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePhoneResponseType.error,
      );
    }
  }

  // Method untuk reset state
  void reset() {
    _errorMessage = null;
    _changePhoneResponse = null;
    notifyListeners();
  }
}
