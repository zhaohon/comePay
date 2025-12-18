// Model untuk response change email sukses
class ChangeEmailResponseModel {
  final String message;
  final String newEmail;
  final String nextStep;
  final String otp;
  final String status;

  ChangeEmailResponseModel({
    required this.message,
    required this.newEmail,
    required this.nextStep,
    required this.otp,
    required this.status,
  });

  factory ChangeEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangeEmailResponseModel(
      message: json['message'] ?? '',
      newEmail: json['new_email'] ?? '',
      nextStep: json['next_step'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'new_email': newEmail,
      'next_step': nextStep,
      'otp': otp,
      'status': status,
    };
  }
}
