class UpdateProfileRequestModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String dateOfBirth;
  final String accountType;
  final String referralCode;

  UpdateProfileRequestModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dateOfBirth,
    required this.accountType,
    required this.referralCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'account_type': accountType,
      'referral_code': referralCode,
    };
  }
}
