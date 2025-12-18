class KycModel {
  final int id;
  final int createdTime;
  final int updatedTime;
  final int deletedTime;
  final String firstName;
  final String lastName;
  final String firstNameEn;
  final String lastNameEn;
  final String birthday;
  final int countryId;
  final String countryCode;
  final int cardType;
  final String cardNumber;
  final int status;
  final String areaCode;
  final String phone;
  final String email;
  final String reason;
  final String remark;
  final int holdCardNum;
  final int holdCancelledCardNum;
  final int billCountryId;
  final String billCountryCode;
  final String state;
  final String city;
  final String address;
  final String postCode;

  KycModel({
    required this.id,
    required this.createdTime,
    required this.updatedTime,
    required this.deletedTime,
    required this.firstName,
    required this.lastName,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.birthday,
    required this.countryId,
    required this.countryCode,
    required this.cardType,
    required this.cardNumber,
    required this.status,
    required this.areaCode,
    required this.phone,
    required this.email,
    required this.reason,
    required this.remark,
    required this.holdCardNum,
    required this.holdCancelledCardNum,
    required this.billCountryId,
    required this.billCountryCode,
    required this.state,
    required this.city,
    required this.address,
    required this.postCode,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) {
    return KycModel(
      id: json['id'],
      createdTime: json['created_time'],
      updatedTime: json['updated_time'],
      deletedTime: json['deleted_time'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      firstNameEn: json['first_name_en'] ?? '',
      lastNameEn: json['last_name_en'] ?? '',
      birthday: json['birthday'] ?? '',
      countryId: json['country_id'] ?? 0,
      countryCode: json['country_code'] ?? '',
      cardType: json['card_type'] ?? 0,
      cardNumber: json['card_number'] ?? '',
      status: json['status'] ?? 0,
      areaCode: json['area_code'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      reason: json['reason'] ?? '',
      remark: json['remark'] ?? '',
      holdCardNum: json['hold_card_num'] ?? 0,
      holdCancelledCardNum: json['hold_cancelled_card_num'] ?? 0,
      billCountryId: json['bill_country_id'] ?? 0,
      billCountryCode: json['bill_country_code'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      postCode: json['post_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'deleted_time': deletedTime,
      'first_name': firstName,
      'last_name': lastName,
      'first_name_en': firstNameEn,
      'last_name_en': lastNameEn,
      'birthday': birthday,
      'country_id': countryId,
      'country_code': countryCode,
      'card_type': cardType,
      'card_number': cardNumber,
      'status': status,
      'area_code': areaCode,
      'phone': phone,
      'email': email,
      'reason': reason,
      'remark': remark,
      'hold_card_num': holdCardNum,
      'hold_cancelled_card_num': holdCancelledCardNum,
      'bill_country_id': billCountryId,
      'bill_country_code': billCountryCode,
      'state': state,
      'city': city,
      'address': address,
      'post_code': postCode,
    };
  }
}
