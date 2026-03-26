import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/models/requests/change_password_request_model.dart';
import 'package:comecomepay/models/responses/change_password_response_model.dart';
import 'package:comecomepay/models/responses/change_password_error_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Result types for change password scenarios
class ChangePasswordResult {
  final bool success;
  final String? message;
  final ChangePasswordResponseType responseType;

  ChangePasswordResult({
    required this.success,
    this.message,
    required this.responseType,
  });
}

enum ChangePasswordResponseType {
  success,
  error,
}

class ModifyPasswordViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  String? _errorMessage;

  // Getters
  bool get isLoading => busy;
  String? get errorMessage => _errorMessage;

  // Setters
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<ChangePasswordResult> changePassword(AppLocalizations l10n,
      String oldPassword, String newPassword, String confirmPassword) async {
    // Validasi input
    if (oldPassword.isEmpty) {
      _errorMessage = l10n.oldPasswordCannotBeEmpty;
      notifyListeners();
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }

    if (newPassword.isEmpty) {
      _errorMessage = l10n.newPasswordCannotBeEmpty;
      notifyListeners();
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }

    if (confirmPassword.isEmpty) {
      _errorMessage = l10n.confirmPasswordCannotBeEmpty;
      notifyListeners();
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }

    if (newPassword != confirmPassword) {
      _errorMessage = l10n.passwordsDoNotMatch;
      notifyListeners();
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }

    if (newPassword.length < 8) {
      _errorMessage = l10n.passwordMustBeAtLeast8Characters;
      notifyListeners();
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = ChangePasswordRequestModel(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Call service
      final response = await _globalService.changePassword(request);

      // Handle different response types
      if (response is ChangePasswordResponseModel) {
        // Change password berhasil
        _errorMessage = null;

        setBusy(false);
        return ChangePasswordResult(
          success: true,
          message: response.message,
          responseType: ChangePasswordResponseType.success,
        );
      } else if (response is ChangePasswordErrorModel) {
        // Change password error
        _errorMessage = response.error;
        setBusy(false);
        return ChangePasswordResult(
          success: false,
          message: response.error,
          responseType: ChangePasswordResponseType.error,
        );
      } else if (response is Map<String, dynamic>) {
        // Handle raw response if needed
        if (response['status'] == 'success') {
          _errorMessage = null;
          setBusy(false);
          return ChangePasswordResult(
            success: true,
            message: response['message'],
            responseType: ChangePasswordResponseType.success,
          );
        } else {
          _errorMessage = response['error'] ?? l10n.changePasswordFailed;
          setBusy(false);
          return ChangePasswordResult(
            success: false,
            message: _errorMessage,
            responseType: ChangePasswordResponseType.error,
          );
        }
      } else {
        // Unexpected response
        _errorMessage = l10n.unexpectedError;
        setBusy(false);
        return ChangePasswordResult(
          success: false,
          message: _errorMessage,
          responseType: ChangePasswordResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = l10n.errorOccurredWithDetails(e.toString());
      setBusy(false);
      return ChangePasswordResult(
        success: false,
        message: _errorMessage,
        responseType: ChangePasswordResponseType.error,
      );
    }
  }

  // Method untuk reset state
  void reset() {
    _errorMessage = null;
    notifyListeners();
  }
}
