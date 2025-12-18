class ForgotPasswordResponseModel {
  final String email;
  final String message;
  final String otp;
  final String status;
  final String? name;

  ForgotPasswordResponseModel({
    required this.email,
    required this.message,
    required this.otp,
    required this.status,
    this.name,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'otp': otp,
      'status': status,
      if (name != null) 'name': name,
    };
  }
}
