import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

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
                child: AspectRatio(
                  aspectRatio: 4999 / 2880,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/card.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 成功标题
              Text(
                AppLocalizations.of(context)!.applyPhysicalCardSuccessTitle,
                style: const TextStyle(
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
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.youCanIn),
                    TextSpan(
                      text: AppLocalizations.of(context)!.cardTab,
                      style: const TextStyle(color: Color(0xFF10B981)), // 绿色高亮
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.screenView),
                    TextSpan(
                      text:
                          AppLocalizations.of(context)!.mailingProgressTabDesc,
                      style: const TextStyle(color: Color(0xFF10B981)), // 绿色高亮
                    ),
                    TextSpan(
                        text:
                            AppLocalizations.of(context)!.willSendCardSoonTip),
                    TextSpan(
                        text: AppLocalizations.of(context)!
                            .pleaseActivateAfterReceiving),
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
                  child: Text(
                    AppLocalizations.of(context)!.backButton,
                    style: const TextStyle(
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
