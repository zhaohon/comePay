import 'package:hive/hive.dart';
import 'package:Demo/models/responses/login_response_model.dart';

part 'otp_verification_response_model.g.dart';

// Model untuk response OTP verification sukses
@HiveType(typeId: 2)
class OtpVerificationResponseModel {
  @HiveField(0)
  final String accessToken;

  @HiveField(1)
  final String refreshToken;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final UserModel user;

  OtpVerificationResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.status,
    required this.user,
  });

  factory OtpVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      message: json['message'],
      status: json['status'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'message': message,
      'status': status,
      'user': user.toJson(),
    };
  }
}
