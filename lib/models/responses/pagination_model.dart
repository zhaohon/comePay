class PaginationModel {
  final int limit;
  final int page;
  final int total;

  PaginationModel({
    required this.limit,
    required this.page,
    required this.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      limit: json['limit'] ?? 10,
      page: json['page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'page': page,
      'total': total,
    };
  }
}
