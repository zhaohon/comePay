class CardFeePaymentModel {
  final int id;
  final int userId;
  final String cardType;
  final double originalFee;
  final double couponDiscount;
  final double actualPayment;
  final String status; // pending | completed
  final String transactionRef;
  final String? paymentMethod;
  final String? couponCode;
  final String? couponName;
  final DateTime? paidAt;
  final DateTime createdAt;

  CardFeePaymentModel({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.originalFee,
    required this.couponDiscount,
    required this.actualPayment,
    required this.status,
    required this.transactionRef,
    this.paymentMethod,
    this.couponCode,
    this.couponName,
    this.paidAt,
    required this.createdAt,
  });

  factory CardFeePaymentModel.fromJson(Map<String, dynamic> json) {
    return CardFeePaymentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      cardType: json['card_type'] ?? '',
      originalFee: (json['original_fee'] ?? 0).toDouble(),
      couponDiscount: (json['coupon_discount'] ?? 0).toDouble(),
      actualPayment: (json['actual_payment'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
      paymentMethod: json['payment_method'],
      couponCode: json['coupon_code'],
      couponName: json['coupon_name'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_type': cardType,
      'original_fee': originalFee,
      'coupon_discount': couponDiscount,
      'actual_payment': actualPayment,
      'status': status,
      'transaction_ref': transactionRef,
      'payment_method': paymentMethod,
      'coupon_code': couponCode,
      'coupon_name': couponName,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
