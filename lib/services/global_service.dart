import 'package:dio/dio.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:comecomepay/models/requests/login_request_model.dart';
import 'package:comecomepay/models/requests/otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/models/responses/login_error_model.dart';
import 'package:comecomepay/models/responses/forgot_password_error_model.dart';
import 'package:comecomepay/models/responses/otp_verification_response_model.dart';
import 'package:comecomepay/models/responses/otp_verification_error_model.dart';
import 'package:comecomepay/models/requests/signup_request_model.dart';
import 'package:comecomepay/models/responses/signup_response_model.dart';
import 'package:comecomepay/models/responses/signup_error_model.dart';
import 'package:comecomepay/models/requests/email_validation_request_model.dart';
import 'package:comecomepay/models/responses/email_validation_response_model.dart';
import 'package:comecomepay/models/responses/email_validation_error_model.dart';
import 'package:comecomepay/models/requests/registration_otp_verification_request_model.dart';
import 'package:comecomepay/models/requests/reset_password_otp_verification_request_model.dart';
import 'package:comecomepay/models/responses/registration_otp_verification_response_model.dart';
import 'package:comecomepay/models/responses/registration_otp_verification_error_model.dart';
import 'package:comecomepay/models/responses/set_password_response_model.dart';
import 'package:comecomepay/services/api_logger_service.dart';
import 'package:comecomepay/models/responses/coupon_response_model.dart';
import 'package:comecomepay/models/responses/coupon_error_model.dart';
import 'package:comecomepay/models/responses/new_coupon_model.dart';
import 'package:comecomepay/models/requests/claim_coupon_request_model.dart';
import 'package:comecomepay/models/responses/claim_coupon_response_model.dart';
import 'package:comecomepay/models/requests/change_email_request_model.dart';
import 'package:comecomepay/models/requests/didit_initialize_token_request_model.dart';
import 'package:comecomepay/models/responses/change_email_response_model.dart';
import 'package:comecomepay/models/responses/change_email_error_model.dart';
import 'package:comecomepay/models/responses/didit_initialize_token_response_model.dart';
import 'package:comecomepay/models/responses/didit_initialize_token_error_model.dart';
import 'package:comecomepay/models/requests/verify_new_email_request_model.dart';
import 'package:comecomepay/models/responses/verify_new_email_response_model.dart';
import 'package:comecomepay/models/requests/complete_change_email_request_model.dart';
import 'package:comecomepay/models/responses/complete_change_email_response_model.dart';
import 'package:comecomepay/models/requests/change_phone_request_model.dart';
import 'package:comecomepay/models/responses/change_phone_response_model.dart';
import 'package:comecomepay/models/responses/change_phone_error_model.dart';
import 'package:comecomepay/models/requests/complete_transaction_password_request_model.dart';
import 'package:comecomepay/models/responses/complete_transaction_password_response_model.dart';
import 'package:comecomepay/models/responses/complete_transaction_password_error_model.dart';
import 'package:comecomepay/models/requests/verify_new_phone_request_model.dart';
import 'package:comecomepay/models/responses/verify_new_phone_response_model.dart';
import 'package:comecomepay/models/requests/complete_change_phone_request_model.dart';
import 'package:comecomepay/models/responses/complete_change_phone_response_model.dart';
import 'package:comecomepay/models/responses/complete_change_phone_error_model.dart';
import 'package:comecomepay/models/requests/transaction_password_request_model.dart';
import 'package:comecomepay/models/responses/transaction_password_response_model.dart';
import 'package:comecomepay/models/responses/transaction_password_error_model.dart';
import 'package:comecomepay/models/requests/change_password_request_model.dart';
import 'package:comecomepay/models/responses/change_password_response_model.dart';
import 'package:comecomepay/models/responses/change_password_error_model.dart';
import 'package:comecomepay/models/responses/chat_inbox_response_model.dart';
import 'package:comecomepay/models/responses/chat_history_response_model.dart';
import 'package:comecomepay/models/requests/send_message_request_model.dart';
import 'package:comecomepay/models/responses/send_message_response_model.dart';
import 'package:comecomepay/models/notification_response_model.dart';
import 'package:comecomepay/models/responses/notification_unread_count_response_model.dart';
import 'package:comecomepay/models/requests/update_profile_request_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

import '../models/carddetail_response_model.dart' show CarddetailResponseModel;
import '../models/responses/get_profile_response_model.dart'
    show GetProfileResponseModel;
import 'package:comecomepay/models/responses/transaction_response_model.dart';
import 'package:comecomepay/models/responses/card_response_model.dart';
import 'package:comecomepay/models/transaction_record_model.dart';
import 'package:comecomepay/models/requests/create_wallet_request_model.dart';
import 'package:comecomepay/models/responses/create_wallet_response_model.dart';
import 'package:comecomepay/models/responses/create_wallet_error_model.dart';

// Response types for different HTTP status codes
class LoginSuccessResponse {
  final LoginResponseModel data;
  LoginSuccessResponse(this.data);
}

class LoginOtpRequiredResponse {
  final String message;
  final String? otp;
  final String? email;
  final String? name;
  LoginOtpRequiredResponse(this.message, {this.otp, this.email, this.name});
}

class LoginErrorResponse {
  final String message;
  LoginErrorResponse(this.message);
}

class GlobalService extends BaseService {
  final ApiLoggerService _apiLogger = ApiLoggerService();

