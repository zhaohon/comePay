// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verification_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OtpVerificationResponseModelAdapter
    extends TypeAdapter<OtpVerificationResponseModel> {
  @override
  final int typeId = 2;

  @override
  OtpVerificationResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtpVerificationResponseModel(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      message: fields[2] as String,
      status: fields[3] as String,
      user: fields[4] as UserModel,
    );
  }

  @override
  void write(BinaryWriter writer, OtpVerificationResponseModel obj) {
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
      other is OtpVerificationResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
