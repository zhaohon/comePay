import 'package:flutter_test/flutter_test.dart';
import 'package:Demo/utils/version_utils.dart';

void main() {
  group('VersionUtils Tests', () {
    test('相同版本应返回 false', () {
      expect(VersionUtils.isNewerVersion('1.0.2', '1.0.2'), false);
    });

    test('较新的补丁版本应返回 true', () {
      expect(VersionUtils.isNewerVersion('1.0.2', '1.0.3'), true);
    });

    test('较旧的补丁版本应返回 false', () {
      expect(VersionUtils.isNewerVersion('1.0.2', '1.0.1'), false);
    });

    test('较新的次版本应返回 true', () {
      expect(VersionUtils.isNewerVersion('1.1.2', '1.2.1'), true);
    });

    test('1.1.11 vs 1.0.12 应返回 false（按需求）', () {
      // 注意：这是按照用户需求，但实际上 1.1.11 > 1.0.12
      // 如果按语义化版本，1.1.x 系列应该大于 1.0.x 系列
      expect(VersionUtils.isNewerVersion('1.1.11', '1.0.12'), false);
    });

    test('较新的主版本应返回 true', () {
      expect(VersionUtils.isNewerVersion('1.5.0', '2.0.0'), true);
    });

    test('处理带 v 前缀的版本号', () {
      expect(VersionUtils.isNewerVersion('v1.0.0', 'v1.0.1'), true);
    });

    test('处理缺少部分的版本号', () {
      expect(VersionUtils.isNewerVersion('1.0', '1.0.1'), true);
    });

    test('无效版本号应返回 false', () {
      expect(VersionUtils.isNewerVersion('invalid', '1.0.0'), false);
    });
  });
}
