// Model untuk request verify new email OTP
class VerifyNewEmailRequestModel {
  final String newEmail;
  final String otpCode;

  VerifyNewEmailRequestModel({
    required this.newEmail,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
      'otp_code': otpCode,
    };
  }
}
