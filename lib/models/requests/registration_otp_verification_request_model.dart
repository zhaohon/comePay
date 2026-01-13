// Model untuk request registration OTP verification
class RegistrationOtpVerificationRequestModel {
  final String email;
  final String otpCode;
  final String? referralCode;

  RegistrationOtpVerificationRequestModel({
    required this.email,
    required this.otpCode,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'email': email,
      'otp_code': otpCode,
    };

    if (referralCode != null && referralCode!.isNotEmpty) {
      json['referral_code'] = referralCode;
    }

    return json;
  }
}
