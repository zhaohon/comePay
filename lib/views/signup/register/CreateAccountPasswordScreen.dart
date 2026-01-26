import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/widgets/custom_text_field.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/models/responses/set_password_response_model.dart';

class CreateAccountPasswordScreen extends StatefulWidget {
  const CreateAccountPasswordScreen({super.key});

  @override
  _CreateAccountPasswordScreenState createState() =>
      _CreateAccountPasswordScreenState();
}

class _CreateAccountPasswordScreenState
    extends State<CreateAccountPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isCreating = false;

  final GlobalService _globalService = GlobalService();

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 3;

  Future<void> _createPassword() async {
    final l10n = AppLocalizations.of(context)!;

    // Trigger validation to show errors
    if (!_formKey.currentState!.validate()) {
      // Show a snackbar to inform user about validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请检查密码要求'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get email and referral code from route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String?;
    final referralCode = arguments?['referral_code'] as String?;

    print('[CreateAccountPasswordScreen] Received arguments: $arguments');
    print(
        '[CreateAccountPasswordScreen] Extracted referralCode: $referralCode');

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
      _isCreating = true;
    });

    try {
      // Call set-password API
      final response = await _globalService.setPassword(
        email,
        _passwordController.text,
        referralCode: referralCode,
      );

      if (!mounted) return;

      setState(() {
        _isCreating = false;
      });

      if (response is SetPasswordResponseModel) {
        // Password set successfully
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('注册成功！请使用您的邮箱和密码登录'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to login screen, clearing all previous routes
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login_screen',
            (route) => false,
          );
        }
      } else if (response is SetPasswordErrorModel) {
        // Password set failed
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
        _isCreating = false;
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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  l10n.createAPassword,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  l10n.passwordMustBe8Characters,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // Password Input
                CustomTextField(
                  controller: _passwordController,
                  hintText: l10n.password,
                  obscureText: !_showPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordCannotBeEmpty;
                    }
                    if (value.length < 8) {
                      return l10n.passwordMustBeAtLeast8Characters;
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return l10n.passwordMustContainUppercase;
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return l10n.passwordMustContainNumber;
                    }
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return l10n.passwordMustContainSpecial;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Label
                Text(
                  l10n.confirmPasswordLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Confirm Password Input
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: l10n.confirmPassword,
                  obscureText: !_showConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseConfirmYourPassword;
                    }
                    if (value != _passwordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),

                const Spacer(),

                // Continue Button
                GradientButton(
                  text: l10n.continues,
                  width: double.infinity,
                  onPressed: _isCreating ? null : _createPassword,
                  isLoading: _isCreating,
                ),

                const SizedBox(height: 24),

                // Progress Indicator
                _buildProgressIndicator(
                    _totalProgressSteps, _currentProgressStep),

                const SizedBox(height: 16),

                // Terms and Privacy
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: '${l10n.byRegisteringYouAccept} '),
                        TextSpan(
                          text: l10n.termsAndConditions,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' ${l10n.andPrivacyPolicy}\n'),
                        TextSpan(
                          text: l10n.privacyPolicy,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '. ${l10n.yourDataWillBeSecure}'),
                      ],
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
  }
}
