class ChatInboxRequestModel {
  final int page;
  final int limit;

  ChatInboxRequestModel({
    required this.page,
    required this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
    };
  }
}
