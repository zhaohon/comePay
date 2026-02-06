import 'package:flutter/material.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/widgets/otp_input.dart';
import 'package:Demo/l10n/app_localizations.dart';
import 'package:Demo/services/global_service.dart';
import 'package:Demo/models/requests/registration_otp_verification_request_model.dart';
import 'package:Demo/models/responses/registration_otp_verification_response_model.dart';
import 'package:Demo/models/responses/registration_otp_verification_error_model.dart';

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
  final GlobalService _globalService = GlobalService();

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

    // Get email and referral code from route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String?;
    final referralCode = arguments?['referral_code'] as String?;

    print('[CreateAccountOtpConfirmScreen] Received arguments: $arguments');
    print(
        '[CreateAccountOtpConfirmScreen] Extracted referralCode: $referralCode');

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Call OTP verification API
      final request = RegistrationOtpVerificationRequestModel(
        email: email,
        otpCode: _otpCode,
        referralCode: referralCode,
      );

      final response = await _globalService.verifyRegistrationOtp(request);

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      if (response is RegistrationOtpVerificationResponseModel) {
        // OTP verification successful
        if (response.nextStep == 'set_password') {
          // Navigate to password screen
          print(
              '[CreateAccountOtpConfirmScreen] Navigating to set_password with: '
              'response.referralCode=${response.referralCode}, '
              'originalArg=$referralCode');

          Navigator.pushNamed(
            context,
            '/create_account_password',
            arguments: {
              'email': email,
              'referral_code': (response.referralCode.isNotEmpty)
                  ? response.referralCode
                  : referralCode,
            },
          );
        } else {
          // Unexpected next step
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else if (response is RegistrationOtpVerificationErrorModel) {
        // OTP verification failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Unexpected response type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorOccurred}: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
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

    // Get email from route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String? ?? 'your email';
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
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: '${l10n.weSentEmailTo} '),
                    TextSpan(
                      text: email,
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
