import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class LoginWelcomeBackScreen extends StatelessWidget {
  const LoginWelcomeBackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon PNG - 使用原来的welcomeback.png
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Image.asset(
                  'assets/welcomeback.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.waving_hand,
                          color: AppColors.primary.withOpacity(0.7),
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Subtitle "Welcome back"
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Text(
                  l10n.welcomeBack,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Button "Get Started"
              GradientButton(
                text: l10n.getStarted,
                width: 200,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
