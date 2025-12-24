class KycEligibilityModel {
  final bool eligible;
  final String paymentStatus; // none | completed
  final String reason;
  final String requiredAction; // create_payment

  KycEligibilityModel({
    required this.eligible,
    required this.paymentStatus,
    required this.reason,
    required this.requiredAction,
  });

  factory KycEligibilityModel.fromJson(Map<String, dynamic> json) {
    return KycEligibilityModel(
      eligible: json['eligible'] ?? false,
      paymentStatus: json['payment_status'] ?? '',
      reason: json['reason'] ?? '',
      requiredAction: json['required_action'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'payment_status': paymentStatus,
      'reason': reason,
      'required_action': requiredAction,
    };
  }
}
