import 'wallet_model.dart';

class UserModel {
  final int id;
  final String walletId;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String accountType;
  final String status;
  final String kycStatus;
  final int kycLevel;
  final bool twoFactorEnabled;
  final String referralCode;
  final String referredBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WalletModel wallet;

  UserModel({
    required this.id,
    required this.walletId,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    required this.accountType,
    required this.status,
    required this.kycStatus,
    required this.kycLevel,
    required this.twoFactorEnabled,
    required this.referralCode,
    required this.referredBy,
    required this.createdAt,
    required this.updatedAt,
    required this.wallet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      accountType: json['account_type'] ?? '',
      status: json['status'] ?? '',
      kycStatus: json['kyc_status'] ?? '',
      kycLevel: json['kyc_level'] ?? 0,
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
      referralCode: json['referral_code'] ?? '',
      referredBy: json['referred_by'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime(1),
      wallet: WalletModel.fromJson(json['wallet'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'account_type': accountType,
      'status': status,
      'kyc_status': kycStatus,
      'kyc_level': kycLevel,
      'two_factor_enabled': twoFactorEnabled,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'wallet': wallet.toJson(),
    };
  }
}
