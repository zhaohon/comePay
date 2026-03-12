import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';

class ApplyPhysicalCardSuccessScreen extends StatelessWidget {
  const ApplyPhysicalCardSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 白底
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 顶部的大卡片图
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/card.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 成功标题
              const Text(
                '您已成功申领实体卡！',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 说明文案
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                  children: [
                    TextSpan(text: '您可在 '),
                    TextSpan(
                      text: '【卡片】',
                      style: TextStyle(color: Color(0xFF10B981)), // 绿色高亮
                    ),
                    TextSpan(text: ' 界面中查看 '),
                    TextSpan(
                      text: '【邮寄进度】\n',
                      style: TextStyle(color: Color(0xFF10B981)), // 绿色高亮
                    ),
                    TextSpan(text: '我们将尽快为您寄送卡片，敬请查收！\n'),
                    TextSpan(text: '请在收到卡片后进行激活后使用。'),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 返回按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 返回到首层卡片页 (根据实际路由堆栈调整，这里简单用 popUntil)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // 深色按钮
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '返回',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
