class ResetPasswordOtpVerificationResponseModel {
  final String? email;
  final String? message;
  final String? nextStep;
  final String? status;
  final String? error;

  ResetPasswordOtpVerificationResponseModel({
    this.email,
    this.message,
    this.nextStep,
    this.status,
    this.error,
  });

  factory ResetPasswordOtpVerificationResponseModel.fromJson(
      Map<String, dynamic> json) {
    return ResetPasswordOtpVerificationResponseModel(
      email: json['email'],
      message: json['message'],
      nextStep: json['next_step'],
      status: json['status'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'next_step': nextStep,
      'status': status,
      'error': error,
    };
  }
}
