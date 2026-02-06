import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Demo/viewmodels/forgot_password_viewmodel.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/widgets/custom_text_field.dart';
import 'package:Demo/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 1;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator(int totalSteps, int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index < currentStep;
        bool isCurrent = index + 1 == currentStep;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 44 : 36,
          height: 4,
          decoration: BoxDecoration(
            gradient: isActive || isCurrent ? AppColors.primaryGradient : null,
            color: isActive || isCurrent ? null : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => ForgotPasswordViewModel(),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        l10n.passwordReset,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        l10n.enterRegisterEmailPassword,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Input
                      CustomTextField(
                        controller: _emailController,
                        hintText: l10n.emailAddress,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterYourEmail;
                          }
                          final emailRegExp = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                          if (!emailRegExp.hasMatch(value)) {
                            return l10n.pleaseEnterAValidEmailAddress;
                          }
                          return null;
                        },
                      ),

                      const Spacer(),

                      // Continue Button
                      GradientButton(
                        text: l10n.continues,
                        width: double.infinity,
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final response = await viewModel
                                      .forgotPassword(_emailController.text);

                                  if (!mounted) return;

                                  if (response != null) {
                                    final emailSent = await viewModel.sendEmail(
                                      response.email,
                                      response.name ?? 'User',
                                      response.otp,
                                    );

                                    if (emailSent) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${l10n.otpSentToYourEmail}: ${_emailController.text}'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        '/ResetPasswordConfirmEmailScreen',
                                        arguments: _emailController.text,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.failedToSendOtp),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(viewModel.errorMessage ??
                                            l10n.errorOccurred),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                        isLoading: viewModel.isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Progress Indicator
                      _buildProgressIndicator(
                          _totalProgressSteps, _currentProgressStep),

                      const SizedBox(height: 16),

                      // Terms and Privacy
                      Center(
                        child: Text(
                          l10n.policies,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