  // Method untuk login with enhanced status code handling
  Future<dynamic> login(LoginRequestModel request) async {
    _apiLogger.logMethodEntry('login', parameters: {
      'email': request.email,
      'password': request.password, // Don't log password
    });

    try {
      final response = await post(
        '/auth/login',
        data: request.toJson(),
      );

      // Handle response berdasarkan struktur data baru
      if (response['status'] == 'success' &&
          response['next_step'] == 'verify_login_otp') {
        // Login berhasil tapi perlu OTP verification
        _apiLogger.logSuccess(
            'login', 'Authentication successful, OTP required');
        _apiLogger.logMethodExit('login', result: 'OTP required');
        return LoginOtpRequiredResponse(
            response['message'] ?? 'OTP verification required',
            otp: response['otp'],
            email: response['email'],
            name: response['name']);
      } else if (response['status'] == 'success') {
        // Login berhasil tanpa OTP
        _apiLogger.logSuccess('login', 'Authentication successful');
        _apiLogger.logMethodExit('login', result: 'Login successful');
        return LoginSuccessResponse(LoginResponseModel.fromJson(response));
      } else {
        // Login gagal
        _apiLogger.logFailure('login', 'Authentication failed',
            error: response['error']);
        _apiLogger.logMethodExit('login', result: 'Login failed');
        return LoginErrorResponse(
          response['error'] ?? 'Login failed',
        );
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - OTP required
      _apiLogger.logFailure('login', 'OTP required', error: e.toString());
      _apiLogger.logMethodExit('login', result: 'OTP required');
      return LoginOtpRequiredResponse(e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('login', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('login', result: 'Unauthorized');
      return LoginErrorResponse(e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('login', 'Server error', error: e.toString());
      _apiLogger.logMethodExit('login', result: 'Server error');
      return LoginErrorResponse(e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('login', 'Network error', error: e.toString());
      _apiLogger.logMethodExit('login', result: 'Network error');
      return LoginErrorResponse(e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('login', 'Exception occurred', error: e.toString());
      _apiLogger.logMethodExit('login', result: 'Exception: ${e.toString()}');
      return LoginErrorResponse(e.toString());
    }
  }

  Future<dynamic> verifyResetPasswordOtp(
      ResetPasswordOtpVerificationRequestModel request) async {
    _apiLogger.logMethodEntry('verifyResetPasswordOtp', parameters: {
      'email': request.email,
      'otp_code': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/verify-forgot-password-otp',
        data: request.toJson(),
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess(
            'verifyResetPasswordOtp', 'OTP verification successful');
        _apiLogger.logMethodExit('verifyResetPasswordOtp',
            result: 'OTP verification successful');
        return response;
      } else {
        _apiLogger.logFailure(
            'verifyResetPasswordOtp', 'OTP verification failed',
            error: response['error']);
        _apiLogger.logMethodExit('verifyResetPasswordOtp',
            result: 'OTP verification failed');
        return {'error': response['error'] ?? 'OTP verification failed'};
      }
    } catch (e) {
      _apiLogger.logFailure('verifyResetPasswordOtp', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('verifyResetPasswordOtp',
          result: 'Exception: ${e.toString()}');
      return {'error': e.toString()};
    }
  }

  // Method untuk refresh token (opsional)
  Future<dynamic> refreshToken(String refreshToken) async {
    _apiLogger.logMethodEntry('refreshToken', parameters: {
      'refresh_token': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response['status'] == 'success' || response['access_token'] != null) {
        _apiLogger.logSuccess('refreshToken', 'Token refresh successful');
        _apiLogger.logMethodExit('refreshToken',
            result: 'Token refresh successful');
        return LoginResponseModel.fromJson(response);
      } else {
        _apiLogger.logFailure('refreshToken', 'Token refresh failed',
            error: response['message']);
        _apiLogger.logMethodExit('refreshToken',
            result: 'Token refresh failed');
        return LoginErrorModel(
          error: response['message'] ?? 'Token refresh failed',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('refreshToken', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('refreshToken',
          result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk logout
  Future<dynamic> logout(String accessToken) async {
    _apiLogger.logMethodEntry('logout', parameters: {
      'access_token': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/logout',
        data: {'access_token': accessToken},
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess('logout', 'Logout successful');
        _apiLogger.logMethodExit('logout', result: 'Logout successful');
        return {'message': 'Logout successful'};
      } else {
        _apiLogger.logFailure('logout', 'Logout failed',
            error: response['message']);
        _apiLogger.logMethodExit('logout', result: 'Logout failed');
        return LoginErrorModel(
          error: response['message'] ?? 'Logout failed',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('logout', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('logout', result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk register
  Future<dynamic> register(Map<String, dynamic> userData) async {
    _apiLogger.logMethodEntry('register', parameters: {
      'email': userData['email'] ?? 'N/A',
      'password': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/register',
        data: userData,
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess('register', 'Registration successful');
        _apiLogger.logMethodExit('register', result: 'Registration successful');
        return {'message': 'Registration successful'};
      } else {
        _apiLogger.logFailure('register', 'Registration failed',
            error: response['message']);
        _apiLogger.logMethodExit('register', result: 'Registration failed');
        return LoginErrorModel(
          error: response['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('register', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('register',
          result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk forgot password
  Future<dynamic> forgotPassword(String email) async {
    _apiLogger.logMethodEntry('forgotPassword', parameters: {
      'email': email,
    });

    try {
      final response = await post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess('forgotPassword', 'Password reset email sent');
        _apiLogger.logMethodExit('forgotPassword',
            result: 'Password reset email sent');
        return response;
      } else {
        _apiLogger.logFailure('forgotPassword', 'Failed to send reset email',
            error: response['message']);
        _apiLogger.logMethodExit('forgotPassword',
            result: 'Failed to send reset email');
        return ForgotPasswordErrorModel(
          error: response['message'] ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('forgotPassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('forgotPassword',
          result: 'Exception: ${e.toString()}');
      return ForgotPasswordErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk reset password
  Future<dynamic> resetPassword(String token, String newPassword) async {
    _apiLogger.logMethodEntry('resetPassword', parameters: {
      'token': '***HIDDEN***',
      'password': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess('resetPassword', 'Password reset successful');
        _apiLogger.logMethodExit('resetPassword',
            result: 'Password reset successful');
        return {'message': 'Password reset successful'};
      } else {
        _apiLogger.logFailure('resetPassword', 'Password reset failed',
            error: response['message']);
        _apiLogger.logMethodExit('resetPassword',
            result: 'Password reset failed');
        return LoginErrorModel(
          error: response['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('resetPassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('resetPassword',
          result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk reset password create password
  Future<dynamic> resetPasswordCreatePassword(
      String email, String newPassword, String confirmPassword) async {
    _apiLogger.logMethodEntry('resetPasswordCreatePassword', parameters: {
      'email': email,
      'new_password': '***HIDDEN***',
      'confirm_password': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/reset-password',
        data: {
          'email': email,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess(
            'resetPasswordCreatePassword', 'Password reset successfully');
        _apiLogger.logMethodExit('resetPasswordCreatePassword',
            result: 'Password reset successfully');
        return response;
      } else {
        _apiLogger.logFailure(
            'resetPasswordCreatePassword', 'Password reset failed',
            error: response['error']);
        _apiLogger.logMethodExit('resetPasswordCreatePassword',
            result: 'Password reset failed');
        return {'error': response['error'] ?? 'Password reset failed'};
      }
    } catch (e) {
      _apiLogger.logFailure('resetPasswordCreatePassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('resetPasswordCreatePassword',
          result: 'Exception: ${e.toString()}');
      return {'error': e.toString()};
    }
  }

  // Method untuk get user profile
  Future<dynamic> getUserProfile(String accessToken) async {
    _apiLogger.logMethodEntry('getUserProfile', parameters: {
      'access_token': '***HIDDEN***',
    });

    try {
      final response = await get(
        '/auth/profile',
        queryParameters: {'access_token': accessToken},
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess(
            'getUserProfile', 'Profile retrieved successfully');
        _apiLogger.logMethodExit('getUserProfile',
            result: 'Profile retrieved successfully');
        return response;
      } else {
        _apiLogger.logFailure('getUserProfile', 'Failed to get profile',
            error: response['message']);
        _apiLogger.logMethodExit('getUserProfile',
            result: 'Failed to get profile');
        return LoginErrorModel(
          error: response['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('getUserProfile', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getUserProfile',
          result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk update user profile
  Future<dynamic> updateUserProfile(
      String accessToken, Map<String, dynamic> profileData) async {
    _apiLogger.logMethodEntry('updateUserProfile', parameters: {
      'access_token': '***HIDDEN***',
      'profile_data': profileData.keys.toList(), // Log only keys, not values
    });

    try {
      final response = await put(
        '/auth/profile',
        data: {
          'access_token': accessToken,
          ...profileData,
        },
      );

      if (response['status'] == 'success') {
        _apiLogger.logSuccess(
            'updateUserProfile', 'Profile updated successfully');
        _apiLogger.logMethodExit('updateUserProfile',
            result: 'Profile updated successfully');
        return response;
      } else {
        _apiLogger.logFailure('updateUserProfile', 'Failed to update profile',
            error: response['message']);
        _apiLogger.logMethodExit('updateUserProfile',
            result: 'Failed to update profile');
        return LoginErrorModel(
          error: response['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      _apiLogger.logFailure('updateUserProfile', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('updateUserProfile',
          result: 'Exception: ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk OTP verification
  Future<dynamic> verifyOtp(OtpVerificationRequestModel request) async {
    _apiLogger.logMethodEntry('verifyOtp', parameters: {
      'email': request.email,
      'otp_code': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/verify-login-otp',
        data: request.toJson(),
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success' || response['access_token'] != null) {
        // OTP verification berhasil
        _apiLogger.logSuccess('verifyOtp', 'OTP verification successful');
        _apiLogger.logMethodExit('verifyOtp',
            result: 'OTP verification successful');
        return OtpVerificationResponseModel.fromJson(response);
      } else {
        // OTP verification gagal
        _apiLogger.logFailure('verifyOtp', 'OTP verification failed',
            error: response['error']);
        _apiLogger.logMethodExit('verifyOtp',
            result: 'OTP verification failed');
        return OtpVerificationErrorModel(
          error: response['error'] ?? 'OTP verification failed',
        );
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Invalid or expired OTP
      _apiLogger.logFailure('verifyOtp', 'Invalid or expired OTP',
          error: e.toString());
      _apiLogger.logMethodExit('verifyOtp', result: 'Invalid or expired OTP');
      return OtpVerificationErrorModel(error: e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('verifyOtp', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('verifyOtp', result: 'Unauthorized');
      return OtpVerificationErrorModel(error: e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('verifyOtp', 'Server error', error: e.toString());
      _apiLogger.logMethodExit('verifyOtp', result: 'Server error');
      return OtpVerificationErrorModel(error: e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('verifyOtp', 'Network error', error: e.toString());
      _apiLogger.logMethodExit('verifyOtp', result: 'Network error');
      return OtpVerificationErrorModel(error: e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('verifyOtp', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('verifyOtp',
          result: 'Exception: ${e.toString()}');
      return OtpVerificationErrorModel(error: e.toString());
    }
  }

  // Method untuk signup
  Future<dynamic> signup(SignupRequestModel request) async {
    _apiLogger.logMethodEntry('signup', parameters: {
      'email': request.email,
      'phone': request.phone,
      'first_name': request.firstName,
      'last_name': request.lastName,
      'date_of_birth': request.dateOfBirth,
      'account_type': request.accountType,
      'password': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/signup',
        data: request.toJson(),
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success') {
        // Signup berhasil
        _apiLogger.logSuccess('signup', 'Signup successful');
        _apiLogger.logMethodExit('signup', result: 'Signup successful');
        return SignupResponseModel.fromJson(response);
      } else {
        // Signup gagal
        _apiLogger.logFailure('signup', 'Signup failed',
            error: response['error']);
        _apiLogger.logMethodExit('signup', result: 'Signup failed');
        return SignupErrorModel.fromJson(response);
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Forbidden
      _apiLogger.logFailure('signup', 'Forbidden', error: e.toString());
      _apiLogger.logMethodExit('signup', result: 'Forbidden');
      return SignupErrorModel(error: e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('signup', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('signup', result: 'Unauthorized');
      return SignupErrorModel(error: e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('signup', 'Server error', error: e.toString());
      _apiLogger.logMethodExit('signup', result: 'Server error');
      return SignupErrorModel(error: e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('signup', 'Network error', error: e.toString());
      _apiLogger.logMethodExit('signup', result: 'Network error');
      return SignupErrorModel(error: e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('signup', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('signup', result: 'Exception: ${e.toString()}');
      return SignupErrorModel(error: e.toString());
    }
  }

  // Method untuk email validation
  Future<dynamic> validateEmail(EmailValidationRequestModel request) async {
    _apiLogger.logMethodEntry('validateEmail', parameters: {
      'email': request.email,
    });

    try {
      final response = await post(
        '/auth/signup',
        data: request.toJson(),
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success') {
        // Email validation berhasil
        _apiLogger.logSuccess('validateEmail', 'Email validation successful');
        _apiLogger.logMethodExit('validateEmail',
            result: 'Email validation successful');
        return EmailValidationResponseModel.fromJson(response);
      } else {
        // Email validation gagal
        _apiLogger.logFailure('validateEmail', 'Email validation failed',
            error: response['error']);
        _apiLogger.logMethodExit('validateEmail',
            result: 'Email validation failed');
        return EmailValidationErrorModel.fromJson(response);
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Forbidden
      _apiLogger.logFailure('validateEmail', 'Forbidden', error: e.toString());
      _apiLogger.logMethodExit('validateEmail', result: 'Forbidden');
      return EmailValidationErrorModel(error: e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('validateEmail', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('validateEmail', result: 'Unauthorized');
      return EmailValidationErrorModel(error: e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('validateEmail', 'Server error',
          error: e.toString());
      _apiLogger.logMethodExit('validateEmail', result: 'Server error');
      return EmailValidationErrorModel(error: e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('validateEmail', 'Network error',
          error: e.toString());
      _apiLogger.logMethodExit('validateEmail', result: 'Network error');
      return EmailValidationErrorModel(error: e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('validateEmail', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('validateEmail',
          result: 'Exception: ${e.toString()}');
      return EmailValidationErrorModel(error: e.toString());
    }
  }

  // Method untuk verify registration OTP
  Future<dynamic> verifyRegistrationOtp(
      RegistrationOtpVerificationRequestModel request) async {
    _apiLogger.logMethodEntry('verifyRegistrationOtp', parameters: {
      'email': request.email,
      'otp_code': '***HIDDEN***',
    });

    try {
      final response = await post(
        '/auth/verify',
        data: request.toJson(),
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success') {
        // Registration OTP verification berhasil
        _apiLogger.logSuccess('verifyRegistrationOtp',
            'Registration OTP verification successful');
        _apiLogger.logMethodExit('verifyRegistrationOtp',
            result: 'Registration OTP verification successful');
        return RegistrationOtpVerificationResponseModel.fromJson(response);
      } else {
        // Registration OTP verification gagal
        _apiLogger.logFailure(
            'verifyRegistrationOtp', 'Registration OTP verification failed',
            error: response['error']);
        _apiLogger.logMethodExit('verifyRegistrationOtp',
            result: 'Registration OTP verification failed');
        return RegistrationOtpVerificationErrorModel.fromJson(response);
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Invalid or expired OTP
      _apiLogger.logFailure('verifyRegistrationOtp', 'Invalid or expired OTP',
          error: e.toString());
      _apiLogger.logMethodExit('verifyRegistrationOtp',
          result: 'Invalid or expired OTP');
      return RegistrationOtpVerificationErrorModel(error: e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('verifyRegistrationOtp', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('verifyRegistrationOtp', result: 'Unauthorized');
      return RegistrationOtpVerificationErrorModel(error: e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('verifyRegistrationOtp', 'Server error',
          error: e.toString());
      _apiLogger.logMethodExit('verifyRegistrationOtp', result: 'Server error');
      return RegistrationOtpVerificationErrorModel(error: e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('verifyRegistrationOtp', 'Network error',
          error: e.toString());
      _apiLogger.logMethodExit('verifyRegistrationOtp',
          result: 'Network error');
      return RegistrationOtpVerificationErrorModel(error: e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('verifyRegistrationOtp', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('verifyRegistrationOtp',
          result: 'Exception: ${e.toString()}');
      return RegistrationOtpVerificationErrorModel(error: e.toString());
    }
  }

  // Method untuk set password
  Future<dynamic> setPassword(String email, String password,
      {String? referralCode}) async {
    _apiLogger.logMethodEntry('setPassword', parameters: {
      'email': email,
      'password': '***HIDDEN***',
      'referral_code': referralCode ?? 'N/A',
    });

    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };

      if (referralCode != null && referralCode.isNotEmpty) {
        data['referral_code'] = referralCode;
      }

      final response = await post(
        '/auth/set-password',
        data: data,
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success') {
        // Set password berhasil
        _apiLogger.logSuccess('setPassword', 'Password set successfully');
        _apiLogger.logMethodExit('setPassword',
            result: 'Password set successfully');
        return SetPasswordResponseModel.fromJson(response);
      } else {
        // Set password gagal
        _apiLogger.logFailure('setPassword', 'Password set failed',
            error: response['error']);
        _apiLogger.logMethodExit('setPassword', result: 'Password set failed');
        return SetPasswordErrorModel.fromJson(response);
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Invalid or expired OTP
      _apiLogger.logFailure('setPassword', 'Invalid or expired OTP',
          error: e.toString());
      _apiLogger.logMethodExit('setPassword', result: 'Invalid or expired OTP');
      return SetPasswordErrorModel(error: e.message);
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('setPassword', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('setPassword', result: 'Unauthorized');
      return SetPasswordErrorModel(error: e.message);
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('setPassword', 'Server error', error: e.toString());
      _apiLogger.logMethodExit('setPassword', result: 'Server error');
      return SetPasswordErrorModel(error: e.message);
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('setPassword', 'Network error',
          error: e.toString());
      _apiLogger.logMethodExit('setPassword', result: 'Network error');
      return SetPasswordErrorModel(error: e.message);
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('setPassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('setPassword',
          result: 'Exception: ${e.toString()}');
      return SetPasswordErrorModel(error: e.toString());
    }
  }

  // Method untuk resend OTP
  Future<dynamic> resendOtp(String email) async {
    _apiLogger.logMethodEntry('resendOtp', parameters: {
      'email': email,
    });

    try {
      final response = await post(
        '/auth/resend-otp',
        data: {'email': email},
      );

      // Handle response berdasarkan struktur data
      if (response['status'] == 'success') {
        // Resend OTP berhasil
        _apiLogger.logSuccess('resendOtp', 'OTP resent successfully');
        _apiLogger.logMethodExit('resendOtp',
            result: 'OTP resent successfully');
        return response;
      } else {
        // Resend OTP gagal
        _apiLogger.logFailure('resendOtp', 'Failed to resend OTP',
            error: response['error']);
        _apiLogger.logMethodExit('resendOtp', result: 'Failed to resend OTP');
        return {'error': response['error'] ?? 'Failed to resend OTP'};
      }
    } on ForbiddenException catch (e) {
      // HTTP 403 - Forbidden
      _apiLogger.logFailure('resendOtp', 'Forbidden', error: e.toString());
      _apiLogger.logMethodExit('resendOtp', result: 'Forbidden');
      return {'error': e.message};
    } on UnauthorizedException catch (e) {
      // HTTP 401 - Unauthorized
      _apiLogger.logFailure('resendOtp', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('resendOtp', result: 'Unauthorized');
      return {'error': e.message};
    } on ServerErrorException catch (e) {
      // HTTP 500 - Server error
      _apiLogger.logFailure('resendOtp', 'Server error', error: e.toString());
      _apiLogger.logMethodExit('resendOtp', result: 'Server error');
      return {'error': e.message};
    } on NetworkException catch (e) {
      // Network error
      _apiLogger.logFailure('resendOtp', 'Network error', error: e.toString());
      _apiLogger.logMethodExit('resendOtp', result: 'Network error');
      return {'error': e.message};
    } catch (e) {
      // Handle other errors
      _apiLogger.logFailure('resendOtp', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('resendOtp',
          result: 'Exception: ${e.toString()}');
      return {'error': e.toString()};
    }
  }

  // Method untuk get user profile
  Future<dynamic> getProfile(String accessToken) async {
    _apiLogger.logMethodEntry('getProfile', parameters: {
      'access_token': '***HIDDEN***',
    });

    try {
      final response = await dio.get(
        '/user/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      return handleResponse(response);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // Method untuk update user profile
  Future<dynamic> updateProfile(UpdateProfileRequestModel request) async {
    _apiLogger.logMethodEntry('updateProfile', parameters: {
      'first_name': request.firstName,
      'last_name': request.lastName,
      'phone': request.phone,
      'date_of_birth': request.dateOfBirth,
      'account_type': request.accountType,
      'referral_code': request.referralCode,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.put(
        '/user/profile',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('updateProfile', 'Profile updated successfully');
        _apiLogger.logMethodExit('updateProfile', result: 'Success');
        return GetProfileResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('updateProfile', 'Failed to update profile',
            error: data['error']);
        _apiLogger.logMethodExit('updateProfile', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to update profile');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('updateProfile', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('updateProfile', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('updateProfile', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('updateProfile', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('updateProfile', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('updateProfile',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Method untuk get my coupons
  Future<CouponResponseModel> getMyCoupons(
      String status, int page, int limit) async {
    _apiLogger.logMethodEntry('getMyCoupons', parameters: {
      'status': status,
      'page': page,
      'limit': limit,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/coupons/my-coupons',
        queryParameters: {
          'status': status,
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('getMyCoupons', 'Coupons retrieved successfully');
        _apiLogger.logMethodExit('getMyCoupons', result: 'Success');
        return CouponResponseModel.fromJson(data['data']);
      } else {
        _apiLogger.logFailure('getMyCoupons', 'Failed to retrieve coupons',
            error: data['error']);
        _apiLogger.logMethodExit('getMyCoupons', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve coupons');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getMyCoupons', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getMyCoupons', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getMyCoupons', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('getMyCoupons', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getMyCoupons', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getMyCoupons',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve coupons: ${e.toString()}');
    }
  }

  // Method untuk get coupons (新API)
  Future<NewCouponResponseModel> getCoupons({bool onlyValid = true}) async {
    _apiLogger.logMethodEntry('getCoupons', parameters: {
      'only_valid': onlyValid,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/coupons/',
        queryParameters: {
          'only_valid': onlyValid,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('getCoupons', 'Coupons retrieved successfully');
        _apiLogger.logMethodExit('getCoupons', result: 'Success');
        return NewCouponResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('getCoupons', 'Failed to retrieve coupons',
            error: data['error']);
        _apiLogger.logMethodExit('getCoupons', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve coupons');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getCoupons', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('getCoupons', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getCoupons', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('getCoupons', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getCoupons', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getCoupons',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve coupons: ${e.toString()}');
    }
  }

  // Method untuk claim coupon
  Future<ClaimCouponResponseModel> claimCoupon(String couponCode) async {
    _apiLogger.logMethodEntry('claimCoupon', parameters: {
      'coupon_code': couponCode,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final request = ClaimCouponRequestModel(couponCode: couponCode);
      final response = await dio.post(
        '/coupons/claim',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('claimCoupon', 'Coupon claimed successfully');
        _apiLogger.logMethodExit('claimCoupon', result: 'Success');
        return ClaimCouponResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('claimCoupon', 'Failed to claim coupon',
            error: data['error']);
        _apiLogger.logMethodExit('claimCoupon', result: 'Failed');
        throw CouponErrorModel.fromJson(
            {'error': data['error'] ?? 'Failed to claim coupon'});
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('claimCoupon', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('claimCoupon', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('claimCoupon', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('claimCoupon', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('claimCoupon', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('claimCoupon',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to claim coupon: ${e.toString()}');
    }
  }

  // Method untuk change email request
  Future<dynamic> changeEmail(ChangeEmailRequestModel request) async {
    _apiLogger.logMethodEntry('changeEmail', parameters: {
      'new_email': request.newEmail,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-email/request',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('changeEmail', 'Change email request successful');
        _apiLogger.logMethodExit('changeEmail', result: 'Success');
        return ChangeEmailResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('changeEmail', 'Change email request failed',
            error: data['error']);
        _apiLogger.logMethodExit('changeEmail', result: 'Failed');
        return ChangeEmailErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('changeEmail', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('changeEmail', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('changeEmail', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('changeEmail', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('changeEmail', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('changeEmail',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to change email: ${e.toString()}');
    }
  }

  // Method untuk verify new email OTP
  Future<dynamic> verifyNewEmail(VerifyNewEmailRequestModel request) async {
    _apiLogger.logMethodEntry('verifyNewEmail', parameters: {
      'new_email': request.newEmail,
      'otp_code': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-email/verify-new',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'verifyNewEmail', 'New email verification successful');
        _apiLogger.logMethodExit('verifyNewEmail', result: 'Success');
        return VerifyNewEmailResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('verifyNewEmail', 'New email verification failed',
            error: data['error']);
        _apiLogger.logMethodExit('verifyNewEmail', result: 'Failed');
        return ChangeEmailErrorModel.fromJson(data); // Reuse error model
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('verifyNewEmail', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('verifyNewEmail', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('verifyNewEmail', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('verifyNewEmail', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('verifyNewEmail', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('verifyNewEmail',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to verify new email: ${e.toString()}');
    }
  }

  // Method untuk complete change email
  Future<dynamic> completeChangeEmail(
      CompleteChangeEmailRequestModel request) async {
    _apiLogger.logMethodEntry('completeChangeEmail', parameters: {
      'new_email': request.newEmail,
      'old_email_otp': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-email/complete',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'completeChangeEmail', 'Email change completed successfully');
        _apiLogger.logMethodExit('completeChangeEmail', result: 'Success');
        return CompleteChangeEmailResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'completeChangeEmail', 'Email change completion failed',
            error: data['error']);
        _apiLogger.logMethodExit('completeChangeEmail', result: 'Failed');
        return ChangeEmailErrorModel.fromJson(data); // Reuse error model
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('completeChangeEmail', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangeEmail', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('completeChangeEmail', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangeEmail', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('completeChangeEmail', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangeEmail',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to complete email change: ${e.toString()}');
    }
  }

  // Method untuk change phone request
  Future<dynamic> changePhoneRequest(ChangePhoneRequestModel request) async {
    _apiLogger.logMethodEntry('changePhoneRequest', parameters: {
      'new_phone': request.newPhone,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-phone/request',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'changePhoneRequest', 'Change phone request successful');
        _apiLogger.logMethodExit('changePhoneRequest', result: 'Success');
        return ChangePhoneResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'changePhoneRequest', 'Change phone request failed',
            error: data['error']);
        _apiLogger.logMethodExit('changePhoneRequest', result: 'Failed');
        return ChangePhoneErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('changePhoneRequest', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('changePhoneRequest', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('changePhoneRequest', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('changePhoneRequest', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('changePhoneRequest', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('changePhoneRequest',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to change phone: ${e.toString()}');
    }
  }

  // Method untuk verify new phone
  Future<dynamic> verifyNewPhone(VerifyNewPhoneRequestModel request) async {
    _apiLogger.logMethodEntry('verifyNewPhone', parameters: {
      'email': request.email,
      'new_phone': request.newPhone,
      'otp_code': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-phone/verify-new',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('verifyNewPhone', 'Verify new phone successful');
        _apiLogger.logMethodExit('verifyNewPhone', result: 'Success');
        return VerifyNewPhoneResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('verifyNewPhone', 'Verify new phone failed',
            error: data['error']);
        _apiLogger.logMethodExit('verifyNewPhone', result: 'Failed');
        return ChangePhoneErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('verifyNewPhone', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('verifyNewPhone', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('verifyNewPhone', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('verifyNewPhone', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('verifyNewPhone', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('verifyNewPhone',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to verify new phone: ${e.toString()}');
    }
  }

  // Method untuk complete change phone
  Future<dynamic> completeChangePhone(
      CompleteChangePhoneRequestModel request) async {
    _apiLogger.logMethodEntry('completeChangePhone', parameters: {
      'new_phone': request.newPhone,
      'email_otp': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-phone/complete',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'completeChangePhone', 'Phone change completed successfully');
        _apiLogger.logMethodExit('completeChangePhone', result: 'Success');
        return CompleteChangePhoneResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'completeChangePhone', 'Phone change completion failed',
            error: data['error']);
        _apiLogger.logMethodExit('completeChangePhone', result: 'Failed');
        return CompleteChangePhoneErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('completeChangePhone', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangePhone', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('completeChangePhone', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangePhone', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('completeChangePhone', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('completeChangePhone',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to complete phone change: ${e.toString()}');
    }
  }

  // Method untuk request transaction password
  Future<dynamic> requestTransactionPassword(
      TransactionPasswordRequestModel request) async {
    _apiLogger.logMethodEntry('requestTransactionPassword', parameters: {
      'transaction_password': '***HIDDEN***',
      'confirm_transaction_password': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/transaction-password/request',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('requestTransactionPassword',
            'Transaction password request successful');
        _apiLogger.logMethodExit('requestTransactionPassword',
            result: 'Success');
        return TransactionPasswordResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'requestTransactionPassword', 'Transaction password request failed',
            error: data['error']);
        _apiLogger.logMethodExit('requestTransactionPassword',
            result: 'Failed');
        return TransactionPasswordErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('requestTransactionPassword', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('requestTransactionPassword',
          result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('requestTransactionPassword', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('requestTransactionPassword',
          result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('requestTransactionPassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('requestTransactionPassword',
          result: 'Exception: ${e.toString()}');
      throw Exception(
          'Failed to request transaction password: ${e.toString()}');
    }
  }

  // Method untuk complete transaction password
  Future<dynamic> completeTransactionPassword(
      CompleteTransactionPasswordRequestModel request) async {
    _apiLogger.logMethodEntry('completeTransactionPassword', parameters: {
      'otp_code': '***HIDDEN***',
      'temp_hash': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/transaction-password/complete',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('completeTransactionPassword',
            'Transaction password set successfully');
        _apiLogger.logMethodExit('completeTransactionPassword',
            result: 'Success');
        return CompleteTransactionPasswordResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'completeTransactionPassword', 'Completion failed',
            error: data['error']);
        _apiLogger.logMethodExit('completeTransactionPassword',
            result: 'Failed');
        return CompleteTransactionPasswordErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('completeTransactionPassword', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('completeTransactionPassword',
          result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('completeTransactionPassword', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('completeTransactionPassword',
          result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('completeTransactionPassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('completeTransactionPassword',
          result: 'Exception: ${e.toString()}');
      throw Exception(
          'Failed to complete transaction password: ${e.toString()}');
    }
  }

  // Method untuk change password
  Future<dynamic> changePassword(ChangePasswordRequestModel request) async {
    _apiLogger.logMethodEntry('changePassword', parameters: {
      'old_password': '***HIDDEN***',
      'new_password': '***HIDDEN***',
      'confirm_password': '***HIDDEN***',
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/user/change-password',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'changePassword', 'Password changed successfully');
        _apiLogger.logMethodExit('changePassword', result: 'Success');
        return ChangePasswordResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('changePassword', 'Change password failed',
            error: data['error']);
        _apiLogger.logMethodExit('changePassword', result: 'Failed');
        return ChangePasswordErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('changePassword', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('changePassword', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('changePassword', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('changePassword', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('changePassword', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('changePassword',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Method untuk get chat inbox
  Future<ChatInboxResponseModel> getChatInbox(int page, int limit) async {
    _apiLogger.logMethodEntry('getChatInbox', parameters: {
      'page': page,
      'limit': limit,
    });

    try {
      final accessToken = await HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/chat/inbox',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['messages'] != null) {
        _apiLogger.logSuccess(
            'getChatInbox', 'Chat inbox retrieved successfully');
        _apiLogger.logMethodExit('getChatInbox', result: 'Success');
        return ChatInboxResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('getChatInbox', 'Failed to retrieve chat inbox',
            error: data['error']);
        _apiLogger.logMethodExit('getChatInbox', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve chat inbox');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getChatInbox', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getChatInbox', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getChatInbox', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('getChatInbox', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getChatInbox', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getChatInbox',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve chat inbox: ${e.toString()}');
    }
  }

  // Method untuk send chat message
  Future<SendMessageResponseModel> sendChatMessage(
      SendMessageRequestModel request) async {
    _apiLogger.logMethodEntry('sendChatMessage', parameters: {
      'message': request.message,
    });

    try {
      final accessToken = await HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        'http://149.88.65.193:8010/api/chat/send',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200) {
        _apiLogger.logSuccess('sendChatMessage', 'Message sent successfully');
        _apiLogger.logMethodExit('sendChatMessage', result: 'Success');
        return SendMessageResponseModel.fromJson(data['data']);
      } else {
        _apiLogger.logFailure('sendChatMessage', 'Failed to send message',
            error: data['message']);
        _apiLogger.logMethodExit('sendChatMessage', result: 'Failed');
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('sendChatMessage', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('sendChatMessage', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('sendChatMessage', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('sendChatMessage', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('sendChatMessage', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('sendChatMessage',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Method untuk get notifications
  Future<NotificationResponseModel> getNotifications(
      int limit, int offset) async {
    _apiLogger.logMethodEntry('getNotifications', parameters: {
      'limit': limit,
      'offset': offset,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/notifications/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'getNotifications', 'Notifications retrieved successfully');
        _apiLogger.logMethodExit('getNotifications', result: 'Success');
        return NotificationResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'getNotifications', 'Failed to retrieve notifications',
            error: data['error']);
        _apiLogger.logMethodExit('getNotifications', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve notifications');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getNotifications', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getNotifications', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getNotifications', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('getNotifications', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getNotifications', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getNotifications',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve notifications: ${e.toString()}');
    }
  }

  // Method untuk get unread notification count
  Future<NotificationUnreadCountResponseModel>
      getUnreadNotificationCount() async {
    _apiLogger.logMethodEntry('getUnreadNotificationCount');

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/notifications/unread-count',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess('getUnreadNotificationCount',
            'Unread count retrieved successfully');
        _apiLogger.logMethodExit('getUnreadNotificationCount',
            result: 'Success');
        return NotificationUnreadCountResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'getUnreadNotificationCount', 'Failed to retrieve unread count',
            error: data['error']);
        _apiLogger.logMethodExit('getUnreadNotificationCount',
            result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve unread count');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getUnreadNotificationCount', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getUnreadNotificationCount',
          result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getUnreadNotificationCount', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('getUnreadNotificationCount',
          result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getUnreadNotificationCount', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getUnreadNotificationCount',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve unread count: ${e.toString()}');
    }
  }

  Future<CarddetailResponseModel> initGetCard(int kyc_id) async {
    try {
      final response = await dio.get(
        'http://149.88.65.193:8010/api/v1/card',
        queryParameters: {'kyc_id': kyc_id},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200) {
        _apiLogger.logSuccess(
            'getCardData', 'Card data retrieved successfully');
        _apiLogger.logMethodExit('getCardData', result: 'Success');
        return CarddetailResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('getCardData', 'Failed to retrieve card data',
            error: data['message']);
        _apiLogger.logMethodExit('getCardData', result: 'Failed');
        throw Exception(data['message'] ?? 'Failed to retrieve card data');
      }
    } catch (e) {
      _apiLogger.logFailure('initGetCard', 'Exception occurred',
          error: e.toString());
      throw Exception('Failed to retrieve card data: ${e.toString()}');
    }
  }

  // Method untuk initialize Didit token
  Future<dynamic> initializeDiditToken(
      DiditInitializeTokenRequestModel request) async {
    _apiLogger.logMethodEntry('initializeDiditToken', parameters: {
      'email': request.email,
      'first_en_name': request.firstEnName,
      'last_en_name': request.lastEnName,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        '/didit/initialize-token',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = handleResponse(response);
      if (data['didit_token'] != null) {
        _apiLogger.logSuccess(
            'initializeDiditToken', 'Didit token initialized successfully');
        _apiLogger.logMethodExit('initializeDiditToken', result: 'Success');
        return DiditInitializeTokenResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'initializeDiditToken', 'Failed to initialize Didit token',
            error: data['message']);
        _apiLogger.logMethodExit('initializeDiditToken', result: 'Failed');
        return DiditInitializeTokenErrorModel.fromJson(data);
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('initializeDiditToken', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('initializeDiditToken', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('initializeDiditToken', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('initializeDiditToken', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('initializeDiditToken', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('initializeDiditToken',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to initialize Didit token: ${e.toString()}');
    }
  }

  // Method untuk get card data
  Future<CardResponseModel> getCardData(String userId) async {
    _apiLogger.logMethodEntry('getCardData', parameters: {
      'user_id': userId,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        'http://149.88.65.193:8010/api/card',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'id_user': userId,
          },
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200) {
        _apiLogger.logSuccess(
            'getCardData', 'Card data retrieved successfully');
        _apiLogger.logMethodExit('getCardData', result: 'Success');
        return CardResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('getCardData', 'Failed to retrieve card data',
            error: data['message']);
        _apiLogger.logMethodExit('getCardData', result: 'Failed');
        throw Exception(data['message'] ?? 'Failed to retrieve card data');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getCardData', 'Unauthorized', error: e.toString());
      _apiLogger.logMethodExit('getCardData', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getCardData', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('getCardData', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getCardData', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getCardData',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve card data: ${e.toString()}');
    }
  }

  // Method untuk get transaction data
  Future<TransactionResponse> getTransactionData(String userId) async {
    _apiLogger.logMethodEntry('getTransactionData', parameters: {
      'user_id': userId,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        '/user/transactions',
        queryParameters: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['status'] == 'success') {
        _apiLogger.logSuccess(
            'getTransactionData', 'Transaction data retrieved successfully');
        _apiLogger.logMethodExit('getTransactionData', result: 'Success');
        return TransactionResponse.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'getTransactionData', 'Failed to retrieve transaction data',
            error: data['error']);
        _apiLogger.logMethodExit('getTransactionData', result: 'Failed');
        throw Exception(data['error'] ?? 'Failed to retrieve transaction data');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getTransactionData', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getTransactionData', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getTransactionData', 'Dio error',
          error: e.toString());
      _apiLogger.logMethodExit('getTransactionData', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getTransactionData', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getTransactionData',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve transaction data: ${e.toString()}');
    }
  }

  // Method untuk send email
  Future<bool> sendEmail(String email, String name, String otp,
      {bool isForgotPassword = false}) async {
    print('🔥 [SEND EMAIL] Starting sendEmail process...');
    print('🔥 [SEND EMAIL] Email: $email, Name: $name, OTP: ***HIDDEN***');

    if (isForgotPassword) {
      print('🔥 [SEND EMAIL] Skipping email sending for Forgot Password flow.');
      return true;
    }

    _apiLogger.logMethodEntry('sendEmail', parameters: {
      'email': email,
      'name': name,
      'otp': '***HIDDEN***',
    });

    try {
      print('🔥 [SEND EMAIL] Making API call to send-email endpoint...');
      final response = await dio.post(
        'http://149.88.65.193:8010/api/v1/auth/verify-otp',
        data: {
          'email': email,
          'referral_code': '',
          'otp_code': otp,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          '🔥 [SEND EMAIL] API Response received. Status: ${response.statusCode}');
      final data = handleResponse(response);
      print('🔥 [SEND EMAIL] Response data: $data');

      if (data['status'] == 'success' || response.statusCode == 200) {
        print('🔥 [SEND EMAIL] Email sent successfully!');
        _apiLogger.logSuccess('sendEmail', 'Email sent successfully');
        _apiLogger.logMethodExit('sendEmail', result: 'Success');
        return true;
      } else {
        print('🔥 [SEND EMAIL] Failed to send email. Error: ${data['error']}');
        _apiLogger.logFailure('sendEmail', 'Failed to send email',
            error: data['error']);
        _apiLogger.logMethodExit('sendEmail', result: 'Failed');
        return false;
      }
    } on DioException catch (e) {
      print('🔥 [SEND EMAIL] DioException occurred: ${e.toString()}');
      _apiLogger.logFailure('sendEmail', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('sendEmail', result: 'Dio error');
      return false;
    } catch (e) {
      print('🔥 [SEND EMAIL] Exception occurred: ${e.toString()}');
      _apiLogger.logFailure('sendEmail', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('sendEmail',
          result: 'Exception: ${e.toString()}');
      return false;
    }
  }

  // Method untuk create wallet
  Future<dynamic> createWallet(
      CreateWalletRequestModel request, String userId) async {
    _apiLogger.logMethodEntry('createWallet', parameters: {
      'tenant_name': request.tenantName,
      'tenant_external_id': request.tenantExternalId,
      'chain': request.chain,
      'label': request.label,
      'custody': request.custody,
      'user_id': userId,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.post(
        'http://149.88.65.193:8010/api/wallet',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'id_user': userId,
          },
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200 &&
          data['data'] != null &&
          data['data']['ok'] == true) {
        _apiLogger.logSuccess('createWallet', 'Wallet created successfully');
        _apiLogger.logMethodExit('createWallet', result: 'Success');
        return CreateWalletResponseModel.fromJson(data);
      } else {
        _apiLogger.logFailure('createWallet', 'Failed to create wallet',
            error: data['message'] ?? 'Unknown error');
        _apiLogger.logMethodExit('createWallet', result: 'Failed');
        return CreateWalletErrorModel(
            error: data['message'] ?? 'Failed to create wallet');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('createWallet', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('createWallet', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('createWallet', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('createWallet', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('createWallet', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('createWallet',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to create wallet: ${e.toString()}');
    }
  }

  // Method untuk create card
  Future<dynamic> createCard(
      Map<String, dynamic> cardData, String userId) async {
    _apiLogger.logMethodEntry('createCard', parameters: {
      'card_data': cardData,
      'user_id': userId,
    });

    try {
      final response = await dio.post(
        'http://149.88.65.193:8010/api/card',
        data: cardData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'id_user': userId,
          },
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200) {
        _apiLogger.logSuccess('createCard', 'Card created successfully');
        _apiLogger.logMethodExit('createCard', result: 'Success');
        return data; // Return the response data
      } else {
        _apiLogger.logFailure('createCard', 'Failed to create card',
            error: data['errstr'] ?? 'Unknown error');
        _apiLogger.logMethodExit('createCard', result: 'Failed');
        throw Exception(data['errstr'] ?? 'Failed to create card');
      }
    } on DioException catch (e) {
      _apiLogger.logFailure('createCard', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('createCard', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('createCard', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('createCard',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to create card: ${e.toString()}');
    }
  }

  // Method untuk get chat history
  Future<ChatHistoryResponse> getChatHistory(
      int userId, int page, int limit) async {
    _apiLogger.logMethodEntry('getChatHistory', parameters: {
      'user_id': userId,
      'page': page,
      'limit': limit,
    });

    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw UnauthorizedException('No access token available');
      }

      final response = await dio.get(
        'http://149.88.65.193:8010/api/chat/history/$userId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = handleResponse(response);
      if (data['code'] == 200) {
        _apiLogger.logSuccess(
            'getChatHistory', 'Chat history retrieved successfully');
        _apiLogger.logMethodExit('getChatHistory', result: 'Success');
        return ChatHistoryResponse.fromJson(data);
      } else {
        _apiLogger.logFailure(
            'getChatHistory', 'Failed to retrieve chat history',
            error: data['message']);
        _apiLogger.logMethodExit('getChatHistory', result: 'Failed');
        throw Exception(data['message'] ?? 'Failed to retrieve chat history');
      }
    } on UnauthorizedException catch (e) {
      _apiLogger.logFailure('getChatHistory', 'Unauthorized',
          error: e.toString());
      _apiLogger.logMethodExit('getChatHistory', result: 'Unauthorized');
      throw e;
    } on DioException catch (e) {
      _apiLogger.logFailure('getChatHistory', 'Dio error', error: e.toString());
      _apiLogger.logMethodExit('getChatHistory', result: 'Dio error');
      throw handleDioError(e);
    } catch (e) {
      _apiLogger.logFailure('getChatHistory', 'Exception occurred',
          error: e.toString());
      _apiLogger.logMethodExit('getChatHistory',
          result: 'Exception: ${e.toString()}');
      throw Exception('Failed to retrieve chat history: ${e.toString()}');
    }
  }
}
