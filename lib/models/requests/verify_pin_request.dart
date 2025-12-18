// Model untuk request verifikasi PIN
class VerifyPinRequest {
  final String pin;

  VerifyPinRequest({
    required this.pin,
  });

  Map<String, dynamic> toJson() {
    return {
      'pin': pin,
    };
  }
}
