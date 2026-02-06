import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 版本更新弹窗 - 完全参考 Telegram 设计
class VersionUpdateDialog extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool forceUpdate;
  final VoidCallback? onSkip;

  const VersionUpdateDialog({
    Key? key,
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    this.forceUpdate = false,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(0), // Telegram 使用直角
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部栏：跳过按钮 + 标题
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 跳过按钮
                  if (!forceUpdate)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onSkip?.call();
                      },
                      child: const Text(
                        '跳过',
                        style: TextStyle(
                          color: Color(0xFF3390EC),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // 标题
                  const Text(
                    'Demo 升级',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 占位，保持标题居中
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // 分割线
            Container(
              height: 0.5,
              color: const Color(0xFF2C2C2E),
            ),

            const SizedBox(height: 32),

            // 主内容区域：图标 + 版本号卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 应用图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFA855F7),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/which.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.payment,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 版本号
                  Text(
                    'Demo $version',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 更新说明区域
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minHeight: 80,
                maxHeight: 200,
              ),
              child: SingleChildScrollView(
                child: Text(
                  releaseNotes.isEmpty ? '测试安卓' : releaseNotes,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 升级按钮
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _launchUrl(downloadUrl);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  '升级 Demo',
                  style: TextStyle(
                    color: Color(0xFF3390EC),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
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

  /// 显示版本更新弹窗
  static Future<void> show(
    BuildContext context, {
    required String version,
    required String releaseNotes,
    required String downloadUrl,
    bool forceUpdate = false,
    VoidCallback? onSkip,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => VersionUpdateDialog(
        version: version,
        releaseNotes: releaseNotes,
        downloadUrl: downloadUrl,
        forceUpdate: forceUpdate,
        onSkip: onSkip,
      ),
    );
  }
}
