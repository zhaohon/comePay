class CardFeeConfigModel {
  final int id;
  final String cardType; // virtual | physical
  final String feeType; // flat
  final double feeAmount;
  final bool isActive;
  final String description;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardFeeConfigModel({
    required this.id,
    required this.cardType,
    required this.feeType,
    required this.feeAmount,
    required this.isActive,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardFeeConfigModel.fromJson(Map<String, dynamic> json) {
    return CardFeeConfigModel(
      id: json['id'] ?? 0,
      cardType: json['card_type'] ?? '',
      feeType: json['fee_type'] ?? '',
      feeAmount: (json['fee_amount'] ?? 0).toDouble(),
      isActive: json['IsActive'] ?? false,
      description: json['description'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_type': cardType,
      'fee_type': feeType,
      'fee_amount': feeAmount,
      'IsActive': isActive,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
