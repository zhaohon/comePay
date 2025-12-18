// Model untuk response registration OTP verification error
class RegistrationOtpVerificationErrorModel {
  final String error;

  RegistrationOtpVerificationErrorModel({
    required this.error,
  });

  factory RegistrationOtpVerificationErrorModel.fromJson(
      Map<String, dynamic> json) {
    return RegistrationOtpVerificationErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
