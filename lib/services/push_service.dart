import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:comecomepay/core/base_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PushService extends BaseService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 供外部直接调用：获取并解析稳定的设备标示 ID (uuid / identifierForVendor / androidId 等)
  Future<String> _getStableDeviceId() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios-unknown-device';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Android 8.0+ 推荐的稳定硬件标识 ID
        return androidInfo.id;
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
    }
    // Fallback if platform is unknown or info extraction fails
    return 'unknown-device-id-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 封装上报/刷新 Fcm Token 的网络请求
  Future<void> registerDevice() async {
    try {
      // 1. 获取 FCM Token (确保超时控制)
      final String? fcmToken =
          await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('FCM Token Fetch TIMEOUT during registerDevice');
          return null;
        },
      );

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('Skip Push Device Registration: No FCM Token available.');
        return;
      }

      // 2. 组装其他硬件信息参数
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String deviceId = await _getStableDeviceId();
      final String platform = Platform.isIOS ? 'ios' : 'android';

      // 3. 构造请求 Payload
      final Map<String, dynamic> payload = {
        'fcm_token': fcmToken,
        'device_id': deviceId,
        'platform': platform,
        'app_version': packageInfo.version,
      };
      debugPrint('====> [PushService] 准备注册推送设备');
      debugPrint('====> [PushService] 传参 (Payload): $payload');

      // 4. 发起上报请求
      final response = await post('/push/devices', data: payload);
      debugPrint('<==== [PushService] 注册返回数据: $response');
      if (response['status'] == 'success') {
        debugPrint('====> [PushService] ✔️ 成功将硬件绑定至当前登录用户！');
      } else {
        debugPrint('Failed to register push device: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Register Push Device Error: $e');
    }
  }

  /// 注销绑定关系（用于主调发起，常挂载在注销账号或退出登录等位置）
  Future<void> unregisterDevice() async {
    try {
      // FCM Token could change natively, but we need the current one matching what backend holds.
      final String? fcmToken =
          await FirebaseMessaging.instance.getToken().timeout(
                const Duration(seconds: 5),
                onTimeout: () => null, // 优雅降级
              );

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint(
            'Skip Push Device Unregister: Local token is missing or network hang.');
        return;
      }

      final Map<String, dynamic> payload = {
        'fcm_token': fcmToken,
      };

      debugPrint('====> [PushService] 准备注销解绑推送设备');
      debugPrint('====> [PushService] 提取到的注销 Token: $fcmToken');

      final response = await delete('/push/devices', data: payload);
      debugPrint('<==== [PushService] 注销返回数据: $response');

      if (response['status'] == 'success') {
        debugPrint('====> [PushService] ✔️ 成功解除推送设备的账号绑定，防止串号！');
      } else {
        debugPrint(
            'Unregister push device response warning: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Unregister Push Device Error: $e');
    }
  }
}
