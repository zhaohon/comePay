// Model untuk response email validation sukses
class EmailValidationResponseModel {
  final String email;
  final String message;
  final String otp;
  final String status;

  EmailValidationResponseModel({
    required this.email,
    required this.message,
    required this.otp,
    required this.status,
  });

  factory EmailValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return EmailValidationResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'otp': otp,
      'status': status,
    };
  }
}
