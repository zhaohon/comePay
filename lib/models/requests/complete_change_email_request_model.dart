// Model untuk request complete change email
class CompleteChangeEmailRequestModel {
  final String newEmail;
  final String oldEmailOtp;

  CompleteChangeEmailRequestModel({
    required this.newEmail,
    required this.oldEmailOtp,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
      'old_email_otp': oldEmailOtp,
    };
  }
}
