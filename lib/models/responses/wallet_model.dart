class WalletModel {
  final int id;
  final int userId;
  final double balance;
  final double frozenBalance;
  final String currency;
  final String status;
  final double dailyLimit;
  final double monthlyLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.frozenBalance,
    required this.currency,
    required this.status,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      frozenBalance: (json['frozen_balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      dailyLimit: (json['daily_limit'] ?? 0).toDouble(),
      monthlyLimit: (json['monthly_limit'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime(1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'frozen_balance': frozenBalance,
      'currency': currency,
      'status': status,
      'daily_limit': dailyLimit,
      'monthly_limit': monthlyLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
