// Model untuk request change email
class ChangeEmailRequestModel {
  final String newEmail;

  ChangeEmailRequestModel({
    required this.newEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
    };
  }
}
