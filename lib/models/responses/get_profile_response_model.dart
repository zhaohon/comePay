import 'package:hive/hive.dart';

part 'get_profile_response_model.g.dart';

// Model untuk data user profile (extended from UserModel)
@HiveType(typeId: 2)
class ProfileUserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String accountType;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String walletId;

  @HiveField(8)
  final int kycLevel;

  @HiveField(9)
  final String kycStatus;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final String referralCode;

  @HiveField(12)
  final String? dateOfBirth;

  @HiveField(13)
  final bool isActive;

  @HiveField(14)
  final String referredBy;

  @HiveField(15)
  final bool twoFactorEnabled;

  @HiveField(16)
  final DateTime updatedAt;

  @HiveField(17)
  final String? address;

  @HiveField(18)
  final String? areaCode;

  @HiveField(19)
  final String? billCountryCode;

  @HiveField(20)
  final String? city;

  @HiveField(21)
  final String? postCode;

  @HiveField(22)
  final String? state;

  ProfileUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.accountType,
    required this.status,
    required this.walletId,
    required this.kycLevel,
    required this.kycStatus,
    required this.createdAt,
    required this.referralCode,
    this.dateOfBirth,
    required this.isActive,
    required this.referredBy,
    required this.twoFactorEnabled,
    required this.updatedAt,
    this.address,
    this.areaCode,
    this.billCountryCode,
    this.city,
    this.postCode,
    this.state,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      accountType: json['account_type'] ?? '',
      status: json['status'] ?? '',
      walletId: json['wallet_id'] ?? '',
      kycLevel: json['kyc_level'] ?? 0,
      kycStatus: json['kyc_status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      referralCode: json['referral_code'] ?? '',
      dateOfBirth: json['date_of_birth'],
      isActive: json['is_active'] ?? true,
      referredBy: json['referred_by'] ?? '',
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      address: json['address'] ?? 'Default Address',
      areaCode: json['area_code'] ?? '86',
      billCountryCode: json['bill_country_code'] ?? 'CN',
      city: json['city'] ?? 'Default City',
      postCode: json['post_code'] ?? '000000',
      state: json['state'] ?? 'Default State',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'account_type': accountType,
      'status': status,
      'wallet_id': walletId,
      'kyc_level': kycLevel,
      'kyc_status': kycStatus,
      'created_at': createdAt.toIso8601String(),
      'referral_code': referralCode,
      'date_of_birth': dateOfBirth,
      'is_active': isActive,
      'referred_by': referredBy,
      'two_factor_enabled': twoFactorEnabled,
      'updated_at': updatedAt.toIso8601String(),
      'address': address,
      'area_code': areaCode,
      'bill_country_code': billCountryCode,
      'city': city,
      'post_code': postCode,
      'state': state,
    };
  }
}

// Model untuk response get profile sukses
@HiveType(typeId: 3)
class GetProfileResponseModel {
  @HiveField(0)
  final String status;

  @HiveField(1)
  final ProfileUserModel user;

  GetProfileResponseModel({
    required this.status,
    required this.user,
  });

  factory GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return GetProfileResponseModel(
      status: json['status'] ?? '',
      user: ProfileUserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'user': user.toJson(),
    };
  }
}

// Model untuk response get profile error
class GetProfileErrorModel {
  final String error;

  GetProfileErrorModel({
    required this.error,
  });

  factory GetProfileErrorModel.fromJson(Map<String, dynamic> json) {
    return GetProfileErrorModel(
      error: json['error'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
