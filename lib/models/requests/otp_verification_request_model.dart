// Model untuk request OTP verification
class OtpVerificationRequestModel {
  final String email;
  final String otpCode;

  OtpVerificationRequestModel({
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
