// Model for Reset Password OTP Verification request
class ResetPasswordOtpVerificationRequestModel {
  final String email;
  final String otpCode;

  ResetPasswordOtpVerificationRequestModel({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
    };
  }
}
