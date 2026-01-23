import 'package:json_annotation/json_annotation.dart';

part 'three_ds_record_model.g.dart';

@JsonSerializable()
class ThreeDSRecordModel {
  final int id;
  @JsonKey(name: 'merchant_name')
  final String merchantName;
  final String amount;
  final String currency;
  final String passcode;
  @JsonKey(name: 'received_at')
  final String receivedAt;
  @JsonKey(name: 'expires_after')
  final int expiresAfter;

  ThreeDSRecordModel({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.currency,
    required this.passcode,
    required this.receivedAt,
    required this.expiresAfter,
  });

  factory ThreeDSRecordModel.fromJson(Map<String, dynamic> json) =>
      _$ThreeDSRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreeDSRecordModelToJson(this);
}

@JsonSerializable()
class GetThreeDSRecordsResponse {
  final int page;
  @JsonKey(name: 'page_size')
  final int pageSize;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final List<ThreeDSRecordModel> records;

  GetThreeDSRecordsResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.records,
  });

  factory GetThreeDSRecordsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetThreeDSRecordsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetThreeDSRecordsResponseToJson(this);
}
