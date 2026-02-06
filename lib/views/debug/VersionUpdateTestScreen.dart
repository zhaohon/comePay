import 'package:flutter/material.dart';
import 'package:Demo/views/homes/VersionUpdateScreen.dart';

/// 版本更新测试页面
/// 用于测试版本更新 UI
class VersionUpdateTestScreen extends StatelessWidget {
  const VersionUpdateTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('版本更新测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 直接显示版本更新页面
                VersionUpdateScreen.show(
                  context,
                  version: '1.0.1',
                  releaseNotes:
                      'Please update Demo to the latest version. The version you are using is out of date and may stop working soon.',
                  downloadUrl: 'https://www.baidu.com',
                  forceUpdate: false,
                );
              },
              child: const Text('显示版本更新页面（普通模式）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 显示强制更新模式
                VersionUpdateScreen.show(
                  context,
                  version: '1.0.1',
                  releaseNotes:
                      'Please update Demo to the latest version. The version you are using is out of date and may stop working soon.',
                  downloadUrl: 'https://www.baidu.com',
                  forceUpdate: true,
                );
              },
              child: const Text('显示版本更新页面（强制更新）'),
            ),
          ],
        ),
      ),
    );
  }
}
