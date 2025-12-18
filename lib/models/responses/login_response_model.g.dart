// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      email: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      phone: fields[4] as String,
      accountType: fields[5] as String,
      status: fields[6] as String,
      walletId: fields[7] as String,
      kycLevel: fields[8] as int,
      kycStatus: fields[9] as String,
      createdAt: fields[10] as DateTime,
      referralCode: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.accountType)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.walletId)
      ..writeByte(8)
      ..write(obj.kycLevel)
      ..writeByte(9)
      ..write(obj.kycStatus)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.referralCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoginResponseModelAdapter extends TypeAdapter<LoginResponseModel> {
  @override
  final int typeId = 1;

  @override
  LoginResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginResponseModel(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      message: fields[2] as String,
      status: fields[3] as String,
      user: fields[4] as UserModel?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginResponseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
