// Model for Didit initialize token request
class DiditInitializeTokenRequestModel {
  final String address;
  final String agentUid;
  final String areaCode;
  final String billCountryCode;
  final String city;
  final String email;
  final String firstEnName;
  final String lastEnName;
  final String phone;
  final String postCode;
  final String returnUrl;
  final String state;

  DiditInitializeTokenRequestModel({
    required this.address,
    required this.agentUid,
    required this.areaCode,
    required this.billCountryCode,
    required this.city,
    required this.email,
    required this.firstEnName,
    required this.lastEnName,
    required this.phone,
    required this.postCode,
    required this.returnUrl,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'agent_uid': agentUid,
      'area_code': areaCode,
      'bill_country_code': billCountryCode,
      'city': city,
      'email': email,
      'first_en_name': firstEnName,
      'last_en_name': lastEnName,
      'phone': phone,
      'post_code': postCode,
      'return_url': returnUrl,
      'state': state,
    };
  }
}
