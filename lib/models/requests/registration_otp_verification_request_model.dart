// Model untuk request registration OTP verification
class RegistrationOtpVerificationRequestModel {
  final String email;
  final String otpCode;

  RegistrationOtpVerificationRequestModel({
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
