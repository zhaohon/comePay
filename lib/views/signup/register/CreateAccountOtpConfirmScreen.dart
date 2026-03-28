import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/widgets/otp_input.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/registration_otp_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:provider/provider.dart';

class CreateAccountOtpConfirmScreen extends StatefulWidget {
  const CreateAccountOtpConfirmScreen({super.key});

  @override
  _CreateAccountOtpConfirmScreenState createState() =>
      _CreateAccountOtpConfirmScreenState();
}

class _CreateAccountOtpConfirmScreenState
    extends State<CreateAccountOtpConfirmScreen> {
  String _otpCode = '';
  late final RegistrationOtpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<RegistrationOtpViewModel>();
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

    // Get email and referral code from route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String?;
    final referralCode = arguments?['referral_code'] as String?;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Call OTP verification via ViewModel
    final result = await _viewModel.verifyRegistrationOtp(
      email: email,
      otpCode: _otpCode,
      l10n: l10n,
    );

    if (!mounted) return;

    if (result.success) {
      final response = _viewModel.otpResponse;
      if (response != null && response.nextStep == 'set_password') {
        // Navigate to password screen
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
            content: Text(result.message ?? l10n.unexpectedError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // OTP verification failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? l10n.errorOccurred),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _resendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String?;

    if (email == null || email.isEmpty) return;

    final result = await _viewModel.resendOtp(email, l10n);

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.newOtpSentToYourEmail),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? l10n.failedToResendOtp),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get email from route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String? ?? 'your email';

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
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
                Selector<RegistrationOtpViewModel, bool>(
                  selector: (_, model) => model.busy,
                  builder: (context, busy, _) {
                    return GradientButton(
                      text: l10n.verify,
                      width: double.infinity,
                      onPressed: busy ? null : _verifyOtp,
                      isLoading: busy,
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
