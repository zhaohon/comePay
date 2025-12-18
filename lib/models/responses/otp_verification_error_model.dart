// Model untuk response OTP verification error
class OtpVerificationErrorModel {
  final String error;

  OtpVerificationErrorModel({
    required this.error,
  });

  factory OtpVerificationErrorModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationErrorModel(
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
