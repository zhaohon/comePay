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
      _apiLogger.logMethodExit('login', result: '  ${e.toString()}');
      return LoginErrorResponse(e.toString());
    }
  }

  Future<dynamic> verifyResetPasswordOtp(
      ResetPasswordOtpVerificationRequestModel request) async {
    _apiLogger.logMethodEntry('verifyResetPasswordOtp', parameters: {
      'email': request.email,
    });

    try {
      final response = await post(
        '/auth/verify-forgot-password-otp',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('verifyResetPasswordOtp', result: 'Success');
      return response;
    } catch (e) {
      _apiLogger.logMethodExit('verifyResetPasswordOtp', result: 'Error: $e');
      return {'error': e.toString()};
    }
  }

  // Method untuk refresh token (opsional)
  Future<dynamic> refreshToken(String refreshToken) async {
    _apiLogger.logMethodEntry('refreshToken');
    try {
      final response = await post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      _apiLogger.logMethodExit('refreshToken', result: 'Success');
      return LoginResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('refreshToken', result: 'Error: $e');
      return LoginErrorModel(error: e.toString());
    }
  }

  // Method untuk logout
  Future<dynamic> logout(String accessToken) async {
    _apiLogger.logMethodEntry('logout');
    try {
      await post(
        '/auth/logout',
        data: {'access_token': accessToken},
      );
      _apiLogger.logMethodExit('logout', result: 'Success');
      return {'message': 'Logout successful'};
    } catch (e) {
      _apiLogger.logMethodExit('logout', result: 'Error: $e');
      return LoginErrorModel(error: e.toString());
    }
  }

  // Method untuk register
  Future<dynamic> register(Map<String, dynamic> userData) async {
    _apiLogger.logMethodEntry('register', parameters: {
      'email': userData['email'] ?? 'N/A',
    });

    try {
      await post(
        '/auth/register',
        data: userData,
      );
      _apiLogger.logMethodExit('register', result: 'Success');
      return {'message': 'Registration successful'};
    } catch (e) {
      _apiLogger.logMethodExit('register', result: 'Error: $e');
      return LoginErrorModel(error: e.toString());
    }
  }

  // Method untuk forgot password
  Future<dynamic> forgotPassword(String email) async {
    _apiLogger.logMethodEntry('forgotPassword', parameters: {'email': email});
    try {
      final response = await post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      _apiLogger.logMethodExit('forgotPassword', result: 'Success');
      return response;
    } catch (e) {
      _apiLogger.logMethodExit('forgotPassword', result: 'Error: $e');
      return ForgotPasswordErrorModel(error: e.toString());
    }
  }

  // Method untuk reset password
  Future<dynamic> resetPassword(String token, String newPassword) async {
    _apiLogger.logMethodEntry('resetPassword');
    try {
      await post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );
      _apiLogger.logMethodExit('resetPassword', result: 'Success');
      return {'message': 'Password reset successful'};
    } catch (e) {
      _apiLogger.logMethodExit('resetPassword', result: 'Error: $e');
      return LoginErrorModel(error: e.toString());
    }
  }

  // Method untuk reset password create password
  Future<dynamic> resetPasswordCreatePassword(
      String email, String newPassword, String confirmPassword) async {
    _apiLogger.logMethodEntry('resetPasswordCreatePassword', parameters: {
      'email': email,
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
      _apiLogger.logMethodExit('resetPasswordCreatePassword',
          result: 'Success');
      return response;
    } catch (e) {
      _apiLogger.logMethodExit('resetPasswordCreatePassword',
          result: 'Error: $e');
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
      _apiLogger.logMethodExit('getUserProfile', result: '  ${e.toString()}');
      return LoginErrorModel(
        error: e.toString(),
      );
    }
  }

  // Method untuk update user profile
  Future<dynamic> updateUserProfile(
      String accessToken, Map<String, dynamic> profileData) async {
    _apiLogger.logMethodEntry('updateUserProfile');
    try {
      final response = await put(
        '/auth/profile',
        data: {
          'access_token': accessToken,
          ...profileData,
        },
      );
      _apiLogger.logMethodExit('updateUserProfile', result: 'Success');
      return response;
    } catch (e) {
      _apiLogger.logMethodExit('updateUserProfile', result: 'Error: $e');
      return LoginErrorModel(error: e.toString());
    }
  }

  // Method untuk OTP verification
  Future<dynamic> verifyOtp(OtpVerificationRequestModel request) async {
    _apiLogger
        .logMethodEntry('verifyOtp', parameters: {'email': request.email});
    try {
      final response = await post(
        '/auth/verify-login-otp',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('verifyOtp', result: 'Success');
      return OtpVerificationResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('verifyOtp', result: 'Error: $e');
      return OtpVerificationErrorModel(error: e.toString());
    }
  }

  // Method untuk signup
  Future<dynamic> signup(SignupRequestModel request) async {
    _apiLogger.logMethodEntry('signup', parameters: {'email': request.email});
    try {
      final response = await post(
        '/auth/signup',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('signup', result: 'Success');
      return SignupResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('signup', result: 'Error: $e');
      return SignupErrorModel(error: e.toString());
    }
  }

  // Method untuk email validation
  Future<dynamic> validateEmail(EmailValidationRequestModel request) async {
    _apiLogger
        .logMethodEntry('validateEmail', parameters: {'email': request.email});
    try {
      final response = await post(
        '/auth/signup',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('validateEmail', result: 'Success');
      return EmailValidationResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('validateEmail', result: 'Error: $e');
      return EmailValidationErrorModel(error: e.toString());
    }
  }

  // Method untuk verify registration OTP
  Future<dynamic> verifyRegistrationOtp(
      RegistrationOtpVerificationRequestModel request) async {
    _apiLogger.logMethodEntry('verifyRegistrationOtp',
        parameters: {'email': request.email});
    try {
      final response = await post(
        '/auth/verify',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('verifyRegistrationOtp', result: 'Success');
      return RegistrationOtpVerificationResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('verifyRegistrationOtp', result: 'Error: $e');
      return RegistrationOtpVerificationErrorModel(error: e.toString());
    }
  }

  // Method untuk set password
  Future<dynamic> setPassword(String email, String password,
      {String? referralCode}) async {
    _apiLogger.logMethodEntry('setPassword', parameters: {
      'email': email,
      'referral_code': referralCode ?? 'N/A',
    });

    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
        if (referralCode != null && referralCode.isNotEmpty)
          'referral_code': referralCode,
      };

      final response = await post(
        '/auth/set-password',
        data: data,
      );
      _apiLogger.logMethodExit('setPassword', result: 'Success');
      return SetPasswordResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('setPassword', result: 'Error: $e');
      return SetPasswordErrorModel(error: e.toString());
    }
  }

  // Method untuk resend OTP
  Future<dynamic> resendOtp(String email) async {
    _apiLogger.logMethodEntry('resendOtp', parameters: {'email': email});
    try {
      final response = await post(
        '/auth/resend-otp',
        data: {'email': email},
      );
      _apiLogger.logMethodExit('resendOtp', result: 'Success');
      return response;
    } catch (e) {
      _apiLogger.logMethodExit('resendOtp', result: 'Error: $e');
      return {'error': e.toString()};
    }
  }

  // Method untuk get user profile
  Future<dynamic> getProfile(String accessToken) async {
    _apiLogger.logMethodEntry('getProfile');
    return await get('/user/profile');
  }

  // Method untuk update user profile
  Future<dynamic> updateProfile(UpdateProfileRequestModel request) async {
    _apiLogger.logMethodEntry('updateProfile');
    try {
      final data = await put(
        '/user/profile',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('updateProfile', result: 'Success');
      return GetProfileResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('updateProfile', result: 'Error: $e');
      rethrow;
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
      final data = await get(
        '/coupons/my-coupons',
        queryParameters: {
          'status': status,
          'page': page,
          'limit': limit,
        },
      );
      _apiLogger.logMethodExit('getMyCoupons', result: 'Success');
      return CouponResponseModel.fromJson(data['data']);
    } catch (e) {
      _apiLogger.logMethodExit('getMyCoupons', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk get coupons (新API)
  Future<NewCouponResponseModel> getCoupons({bool onlyValid = true}) async {
    _apiLogger
        .logMethodEntry('getCoupons', parameters: {'only_valid': onlyValid});
    try {
      final data = await get(
        '/coupons/',
        queryParameters: {'only_valid': onlyValid},
      );
      _apiLogger.logMethodExit('getCoupons', result: 'Success');
      return NewCouponResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getCoupons', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk claim coupon
  Future<ClaimCouponResponseModel> claimCoupon(String couponCode) async {
    _apiLogger
        .logMethodEntry('claimCoupon', parameters: {'coupon_code': couponCode});
    try {
      final data = await post(
        '/coupons/claim',
        data: ClaimCouponRequestModel(couponCode: couponCode).toJson(),
      );
      _apiLogger.logMethodExit('claimCoupon', result: 'Success');
      return ClaimCouponResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('claimCoupon', result: 'Error: $e');
      throw CouponErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk change email request
  Future<dynamic> changeEmail(ChangeEmailRequestModel request) async {
    _apiLogger.logMethodEntry('changeEmail',
        parameters: {'new_email': request.newEmail});
    try {
      final data = await post(
        '/user/change-email/request',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('changeEmail', result: 'Success');
      return ChangeEmailResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('changeEmail', result: 'Error: $e');
      return ChangeEmailErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk verify new email OTP
  Future<dynamic> verifyNewEmail(VerifyNewEmailRequestModel request) async {
    _apiLogger.logMethodEntry('verifyNewEmail',
        parameters: {'new_email': request.newEmail});
    try {
      final data = await post(
        '/user/change-email/verify-new',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('verifyNewEmail', result: 'Success');
      return VerifyNewEmailResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('verifyNewEmail', result: 'Error: $e');
      return ChangeEmailErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk complete change email
  Future<dynamic> completeChangeEmail(
      CompleteChangeEmailRequestModel request) async {
    _apiLogger.logMethodEntry('completeChangeEmail');
    try {
      final data = await post(
        '/user/change-email/complete',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('completeChangeEmail', result: 'Success');
      return CompleteChangeEmailResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('completeChangeEmail', result: 'Error: $e');
      return ChangeEmailErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk change phone request
  Future<dynamic> changePhoneRequest(ChangePhoneRequestModel request) async {
    _apiLogger.logMethodEntry('changePhoneRequest',
        parameters: {'new_phone': request.newPhone});
    try {
      final data = await post(
        '/user/change-phone/request',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('changePhoneRequest', result: 'Success');
      return ChangePhoneResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('changePhoneRequest', result: 'Error: $e');
      return ChangePhoneErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk verify new phone
  Future<dynamic> verifyNewPhone(VerifyNewPhoneRequestModel request) async {
    _apiLogger.logMethodEntry('verifyNewPhone', parameters: {
      'email': request.email,
      'new_phone': request.newPhone,
    });

    try {
      final response = await post(
        '/user/change-phone/verify-new',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('verifyNewPhone', result: 'Success');
      return VerifyNewPhoneResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('verifyNewPhone', result: 'Error: $e');
      return ChangePhoneErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk complete change phone
  Future<dynamic> completeChangePhone(
      CompleteChangePhoneRequestModel request) async {
    _apiLogger.logMethodEntry('completeChangePhone', parameters: {
      'new_phone': request.newPhone,
    });

    try {
      final response = await post(
        '/user/change-phone/complete',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('completeChangePhone', result: 'Success');
      return CompleteChangePhoneResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('completeChangePhone', result: 'Error: $e');
      return CompleteChangePhoneErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk request transaction password
  Future<dynamic> requestTransactionPassword(
      TransactionPasswordRequestModel request) async {
    _apiLogger.logMethodEntry('requestTransactionPassword');
    try {
      final response = await post(
        '/user/transaction-password/request',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('requestTransactionPassword', result: 'Success');
      return TransactionPasswordResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('requestTransactionPassword',
          result: 'Error: $e');
      return TransactionPasswordErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk complete transaction password
  Future<dynamic> completeTransactionPassword(
      CompleteTransactionPasswordRequestModel request) async {
    _apiLogger.logMethodEntry('completeTransactionPassword');
    try {
      final response = await post(
        '/user/transaction-password/complete',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('completeTransactionPassword',
          result: 'Success');
      return CompleteTransactionPasswordResponseModel.fromJson(response);
    } catch (e) {
      _apiLogger.logMethodExit('completeTransactionPassword',
          result: 'Error: $e');
      return CompleteTransactionPasswordErrorModel.fromJson(
          {'error': e.toString()});
    }
  }

  // Method untuk change password
  Future<dynamic> changePassword(ChangePasswordRequestModel request) async {
    _apiLogger.logMethodEntry('changePassword');
    try {
      final data = await post(
        '/user/change-password',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('changePassword', result: 'Success');
      return ChangePasswordResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('changePassword', result: 'Error: $e');
      return ChangePasswordErrorModel.fromJson({'error': e.toString()});
    }
  }

  // Method untuk get chat inbox
  Future<ChatInboxResponseModel> getChatInbox(int page, int limit) async {
    _apiLogger.logMethodEntry('getChatInbox',
        parameters: {'page': page, 'limit': limit});
    try {
      final data = await get(
        '/chat/inbox',
        queryParameters: {'page': page, 'limit': limit},
      );
      _apiLogger.logMethodExit('getChatInbox', result: 'Success');
      return ChatInboxResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getChatInbox', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk send chat message
  Future<SendMessageResponseModel> sendChatMessage(
      SendMessageRequestModel request) async {
    _apiLogger.logMethodEntry('sendChatMessage');
    try {
      final data = await post(
        'http://149.88.65.193:8010/api/chat/send',
        data: request.toJson(),
      );
      _apiLogger.logMethodExit('sendChatMessage', result: 'Success');
      return SendMessageResponseModel.fromJson(data['data']);
    } catch (e) {
      _apiLogger.logMethodExit('sendChatMessage', result: 'Error: $e');
      rethrow;
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
      final data = await get(
        '/notifications/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      _apiLogger.logMethodExit('getNotifications', result: 'Success');
      return NotificationResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getNotifications',
          result: 'Error: ${e.toString()}');
      rethrow;
    }
  }

  // Method untuk get unread notification count
  Future<NotificationUnreadCountResponseModel>
      getUnreadNotificationCount() async {
    _apiLogger.logMethodEntry('getUnreadNotificationCount');
    try {
      final data = await get('/notifications/unread-count');
      _apiLogger.logMethodExit('getUnreadNotificationCount', result: 'Success');
      return NotificationUnreadCountResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getUnreadNotificationCount',
          result: 'Error: $e');
      rethrow;
    }
  }

  /// Get unread announcement count
  Future<NotificationUnreadCountResponseModel>
      getUnreadAnnouncementCount() async {
    _apiLogger.logMethodEntry('getUnreadAnnouncementCount');
    try {
      final data = await get('/announcements/unread-count');
      _apiLogger.logMethodExit('getUnreadAnnouncementCount', result: 'Success');
      return NotificationUnreadCountResponseModel.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getUnreadAnnouncementCount',
          result: 'Error: $e');
      rethrow;
    }
  }

  Future<CarddetailResponseModel> initGetCard(int kyc_id) async {
    _apiLogger.logMethodEntry('initGetCard', parameters: {'kyc_id': kyc_id});
    try {
      final data = await get(
        'http://149.88.65.193:8010/api/v1/card',
        queryParameters: {'kyc_id': kyc_id},
      );

      if (data['code'] == 200) {
        _apiLogger.logMethodExit('initGetCard', result: 'Success');
        return CarddetailResponseModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to retrieve card data');
      }
    } catch (e) {
      _apiLogger.logMethodExit('initGetCard', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk initialize Didit token
  Future<dynamic> initializeDiditToken(
      DiditInitializeTokenRequestModel request) async {
    _apiLogger.logMethodEntry('initializeDiditToken', parameters: {
      'email': request.email,
    });

    try {
      final data = await post(
        '/didit/initialize-token',
        data: request.toJson(),
      );

      if (data['didit_token'] != null) {
        _apiLogger.logMethodExit('initializeDiditToken', result: 'Success');
        return DiditInitializeTokenResponseModel.fromJson(data);
      } else {
        return DiditInitializeTokenErrorModel.fromJson(data);
      }
    } catch (e) {
      _apiLogger.logMethodExit('initializeDiditToken', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk get card data
  Future<CardResponseModel> getCardData(String userId) async {
    _apiLogger.logMethodEntry('getCardData', parameters: {'user_id': userId});
    try {
      final data = await get(
        'http://149.88.65.193:8010/api/card',
        options: Options(
          headers: {'id_user': userId},
        ),
      );

      if (data['code'] == 200) {
        _apiLogger.logMethodExit('getCardData', result: 'Success');
        return CardResponseModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to retrieve card data');
      }
    } catch (e) {
      _apiLogger.logMethodExit('getCardData', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk get transaction data
  Future<TransactionResponse> getTransactionData(String userId) async {
    _apiLogger
        .logMethodEntry('getTransactionData', parameters: {'user_id': userId});
    try {
      final data = await get(
        '/user/transactions',
        queryParameters: {'user_id': userId},
      );

      _apiLogger.logMethodExit('getTransactionData', result: 'Success');
      return TransactionResponse.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getTransactionData', result: 'Error: $e');
      rethrow;
    }
  }

  // Method untuk send email
  Future<bool> sendEmail(String email, String name, String otp,
      {bool isForgotPassword = false}) async {
    if (isForgotPassword) return true;

    _apiLogger.logMethodEntry('sendEmail', parameters: {'email': email});
    try {
      await post(
        'http://149.88.65.193:8010/api/v1/auth/verify-otp',
        data: {
          'email': email,
          'referral_code': '',
          'otp_code': otp,
        },
      );

      _apiLogger.logMethodExit('sendEmail', result: 'Success');
      return true;
    } catch (e) {
      _apiLogger.logMethodExit('sendEmail', result: 'Error: $e');
      return false;
    }
  }

  // Method untuk create wallet
  Future<dynamic> createWallet(
      CreateWalletRequestModel request, String userId) async {
    _apiLogger.logMethodEntry('createWallet', parameters: {'user_id': userId});
    try {
      final data = await post(
        'http://149.88.65.193:8010/api/wallet',
        data: request.toJson(),
        options: Options(
          headers: {'id_user': userId},
        ),
      );

      if (data['code'] == 200 &&
          data['data'] != null &&
          data['data']['ok'] == true) {
        _apiLogger.logMethodExit('createWallet', result: 'Success');
        return CreateWalletResponseModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to create wallet');
      }
    } catch (e) {
      _apiLogger.logMethodExit('createWallet', result: 'Error: $e');
      return CreateWalletErrorModel(error: e.toString());
    }
  }

  // Method untuk create card
  Future<dynamic> createCard(
      Map<String, dynamic> cardData, String userId) async {
    _apiLogger.logMethodEntry('createCard', parameters: {'user_id': userId});
    try {
      final data = await post(
        'http://149.88.65.193:8010/api/card',
        data: cardData,
        options: Options(
          headers: {'id_user': userId},
        ),
      );

      if (data['code'] == 200) {
        _apiLogger.logMethodExit('createCard', result: 'Success');
        return data;
      } else {
        throw Exception(data['errstr'] ?? 'Failed to create card');
      }
    } catch (e) {
      _apiLogger.logMethodExit('createCard', result: 'Error: $e');
      rethrow;
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
      final data = await get(
        'http://149.88.65.193:8010/api/chat/history/$userId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      _apiLogger.logMethodExit('getChatHistory', result: 'Success');
      return ChatHistoryResponse.fromJson(data);
    } catch (e) {
      _apiLogger.logMethodExit('getChatHistory', result: 'Error: $e');
      rethrow;
    }
  }
}
