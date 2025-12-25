/// 卡片申请请求模型
class CardApplyRequestModel {
  final bool physical;
  final String? nameOnCard;
  final String? recipient;
  final String? areaCode;
  final String? phone;
  final String? postalAddress;
  final String? postalCity;
  final String? postalCode;
  final String? postalCountry;

  CardApplyRequestModel({
    this.physical = false,
    this.nameOnCard,
    this.recipient,
    this.areaCode,
    this.phone,
    this.postalAddress,
    this.postalCity,
    this.postalCode,
    this.postalCountry,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'physical': physical,
    };

    if (physical) {
      if (nameOnCard != null) json['name_on_card'] = nameOnCard;
      if (recipient != null) json['recipient'] = recipient;
      if (areaCode != null) json['area_code'] = areaCode;
      if (phone != null) json['phone'] = phone;
      if (postalAddress != null) json['postal_address'] = postalAddress;
      if (postalCity != null) json['postal_city'] = postalCity;
      if (postalCode != null) json['postal_code'] = postalCode;
      if (postalCountry != null) json['postal_country'] = postalCountry;
    }

    return json;
  }
}

/// 卡片申请响应模型
class CardApplyResponseModel {
  final int taskId;
  final String message;

  CardApplyResponseModel({
    required this.taskId,
    required this.message,
  });

  factory CardApplyResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return CardApplyResponseModel(
      taskId: data['task_id'] as int? ?? 0,
      message: data['message'] as String? ?? '',
    );
  }
}

