// Model untuk response registration OTP verification success
class RegistrationOtpVerificationResponseModel {
  final String email;
  final String message;
  final String nextStep;
  final String referralCode;
  final String status;

  RegistrationOtpVerificationResponseModel({
    required this.email,
    required this.message,
    required this.nextStep,
    required this.referralCode,
    required this.status,
  });

  factory RegistrationOtpVerificationResponseModel.fromJson(
      Map<String, dynamic> json) {
    return RegistrationOtpVerificationResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      nextStep: json['next_step'] ?? '',
      referralCode: json['referral_code'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'next_step': nextStep,
      'referral_code': referralCode,
      'status': status,
    };
  }
}
