class CompleteTransactionPasswordRequestModel {
  final String otpCode;
  final String tempHash;

  CompleteTransactionPasswordRequestModel({
    required this.otpCode,
    required this.tempHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp_code': otpCode,
      'temp_hash': tempHash,
    };
  }
}
