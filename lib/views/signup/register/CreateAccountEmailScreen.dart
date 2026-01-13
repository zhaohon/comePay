import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/signup_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/widgets/gradient_button.dart';
import 'package:comecomepay/widgets/custom_text_field.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

class CreateAccountEmailScreen extends StatefulWidget {
  const CreateAccountEmailScreen({super.key});

  @override
  _CreateAccountEmailScreenState createState() =>
      _CreateAccountEmailScreenState();
}

class _CreateAccountEmailScreenState extends State<CreateAccountEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  late final SignupViewModel _signupViewModel;

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 1;

  @override
  void initState() {
    super.initState();
    _signupViewModel = getIt<SignupViewModel>();
  }

  Future<void> _validateEmailAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      // 触发重建以显示加载状态
      setState(() {});

      final result = await _signupViewModel.validateEmail(
        _emailController.text,
        referralCode: _referralCodeController.text.trim().isEmpty
            ? null
            : _referralCodeController.text.trim(),
      );

      if (!mounted) return;

      // 触发重建以隐藏加载状态
      setState(() {});

      if (result.success) {
        // /auth/signup 已自动发送验证码，直接导航
        Navigator.pushNamed(
          context,
          '/create_account_confirm_email',
          arguments: {
            'email': _emailController.text,
            'message': result.message,
            'otp': _signupViewModel.emailValidationResponse?.otp,
          },
        );
      } else {
        _showErrorAlert(
            result.message ?? AppLocalizations.of(context)!.errorOccurred);
      }
    }
  }

  void _showErrorAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void dispose() {
    _emailController.dispose();
    _referralCodeController.dispose();
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
                  l10n.whatsYourEmail,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  l10n.enterTheEmailAddressYouWantToUseToRegisterWithCCP,
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

                const SizedBox(height: 20),

                // Referral Code Input (Optional)
                CustomTextField(
                  controller: _referralCodeController,
                  hintText: l10n.referralCodeOptional,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.card_giftcard,
                    color: AppColors.textSecondary,
                  ),
                  validator: null, // Optional field, no validation needed
                ),

                const SizedBox(height: 20),

                // Log in link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login_screen');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: '${l10n.haveAnAccount} '),
                          TextSpan(
                            text: l10n.logInHere,
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

                // Continue Button
                GradientButton(
                  text: l10n.continues,
                  width: double.infinity,
                  onPressed: _signupViewModel.isLoading
                      ? null
                      : _validateEmailAndNavigate,
                  isLoading: _signupViewModel.isLoading,
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
      ),
    );
  }
}
