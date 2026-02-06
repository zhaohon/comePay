import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Demo/viewmodels/login_viewmodel.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/widgets/gradient_button.dart';
import 'package:Demo/widgets/custom_text_field.dart';
import 'package:Demo/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    loginViewModel.clearError();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final loginResult = await loginViewModel.login(email, password);

    if (!mounted) return;

    if (loginResult.success ||
        loginResult.responseType == LoginResponseType.otpRequired) {
      Navigator.pushNamed(context, '/login_otp_screen', arguments: {
        'email': loginResult.email ?? email,
      });
    } else if (loginResult.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginResult.message!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  l10n.welcomeBack,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  l10n.loginToYourAccount,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Input
                CustomTextField(
                  controller: _emailController,
                  hintText: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterYourEmail;
                    }
                    if (!value.contains('@')) {
                      return l10n.pleaseEnterAValidEmailAddress;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Input
                CustomTextField(
                  controller: _passwordController,
                  hintText: l10n.password,
                  obscureText: !loginViewModel.isPasswordVisible,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      loginViewModel.isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      loginViewModel.togglePasswordVisibility();
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordCannotBeEmpty;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ResetPasswordScreen');
                    },
                    child: Text(
                      l10n.forgotUserOrPassword,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                GradientButton(
                  text: l10n.login,
                  width: double.infinity,
                  onPressed: loginViewModel.isLoading ? null : _handleLogin,
                  isLoading: loginViewModel.isLoading,
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/create_account');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: l10n.dontHaveAnAccount + ' '),
                          TextSpan(
                            text: l10n.signUp,
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
