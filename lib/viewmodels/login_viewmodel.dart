import 'package:flutter/material.dart';
import 'package:comecomepay/core/base_viewmodel.dart';
import 'package:comecomepay/models/requests/login_request_model.dart';
import 'package:comecomepay/models/requests/otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/models/responses/login_error_model.dart';
import 'package:comecomepay/models/responses/otp_verification_response_model.dart';
import 'package:comecomepay/models/responses/otp_verification_error_model.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
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
  Future<LoginResult> login(String email, String password) async {
    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan password tidak boleh kosong';
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
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

      // Handle different response types
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
      } else if (response is LoginOtpRequiredResponse) {
        // OTP required (HTTP 403)
        _errorMessage = null;
        _loginResponse = null;

        // Send email with OTP if email and otp are available
        print('🔥 [LOGIN VIEWMODEL] About to send email with OTP...');
        print(
            '🔥 [LOGIN VIEWMODEL] Name: ${response.name}, Email: ${response.email}, OTP: ${response.otp}');
        if (response.email != null && response.otp != null) {
          print(
              '🔥 [LOGIN VIEWMODEL] Email and OTP available, calling sendEmail...');
          // Use name if available, otherwise use email as name
          final name = response.name ?? response.email!.split('@').first;
          await _globalService.sendEmail(response.email!, name, response.otp!);
        } else {
          print('🔥 [LOGIN VIEWMODEL] Missing data for email sending:');
          print(
              '🔥 [LOGIN VIEWMODEL] Email: ${response.email}, OTP: ${response.otp}');
        }

        setBusy(false);
        return LoginResult(
          success: false,
          message: response.message,
          responseType: LoginResponseType.otpRequired,
          otp: response.otp,
          email: response.email,
        );
      } else if (response is LoginErrorResponse) {
        // Login error (HTTP 401 or other errors)
        _errorMessage = response.message;
        _loginResponse = null;
        setBusy(false);
        return LoginResult(
          success: false,
          message: response.message,
          responseType: LoginResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _loginResponse = null;
        setBusy(false);
        return LoginResult(
          success: false,
          message: _errorMessage,
          responseType: LoginResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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
  Future<LoginResult> verifyOtp(String email, String otpCode) async {
    // Validasi input
    if (email.isEmpty || otpCode.isEmpty) {
      _errorMessage = 'Email dan kode OTP tidak boleh kosong';
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (otpCode.length != 5) {
      _errorMessage = 'Kode OTP harus 5 digit';
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

      // Handle different response types
      if (response is OtpVerificationResponseModel) {
        // OTP verification berhasil
        _loginResponse = LoginResponseModel(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          message: response.message,
          status: response.status,
          user: response.user,
        );
        _errorMessage = null;

        // Simpan data authentication ke Hive
        await HiveStorageService.saveAuthData(_loginResponse!);

        setBusy(false);
        return LoginResult(
          success: true,
          responseType: LoginResponseType.success,
        );
      } else if (response is OtpVerificationErrorModel) {
        // OTP verification error
        _errorMessage = response.error;
        _loginResponse = null;
        setBusy(false);
        return LoginResult(
          success: false,
          message: _errorMessage,
          responseType: LoginResponseType.error,
        );
      } else if (response is Map<String, dynamic>) {
        // Handle new API response structure
        if (response['status'] == 'success' ||
            response['access_token'] != null) {
          // Success response
          _loginResponse = LoginResponseModel(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
            message: response['message'],
            status: response['status'],
            user: response['user'] != null
                ? UserModel.fromJson(response['user'])
                : null,
          );
          _errorMessage = null;

          // Simpan data authentication ke Hive
          await HiveStorageService.saveAuthData(_loginResponse!);

          setBusy(false);
          return LoginResult(
            success: true,
            responseType: LoginResponseType.success,
          );
        } else {
          // Error response
          _errorMessage = response['error'] ?? 'Login failed';
          _loginResponse = null;
          setBusy(false);
          return LoginResult(
            success: false,
            message: _errorMessage,
            responseType: LoginResponseType.error,
          );
        }
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        _loginResponse = null;
        setBusy(false);
        return LoginResult(
          success: false,
          message: _errorMessage,
          responseType: LoginResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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
  Future<LoginResult> resendOtp(String email) async {
    // Validasi input
    if (email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      notifyListeners();
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }

    if (!isValidEmail(email)) {
      _errorMessage = 'Format email tidak valid';
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

      // Handle different response types
      if (response is Map<String, dynamic> && response['status'] == 'success') {
        // Resend OTP berhasil
        _errorMessage = null;
        setBusy(false);
        return LoginResult(
          success: true,
          message: response['message'] ?? 'New OTP sent to your email',
          responseType: LoginResponseType.success,
        );
      } else if (response is Map<String, dynamic> &&
          response['error'] != null) {
        // Resend OTP gagal
        _errorMessage = response['error'];
        setBusy(false);
        return LoginResult(
          success: false,
          message: _errorMessage,
          responseType: LoginResponseType.error,
        );
      } else {
        // Unexpected response
        _errorMessage = 'Terjadi kesalahan yang tidak terduga';
        setBusy(false);
        return LoginResult(
          success: false,
          message: _errorMessage,
          responseType: LoginResponseType.error,
        );
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      setBusy(false);
      return LoginResult(
        success: false,
        message: _errorMessage,
        responseType: LoginResponseType.error,
      );
    }
  }
}
