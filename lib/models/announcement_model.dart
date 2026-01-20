class AnnouncementItem {
  final int id;
  final String title;
  final String content;
  final String status;
  final String createdAt;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'published',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class AnnouncementListResponse {
  final String status;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<AnnouncementItem> items;

  AnnouncementListResponse({
    required this.status,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementListResponse(
      status: json['status'] as String? ?? 'success',
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  AnnouncementItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AnnouncementDetailResponse {
  final String status;
  final AnnouncementItem data;

  AnnouncementDetailResponse({
    required this.status,
    required this.data,
  });

  factory AnnouncementDetailResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetailResponse(
      status: json['status'] as String? ?? 'success',
      data: AnnouncementItem.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
