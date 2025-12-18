// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetPasswordUserModelAdapter extends TypeAdapter<SetPasswordUserModel> {
  @override
  final int typeId = 2;

  @override
  SetPasswordUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetPasswordUserModel(
      id: fields[0] as int,
      email: fields[1] as String,
      accountType: fields[2] as String,
      status: fields[3] as String,
      walletId: fields[4] as String,
      kycLevel: fields[5] as int,
      kycStatus: fields[6] as String,
      createdAt: fields[7] as DateTime,
      referralCode: fields[8] as String,
      firstName: fields[9] as String?,
      lastName: fields[10] as String?,
      phone: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SetPasswordUserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.accountType)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.walletId)
      ..writeByte(5)
      ..write(obj.kycLevel)
      ..writeByte(6)
      ..write(obj.kycStatus)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.referralCode)
      ..writeByte(9)
      ..write(obj.firstName)
      ..writeByte(10)
      ..write(obj.lastName)
      ..writeByte(11)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetPasswordUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetPasswordResponseModelAdapter
    extends TypeAdapter<SetPasswordResponseModel> {
  @override
  final int typeId = 3;

  @override
  SetPasswordResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetPasswordResponseModel(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      message: fields[2] as String,
      nextStep: fields[3] as String,
      status: fields[4] as String,
      user: fields[5] as SetPasswordUserModel,
    );
  }

  @override
  void write(BinaryWriter writer, SetPasswordResponseModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.nextStep)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetPasswordResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetPasswordErrorModelAdapter extends TypeAdapter<SetPasswordErrorModel> {
  @override
  final int typeId = 4;

  @override
  SetPasswordErrorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetPasswordErrorModel(
      error: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SetPasswordErrorModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetPasswordErrorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
