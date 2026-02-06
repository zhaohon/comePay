import 'package:flutter/material.dart';
import 'package:Demo/viewmodels/forgot_password_viewmodel.dart';
import 'package:Demo/utils/service_locator.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/widgets/otp_input.dart';
import 'package:Demo/l10n/app_localizations.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  const ResetPasswordOtpScreen({super.key});

  @override
  _ResetPasswordOtpScreenState createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  String _otpCode = '';
  String _email = 'your email';
  bool _isLoading = false;

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _email = args;
    }
  }

  void _onOtpCompleted(String code) {
    setState(() {
      _otpCode = code;
    });
  }

  void _onOtpChanged(String code) {
    setState(() {
      _otpCode = code;
    });
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_otpCode.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillAllOtpFields),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final forgotPasswordViewModel = getIt<ForgotPasswordViewModel>();
    final success =
        await forgotPasswordViewModel.verifyResetPasswordOtp(_email, _otpCode);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        '/ResetPasswordCreatePasswordScreen',
        arguments: _email,
      );
    } else {
      final errorMessage =
          forgotPasswordViewModel.errorMessage ?? l10n.errorOccurred;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final forgotPasswordViewModel = getIt<ForgotPasswordViewModel>();

    final success = await forgotPasswordViewModel.resendOtp(_email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.newOtpSentToYourEmail
              : (forgotPasswordViewModel.errorMessage ??
                  l10n.failedToResendOtp),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                l10n.pleaseEnterTheCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              //Subtitle with email
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: '${l10n.weSentEmailTo} '),
                    TextSpan(
                      text: _email,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input
              OtpInput(
                length: 5,
                onCompleted: _onOtpCompleted,
                onChanged: _onOtpChanged,
              ),

              const SizedBox(height: 24),

              // Resend link
              Center(
                child: GestureDetector(
                  onTap: _resendOtp,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: '${l10n.didntGetACode} '),
                        TextSpan(
                          text: l10n.sendAgain,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Verify Button
              GradientButton(
                text: l10n.entered,
                width: double.infinity,
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Progress Indicator
              _buildProgressIndicator(
                  _totalProgressSteps, _currentProgressStep),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
