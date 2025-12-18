// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileUserModelAdapter extends TypeAdapter<ProfileUserModel> {
  @override
  final int typeId = 2;

  @override
  ProfileUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileUserModel(
      id: fields[0] as int,
      email: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      phone: fields[4] as String?,
      accountType: fields[5] as String,
      status: fields[6] as String,
      walletId: fields[7] as String,
      kycLevel: fields[8] as int,
      kycStatus: fields[9] as String,
      createdAt: fields[10] as DateTime,
      referralCode: fields[11] as String,
      dateOfBirth: fields[12] as String?,
      isActive: fields[13] as bool,
      referredBy: fields[14] as String,
      twoFactorEnabled: fields[15] as bool,
      updatedAt: fields[16] as DateTime,
      address: fields[17] as String?,
      areaCode: fields[18] as String?,
      billCountryCode: fields[19] as String?,
      city: fields[20] as String?,
      postCode: fields[21] as String?,
      state: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileUserModel obj) {
    writer
      ..writeByte(23)
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
      ..write(obj.referralCode)
      ..writeByte(12)
      ..write(obj.dateOfBirth)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.referredBy)
      ..writeByte(15)
      ..write(obj.twoFactorEnabled)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.address)
      ..writeByte(18)
      ..write(obj.areaCode)
      ..writeByte(19)
      ..write(obj.billCountryCode)
      ..writeByte(20)
      ..write(obj.city)
      ..writeByte(21)
      ..write(obj.postCode)
      ..writeByte(22)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GetProfileResponseModelAdapter
    extends TypeAdapter<GetProfileResponseModel> {
  @override
  final int typeId = 3;

  @override
  GetProfileResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GetProfileResponseModel(
      status: fields[0] as String,
      user: fields[1] as ProfileUserModel,
    );
  }

  @override
  void write(BinaryWriter writer, GetProfileResponseModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetProfileResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
