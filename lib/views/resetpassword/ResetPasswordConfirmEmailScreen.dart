import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Demo/viewmodels/forgot_password_viewmodel.dart';
import 'package:Demo/utils/service_locator.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/l10n/app_localizations.dart';

class ResetPasswordConfirmEmailScreen extends StatefulWidget {
  const ResetPasswordConfirmEmailScreen({super.key});

  @override
  _ResetPasswordConfirmEmailScreenState createState() =>
      _ResetPasswordConfirmEmailScreenState();
}

class _ResetPasswordConfirmEmailScreenState
    extends State<ResetPasswordConfirmEmailScreen> {
  String email = 'Demo@info.com';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          email = args;
        });
      } else {
        email = 'your email';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => getIt<ForgotPasswordViewModel>(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // Image
                    Image.asset(
                      'assets/abstract.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.mark_email_unread_outlined,
                            size: 100,
                            color: AppColors.primary.withOpacity(0.6),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      l10n.confirmYourEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle with email
                    Text(
                      '${l10n.weSentEmailTo} $email',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Confirm Button
                    GradientButton(
                      text: l10n.confirm,
                      width: double.infinity,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/ResetPasswordOtpScreen',
                          arguments: email,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Resend link
                    GestureDetector(
                      onTap: viewModel.isLoading
                          ? null
                          : () async {
                              final response =
                                  await viewModel.forgotPassword(email);
                              if (!mounted) return;

                              if (response != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${l10n.otpSentToYourEmail}: $email'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ??
                                        l10n.errorOccurred),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(text: '${l10n.didnReceive} '),
                            TextSpan(
                              text: l10n.myEmail,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
