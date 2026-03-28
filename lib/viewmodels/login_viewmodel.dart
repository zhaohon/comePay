import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/login_request_model.dart';
import 'package:comecomepay/models/requests/otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/models/responses/otp_verification_response_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/service_locator.dart';

// Response types for different scenarios
class LoginResult {
  final bool success;
  final String? message;
  final LoginResponseType responseType;
  final String? otp;
  final String? email;

  LoginResult({
    required this.success,
    this.message,
    required this.responseType,
    this.otp,
    this.email,
  });
}

// Assuming VerifyOtpResult is an alias or identical to LoginResult for now,
// as the body returns LoginResult instances.
typedef VerifyOtpResult = LoginResult;

enum LoginResponseType {
  success,
  otpRequired,
  error,
}

class LoginViewModel extends BaseViewModel {
  final GlobalService _globalService = getIt<GlobalService>();

  // State variables
  bool _isPasswordVisible = false;
  String? _errorMessage;
  LoginResponseModel? _loginResponse;

  // Getters
  bool get isLoading => busy;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get errorMessage => _errorMessage;
  LoginResponseModel? get loginResponse => _loginResponse;

  // Setters
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Business logic methods
  Future<LoginResult> login(
      String email, String password, AppLocalizations l10n) async {
    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = l10n.allFieldsRequired;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = LoginRequestModel(email: email, password: password);

      // Call service
      final response = await _globalService.login(request);

      if (response is LoginSuccessResponse) {
        // Login berhasil
        _loginResponse = response.data;
        _errorMessage = null;

        // Simpan data authentication ke Hive
        await HiveStorageService.saveAuthData(response.data);

        setBusy(false);
        return LoginResult(
          success: true,
          responseType: LoginResponseType.success,
        );
      } else {
        // Harus LoginOtpRequiredResponse (karena jika error 400/500 sudah dilempar oleh BaseService)
        final otpResponse = response as LoginOtpRequiredResponse;
        _errorMessage = null;
        _loginResponse = null;

        // Send email with OTP if email and otp are available
        if (otpResponse.email != null && otpResponse.otp != null) {
          final name = otpResponse.name ?? otpResponse.email!.split('@').first;
          await _globalService.sendEmail(
              otpResponse.email!, name, otpResponse.otp!);
        }

        setBusy(false);
        return LoginResult(
          success: false,
          message: otpResponse.message,
          responseType: LoginResponseType.otpRequired,
          otp: otpResponse.otp,
          email: otpResponse.email,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      _loginResponse = null;
      setBusy(false);
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }
  }

  // Helper method untuk validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Method untuk logout (opsional)
  Future<void> logout() async {
    _loginResponse = null;
    _errorMessage = null;

    // Hapus data dari Hive
    await HiveStorageService.clearAuthData();

    notifyListeners();
  }

  // Method untuk check apakah user sudah login
  bool get isLoggedIn => _loginResponse != null;

  // Method untuk get user data
  UserModel? get currentUser => _loginResponse?.user;

  // Method untuk get access token
  String? get accessToken => _loginResponse?.accessToken;

  // Method untuk get refresh token
  String? get refreshToken => _loginResponse?.refreshToken;

  // Method untuk load authentication data dari Hive saat app start
  Future<void> loadAuthDataFromStorage() async {
    try {
      final authData = HiveStorageService.getAuthData();
      if (authData != null) {
        _loginResponse = authData;
        notifyListeners();
      }
    } catch (e) {
      // Jika gagal load dari storage, abaikan saja
      _loginResponse = null;
    }
  }

  // Method untuk check apakah ada data auth di storage
  bool get hasStoredAuthData => HiveStorageService.hasAuthData();

  // Method untuk get stored access token (untuk API calls)
  String? get storedAccessToken => HiveStorageService.getAccessToken();

  // Method untuk get stored refresh token
  String? get storedRefreshToken => HiveStorageService.getRefreshToken();

  // Method untuk get stored user data
  UserModel? get storedUser => HiveStorageService.getUser();

  // Method untuk OTP verification
  Future<VerifyOtpResult> verifyOtp(
      String email, String otpCode, AppLocalizations l10n) async {
    // Validasi input
    if (email.isEmpty || otpCode.isEmpty) {
      _errorMessage = l10n.allFieldsRequired;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (otpCode.length != 5) {
      _errorMessage = l10n.otpCodeMustBe5Digits;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    // Set loading state
    setBusy(true);
    _errorMessage = null;

    try {
      // Buat request model
      final request = OtpVerificationRequestModel(
          email: email, otpCode: otpCode.toString());

      // Call service
      final response = await _globalService.verifyOtp(request);

      // Success (BaseService handles failure by throwing)
      final otpResponse = response as OtpVerificationResponseModel;
      _loginResponse = LoginResponseModel(
        accessToken: otpResponse.accessToken,
        refreshToken: otpResponse.refreshToken,
        message: otpResponse.message,
        status: otpResponse.status,
        user: otpResponse.user,
      );
      _errorMessage = null;

      // Simpan data authentication ke Hive
      await HiveStorageService.saveAuthData(_loginResponse!);

      setBusy(false);
      return LoginResult(
        success: true,
        responseType: LoginResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _loginResponse = null;
      setBusy(false);
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }
  }

  // Method untuk resend OTP
  Future<LoginResult> resendOtp(String email, AppLocalizations l10n) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = l10n.emailCannotBeEmpty;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = l10n.invalidEmailFormat;
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
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
      return LoginResult(
        success: true,
        message: response['message'] ?? 'New OTP sent to your email',
        responseType: LoginResponseType.success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }
  }
}
