// Model untuk request email validation
class EmailValidationRequestModel {
  final String email;
  final String? referralCode;

  EmailValidationRequestModel({
    required this.email,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
    };

    // Only include referral_code if it's not null
    if (referralCode != null && referralCode!.isNotEmpty) {
      data['referral_code'] = referralCode!;
    }

    return data;
  }
}
