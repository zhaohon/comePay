import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/widgets/otp_input.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  String _otpCode = '';
  late LoginViewModel _loginViewModel;
  String _email = "john.doe3@example.com";

  @override
  void initState() {
    super.initState();
    _loginViewModel = getIt<LoginViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _email = args['email'] ?? _email;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _loginViewModel.clearError();
    super.dispose();
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

    final result = await _loginViewModel.verifyOtp(_email, _otpCode);

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/login_welcomback_screen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? l10n.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await _loginViewModel.resendOtp(_email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? (result.message ?? l10n.newOtpSentToYourEmail)
              : (result.message ?? l10n.failedToResendOtp),
        ),
        backgroundColor: result.success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _loginViewModel,
      child: Consumer<LoginViewModel>(
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
                      text: l10n.verify,
                      width: double.infinity,
                      onPressed: viewModel.isLoading ? null : _verifyOtp,
                      isLoading: viewModel.isLoading,
                    ),

                    const SizedBox(height: 40),
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
