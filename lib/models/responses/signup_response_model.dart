// Model untuk response signup sukses
class SignupResponseModel {
  final String email;
  final String message;
  final String otp;
  final String status;
  final String walletId;

  SignupResponseModel({
    required this.email,
    required this.message,
    required this.otp,
    required this.status,
    required this.walletId,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
      walletId: json['wallet_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'otp': otp,
      'status': status,
      'wallet_id': walletId,
    };
  }
}
