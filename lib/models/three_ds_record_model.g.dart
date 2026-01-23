// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_ds_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeDSRecordModel _$ThreeDSRecordModelFromJson(Map<String, dynamic> json) =>
    ThreeDSRecordModel(
      id: (json['id'] as num).toInt(),
      merchantName: json['merchant_name'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      passcode: json['passcode'] as String,
      receivedAt: json['received_at'] as String,
      expiresAfter: (json['expires_after'] as num).toInt(),
    );

Map<String, dynamic> _$ThreeDSRecordModelToJson(ThreeDSRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchant_name': instance.merchantName,
      'amount': instance.amount,
      'currency': instance.currency,
      'passcode': instance.passcode,
      'received_at': instance.receivedAt,
      'expires_after': instance.expiresAfter,
    };

GetThreeDSRecordsResponse _$GetThreeDSRecordsResponseFromJson(
        Map<String, dynamic> json) =>
    GetThreeDSRecordsResponse(
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      records: (json['records'] as List<dynamic>)
          .map((e) => ThreeDSRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetThreeDSRecordsResponseToJson(
        GetThreeDSRecordsResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'page_size': instance.pageSize,
      'total': instance.total,
      'total_pages': instance.totalPages,
      'records': instance.records,
    };
