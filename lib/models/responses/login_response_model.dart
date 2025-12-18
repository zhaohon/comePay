import 'package:hive/hive.dart';

part 'login_response_model.g.dart';

// Model untuk data user
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String phone;

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

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.accountType,
    required this.status,
    required this.walletId,
    required this.kycLevel,
    required this.kycStatus,
    required this.createdAt,
    required this.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      accountType: json['account_type'] ?? '',
      status: json['status'] ?? '',
      walletId: json['wallet_id'] ?? '',
      kycLevel: json['kyc_level'] ?? 0,
      kycStatus: json['kyc_status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      referralCode: json['referral_code'] ?? '',
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
    };
  }
}

// Model untuk response login sukses
@HiveType(typeId: 1)
class LoginResponseModel {
  @HiveField(0)
  final String accessToken;

  @HiveField(1)
  final String refreshToken;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final UserModel? user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.status,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      message: json['message'],
      status: json['status'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'message': message,
      'status': status,
      'user': user?.toJson(),
    };
  }
}
