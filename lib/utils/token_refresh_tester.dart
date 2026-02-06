import 'package:Demo/services/hive_storage_service.dart';
import 'dart:developer' as developer;

/// Token刷新测试工具
/// 使用方法：在任意页面调用这些静态方法来测试token刷新功能
class TokenRefreshTester {
  /// 测试1: 模拟 Access Token 过期
  ///
  /// 使用场景：测试24小时后access token过期的情况
  ///
  /// 使用方法：
  /// ```dart
  /// await TokenRefreshTester.simulateAccessTokenExpiry();
  /// // 然后触发任意API请求（如刷新首页、查看卡片列表等）
  /// ```
  ///
  /// 预期结果：
  /// - API请求返回401
  /// - 系统自动调用 /auth/refresh 刷新token
  /// - 原始请求自动重试并成功
  /// - 数据正常显示
  static Future<void> simulateAccessTokenExpiry() async {
    try {
      final authData = HiveStorageService.getAuthData();
      if (authData == null) {
        developer.log('❌ 未找到认证数据，请先登录', name: 'TokenTest');
        return;
      }

      // 保留有效的refresh token，只设置无效的access token
      await HiveStorageService.updateTokens(
        'expired_access_token_for_testing_12345',
        authData.refreshToken,
      );

      developer.log('✅ Access Token已设置为过期状态', name: 'TokenTest');
      developer.log('📱 请立即触发任意API请求（如刷新首页、查看卡片等）', name: 'TokenTest');
      developer.log('👀 观察控制台日志，应该看到自动刷新并重试成功', name: 'TokenTest');
    } catch (e) {
      developer.log('❌ 设置失败: $e', name: 'TokenTest');
    }
  }

  /// 测试2: 模拟 Refresh Token 过期
  ///
  /// 使用场景：测试7天后refresh token也过期的情况
  ///
  /// 使用方法：
  /// ```dart
  /// await TokenRefreshTester.simulateRefreshTokenExpiry();
  /// // 然后触发任意API请求
  /// ```
  ///
  /// 预期结果：
  /// - API请求返回401
  /// - 尝试刷新token但失败（refresh token也过期）
  /// - 系统自动清除本地认证数据
  /// - 发送SessionExpired事件
  /// - 需要重新登录
  static Future<void> simulateRefreshTokenExpiry() async {
    try {
      // 两个token都设置为无效
      await HiveStorageService.updateTokens(
        'expired_access_token_12345',
        'expired_refresh_token_12345',
      );

      developer.log('✅ Access Token 和 Refresh Token 都已设置为过期状态',
          name: 'TokenTest');
      developer.log('📱 请立即触发任意API请求', name: 'TokenTest');
      developer.log('👀 应该看到清除数据并发送SessionExpired事件', name: 'TokenTest');
      developer.log('⚠️ 之后需要重新登录', name: 'TokenTest');
    } catch (e) {
      developer.log('❌ 设置失败: $e', name: 'TokenTest');
    }
  }

  /// 测试3: 恢复正常Token
  ///
  /// 使用场景：测试完成后恢复正常状态
  ///
  /// 注意：这会要求你重新登录
  static Future<void> resetTokens() async {
    try {
      await HiveStorageService.clearAuthData();
      developer.log('✅ Token已清除，请重新登录', name: 'TokenTest');
    } catch (e) {
      developer.log('❌ 清除失败: $e', name: 'TokenTest');
    }
  }

  /// 查看当前Token状态
  static void checkTokenStatus() {
    final accessToken = HiveStorageService.getAccessToken();
    final refreshToken = HiveStorageService.getRefreshToken();
    final user = HiveStorageService.getUser();

    developer.log('=== 当前Token状态 ===', name: 'TokenTest');

    // 显示token的后面部分，更容易看出是否被修改
    if (accessToken != null && accessToken.length > 30) {
      developer.log(
          'Access Token (后30字符): ...${accessToken.substring(accessToken.length - 30)}',
          name: 'TokenTest');
    } else {
      developer.log('Access Token: ${accessToken ?? "无"}', name: 'TokenTest');
    }

    if (refreshToken != null && refreshToken.length > 30) {
      developer.log(
          'Refresh Token (后30字符): ...${refreshToken.substring(refreshToken.length - 30)}',
          name: 'TokenTest');
    } else {
      developer.log('Refresh Token: ${refreshToken ?? "无"}', name: 'TokenTest');
    }
    developer.log('用户: ${user?.email ?? "未登录"}', name: 'TokenTest');
    developer.log('==================', name: 'TokenTest');
  }

  /// 快速测试流程（推荐）
  ///
  /// 这个方法会打印详细的测试步骤指引
  static void showTestGuide() {
    developer.log('', name: 'TokenTest');
    developer.log('╔═══════════════════════════════════════╗',
        name: 'TokenTest');
    developer.log('║   Token自动刷新功能测试指南          ║', name: 'TokenTest');
    developer.log('╚═══════════════════════════════════════╝',
        name: 'TokenTest');
    developer.log('', name: 'TokenTest');

    developer.log('📋 测试步骤：', name: 'TokenTest');
    developer.log('', name: 'TokenTest');

    developer.log('1️⃣ 测试 Access Token 刷新（推荐先测这个）', name: 'TokenTest');
    developer.log(
        '   代码: await TokenRefreshTester.simulateAccessTokenExpiry();',
        name: 'TokenTest');
    developer.log('   然后: 刷新首页或查看任意数据', name: 'TokenTest');
    developer.log('   预期: 自动刷新token，数据正常显示', name: 'TokenTest');
    developer.log('', name: 'TokenTest');

    developer.log('2️⃣ 测试 Refresh Token 过期', name: 'TokenTest');
    developer.log(
        '   代码: await TokenRefreshTester.simulateRefreshTokenExpiry();',
        name: 'TokenTest');
    developer.log('   然后: 刷新首页或查看任意数据', name: 'TokenTest');
    developer.log('   预期: 清除数据，需要重新登录', name: 'TokenTest');
    developer.log('', name: 'TokenTest');

    developer.log('3️⃣ 查看当前Token状态', name: 'TokenTest');
    developer.log('   代码: TokenRefreshTester.checkTokenStatus();',
        name: 'TokenTest');
    developer.log('', name: 'TokenTest');

    developer.log('💡 提示：', name: 'TokenTest');
    developer.log('- 在任意页面的initState或按钮点击事件中调用', name: 'TokenTest');
    developer.log('- 观察DevTools的Logging标签查看详细日志', name: 'TokenTest');
    developer.log('- 测试完成后重新登录即可恢复正常', name: 'TokenTest');
    developer.log('', name: 'TokenTest');
  }
}
