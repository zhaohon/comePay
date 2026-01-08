/// 版本比较工具类
class VersionUtils {
  /// 比较两个语义化版本号
  ///
  /// 参数:
  /// - currentVersion: 当前应用版本，例如 "1.0.2"
  /// - remoteVersion: 远程服务器版本，例如 "1.0.3"
  ///
  /// 返回:
  /// - true: 如果远程版本比当前版本新
  /// - false: 如果远程版本等于或旧于当前版本
  ///
  /// 示例:
  /// - isNewerVersion("1.0.2", "1.0.3") -> true
  /// - isNewerVersion("1.0.2", "1.0.2") -> false
  /// - isNewerVersion("1.0.2", "1.0.1") -> false
  /// - isNewerVersion("1.1.2", "1.2.1") -> true
  /// - isNewerVersion("1.1.11", "1.0.12") -> false
  static bool isNewerVersion(String currentVersion, String remoteVersion) {
    try {
      // 解析版本号为整数列表
      List<int> current = _parseVersion(currentVersion);
      List<int> remote = _parseVersion(remoteVersion);

      // 确保两个版本号都有三个部分（主版本.次版本.补丁版本）
      while (current.length < 3) {
        current.add(0);
      }
      while (remote.length < 3) {
        remote.add(0);
      }

      // 逐个比较版本号的每个部分
      for (int i = 0; i < 3; i++) {
        if (remote[i] > current[i]) {
          return true; // 远程版本更新
        } else if (remote[i] < current[i]) {
          return false; // 远程版本更旧
        }
        // 如果相等，继续比较下一个部分
      }

      // 所有部分都相等
      return false;
    } catch (e) {
      // 如果解析失败，默认返回 false（不更新）
      return false;
    }
  }

  /// 解析版本字符串为整数列表
  /// 例如: "1.2.3" -> [1, 2, 3]
  /// 如果版本无效，抛出异常
  static List<int> _parseVersion(String version) {
    // 移除可能的前缀（如 "v1.2.3" -> "1.2.3"）
    String cleanVersion = version.trim().toLowerCase().replaceFirst('v', '');

    // 分割版本号
    List<String> parts = cleanVersion.split('.');

    // 验证至少有一个部分
    if (parts.isEmpty) {
      throw FormatException('Invalid version format: $version');
    }

    // 转换为整数并验证
    List<int> versionNumbers = [];
    for (String part in parts) {
      int? number = int.tryParse(part.trim());
      if (number == null) {
        throw FormatException('Invalid version format: $version');
      }
      versionNumbers.add(number);
    }

    return versionNumbers;
  }

  /// 格式化版本号显示
  /// 例如: "1.2.3" -> "Version 1.2.3"
  static String formatVersion(String version) {
    return 'Version $version';
  }
}
