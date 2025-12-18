import 'package:hive/hive.dart';

part 'set_password_response_model.g.dart';

// Model untuk data user (similar to LoginResponseModel)
@HiveType(typeId: 2)
class SetPasswordUserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String accountType;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String walletId;

  @HiveField(5)
  final int kycLevel;

  @HiveField(6)
  final String kycStatus;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String referralCode;

  @HiveField(9)
  final String? firstName;

  @HiveField(10)
  final String? lastName;

  @HiveField(11)
  final String? phone;

  SetPasswordUserModel({
    required this.id,
    required this.email,
    required this.accountType,
    required this.status,
    required this.walletId,
    required this.kycLevel,
    required this.kycStatus,
    required this.createdAt,
    required this.referralCode,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory SetPasswordUserModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordUserModel(
      id: json['id'],
      email: json['email'],
      accountType: json['account_type'],
      status: json['status'],
      walletId: json['wallet_id'],
      kycLevel: json['kyc_level'],
      kycStatus: json['kyc_status'],
      createdAt: DateTime.parse(json['created_at']),
      referralCode: json['referral_code'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'account_type': accountType,
      'status': status,
      'wallet_id': walletId,
      'kyc_level': kycLevel,
      'kyc_status': kycStatus,
      'created_at': createdAt.toIso8601String(),
      'referral_code': referralCode,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }
}

// Model untuk response set-password sukses
@HiveType(typeId: 3)
class SetPasswordResponseModel {
  @HiveField(0)
  final String accessToken;

  @HiveField(1)
  final String refreshToken;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String nextStep;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final SetPasswordUserModel user;

  SetPasswordResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.nextStep,
    required this.status,
    required this.user,
  });

  factory SetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      message: json['message'],
      nextStep: json['next_step'],
      status: json['status'],
      user: SetPasswordUserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'message': message,
      'next_step': nextStep,
      'status': status,
      'user': user.toJson(),
    };
  }
}

// Model untuk response set-password error
@HiveType(typeId: 4)
class SetPasswordErrorModel {
  @HiveField(0)
  final String error;

  SetPasswordErrorModel({required this.error});

  factory SetPasswordErrorModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordErrorModel(error: json['error']);
  }

  Map<String, dynamic> toJson() {
    return {'error': error};
  }
}
