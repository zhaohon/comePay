import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/utils/version_utils.dart';
import 'package:comecomepay/services/app_version_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/views/homes/VersionUpdateScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 应用启动时清除版本弹窗显示标记
    // 这样每次完全重启应用都会重新检查版本
    HiveStorageService.clearVersionDialogShown();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await loginViewModel.loadAuthDataFromStorage();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Timer(const Duration(milliseconds: 800), () async {
          if (mounted) {
            // 先检查版本更新
            await _checkVersionUpdate();

            // 然后导航到相应页面
            if (loginViewModel.hasStoredAuthData &&
                loginViewModel.storedAccessToken != null &&
                loginViewModel.storedRefreshToken != null) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/onboarding_screen');
            }
          }
        });
      }
    });
  }

  /// 检查版本更新
  Future<void> _checkVersionUpdate() async {
    try {
      // 检查是否已经显示过弹窗
      final hasShown = HiveStorageService.getVersionDialogShown();
      if (hasShown) {
        return;
      }

      // 调用 API 获取最新版本
      final versionService = AppVersionService();
      final response =
          await versionService.getLatestVersion(platform: 'android');

      // 从 pubspec.yaml 获取当前版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final remoteVersion = response.data.version;

      print('🔍 Version Debug: Current=$currentVersion, Remote=$remoteVersion');

      final isNewer =
          VersionUtils.isNewerVersion(currentVersion, remoteVersion);

      print('🔍 Version Debug: isNewer=$isNewer');

      // 如果有新版本，显示全屏页面
      if (isNewer && mounted) {
        // 标记弹窗已显示
        await HiveStorageService.saveVersionDialogShown(true);

        // 显示更新页面
        await VersionUpdateScreen.show(
          context,
          version: remoteVersion,
          releaseNotes: response.data.releaseNotes,
          downloadUrl: response.data.downloadUrl,
          forceUpdate: response.data.forceUpdate,
        );
      }
    } catch (e) {
      // 静默处理错误，不影响应用启动
      debugPrint('Version check failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // 如果logo不存在，显示应用名
                    return Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Come Come Pay',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
