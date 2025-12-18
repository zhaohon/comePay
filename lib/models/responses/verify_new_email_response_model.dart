// Model untuk response verify new email sukses
class VerifyNewEmailResponseModel {
  final String currentEmail;
  final String message;
  final String nextStep;
  final String otp;
  final String status;

  VerifyNewEmailResponseModel({
    required this.currentEmail,
    required this.message,
    required this.nextStep,
    required this.otp,
    required this.status,
  });

  factory VerifyNewEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyNewEmailResponseModel(
      currentEmail: json['current_email'] ?? '',
      message: json['message'] ?? '',
      nextStep: json['next_step'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_email': currentEmail,
      'message': message,
      'next_step': nextStep,
      'otp': otp,
      'status': status,
    };
  }
}
