// Model untuk request signup
class SignupRequestModel {
  final String email;
  final String phone;
  final String password;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String accountType;

  SignupRequestModel({
    required this.email,
    required this.phone,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'account_type': accountType,
    };
  }
}
