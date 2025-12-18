// Model untuk request email validation
class EmailValidationRequestModel {
  final String email;

  EmailValidationRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
