// Model untuk request change phone
class ChangePhoneRequestModel {
  final String newPhone;

  ChangePhoneRequestModel({
    required this.newPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_phone': newPhone,
    };
  }
}
