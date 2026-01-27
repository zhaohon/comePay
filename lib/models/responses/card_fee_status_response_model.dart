class CardFeeStatusResponseModel {
  final bool hasPayment;
  final String paymentStatus;
  final String status;

  CardFeeStatusResponseModel({
    required this.hasPayment,
    required this.paymentStatus,
    required this.status,
  });

  factory CardFeeStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return CardFeeStatusResponseModel(
      hasPayment: json['has_payment'] ?? false,
      paymentStatus: json['payment_status'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
