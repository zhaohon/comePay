class SendMessageRequestModel {
  final int userId;
  final String sender;
  final String message;

  SendMessageRequestModel({
    required this.userId,
    required this.sender,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'sender': sender,
      'message': message,
    };
  }
}
