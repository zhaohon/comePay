// Model untuk error response change phone
class ChangePhoneErrorModel {
  final String error;

  ChangePhoneErrorModel.fromJson(Map<String, dynamic> json)
      : error = json['error'];
}
