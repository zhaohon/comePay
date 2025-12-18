// Model untuk request complete change phone
class CompleteChangePhoneRequestModel {
  final String newPhone;
  final String emailOtp;

  CompleteChangePhoneRequestModel({
    required this.newPhone,
    required this.emailOtp,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_phone': newPhone,
      'email_otp': emailOtp,
    };
  }
}
