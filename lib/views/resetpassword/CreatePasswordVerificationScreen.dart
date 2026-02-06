import 'package:flutter/material.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/l10n/app_localizations.dart';

class CreatePasswordVerificationScreen extends StatelessWidget {
  const CreatePasswordVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                l10n.verificationSuccess,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              // Image - 使用原来的图片
              Center(
                child: Image.asset(
                  'assets/illustration.png',
                  width: screenWidth * 0.55,
                  height: screenHeight * 0.28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.55,
                      height: screenHeight * 0.28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary.withOpacity(0.6),
                        size: 80,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.verificationSuccessDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GradientButton(
                  text: l10n.startNow,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login_screen',
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
