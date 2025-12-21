import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/widgets/otp_input.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class CreateAccountOtpConfirmScreen extends StatefulWidget {
  const CreateAccountOtpConfirmScreen({super.key});

  @override
  _CreateAccountOtpConfirmScreenState createState() =>
      _CreateAccountOtpConfirmScreenState();
}

class _CreateAccountOtpConfirmScreenState
    extends State<CreateAccountOtpConfirmScreen> {
  String _otpCode = '';
  bool _isVerifying = false;

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

    setState(() {
      _isVerifying = true;
    });

    // TODO: Implement OTP verification logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isVerifying = false;
    });

    // Navigate to password screen
    if (mounted) {
      Navigator.pushNamed(context, '/create_account_password');
    }
  }

  void _resendOtp() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.newOtpSentToYourEmail),
        backgroundColor: AppColors.success,
      ),
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

              // Subtitle with email
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'We sent email to '),
                    TextSpan(
                      text: 'kasino1992@gmail.com',
                      style: TextStyle(
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
                text: l10n.verify,
                width: double.infinity,
                onPressed: _isVerifying ? null : _verifyOtp,
                isLoading: _isVerifying,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
