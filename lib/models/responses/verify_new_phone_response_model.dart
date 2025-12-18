// Model untuk response verify new phone
class VerifyNewPhoneResponseModel {
  final String email;
  final String message;
  final String nextStep;
  final String otp;
  final String status;

  VerifyNewPhoneResponseModel({
    required this.email,
    required this.message,
    required this.nextStep,
    required this.otp,
    required this.status,
  });

  factory VerifyNewPhoneResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyNewPhoneResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      nextStep: json['next_step'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'next_step': nextStep,
      'otp': otp,
      'status': status,
    };
  }
}
