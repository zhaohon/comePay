// Model untuk request verify new phone
class VerifyNewPhoneRequestModel {
  final String email;
  final String newPhone;
  final String otpCode;

  VerifyNewPhoneRequestModel({
    required this.email,
    required this.newPhone,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'new_phone': newPhone,
      'otp_code': otpCode,
    };
  }
}
