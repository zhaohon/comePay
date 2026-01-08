/// 应用版本检查 API 响应模型
class AppVersionResponseModel {
  final String status;
  final AppVersionData data;

  AppVersionResponseModel({
    required this.status,
    required this.data,
  });

  factory AppVersionResponseModel.fromJson(Map<String, dynamic> json) {
    return AppVersionResponseModel(
      status: json['status'] ?? '',
      data: AppVersionData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

/// 版本数据详情
class AppVersionData {
  final String version;
  final String platform;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;
  final String updatedAt;

  AppVersionData({
    required this.version,
    required this.platform,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
    required this.updatedAt,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      version: json['version'] ?? '',
      platform: json['platform'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: json['release_notes'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'platform': platform,
      'download_url': downloadUrl,
      'release_notes': releaseNotes,
      'force_update': forceUpdate,
      'updated_at': updatedAt,
    };
  }
}
