class TransactionPasswordResponseModel {
  final String email;
  final String message;
  final String nextStep;
  final String otp;
  final String status;
  final String tempHash;

  TransactionPasswordResponseModel({
    required this.email,
    required this.message,
    required this.nextStep,
    required this.otp,
    required this.status,
    required this.tempHash,
  });

  factory TransactionPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionPasswordResponseModel(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      nextStep: json['next_step'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
      tempHash: json['temp_hash'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'next_step': nextStep,
      'otp': otp,
      'status': status,
      'temp_hash': tempHash,
    };
  }
}
