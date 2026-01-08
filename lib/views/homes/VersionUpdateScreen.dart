import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 版本更新全屏页面 - 严格按照 Telegram 设计
class VersionUpdateScreen extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool forceUpdate;

  const VersionUpdateScreen({
    Key? key,
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    this.forceUpdate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 强制更新时禁止返回
      canPop: !forceUpdate, // 如果是强制更新，设为 false 阻止返回
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFF4), // iOS 浅灰背景
        body: SafeArea(
          child: Column(
            children: [
              // 顶部导航栏
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 跳过按钮
                    if (!forceUpdate)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '跳过',
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),

                    // 标题
                    const Text(
                      'ComeComePay 升级',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 占位，保持标题居中
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 主内容卡片：图标 + 版本号 + 说明
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 图标和版本号行
                    Row(
                      children: [
                        // 应用图标
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFA855F7),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.payment,
                                  size: 32,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // 版本号
                        Expanded(
                          child: Text(
                            'ComeComePay $version',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 更新说明
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        releaseNotes.isEmpty
                            ? 'Please update ComeComePay to the latest version. The version you are using is out of date and may stop working soon.'
                            : releaseNotes,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 升级按钮
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () async {
                    await _launchUrl(downloadUrl);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    '升级 ComeComePay',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // 占位空间
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开下载链接
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

  /// 显示版本更新页面
  static Future<void> show(
    BuildContext context, {
    required String version,
    required String releaseNotes,
    required String downloadUrl,
    bool forceUpdate = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => VersionUpdateScreen(
          version: version,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
          forceUpdate: forceUpdate,
        ),
      ),
    );
  }
}
