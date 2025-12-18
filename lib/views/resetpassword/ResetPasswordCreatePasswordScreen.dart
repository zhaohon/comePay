import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/forgot_password_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class ResetPasswordCreatePasswordScreen extends StatelessWidget {
  const ResetPasswordCreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => getIt<ForgotPasswordViewModel>(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return _ResetPasswordCreatePasswordScreenContent(
              viewModel: viewModel);
        },
      ),
    );
  }
}

class _ResetPasswordCreatePasswordScreenContent extends StatefulWidget {
  final ForgotPasswordViewModel viewModel;

  const _ResetPasswordCreatePasswordScreenContent({required this.viewModel});

  @override
  State<_ResetPasswordCreatePasswordScreenContent> createState() =>
      _ResetPasswordCreatePasswordScreenContentState();
}

class _ResetPasswordCreatePasswordScreenContentState
    extends State<_ResetPasswordCreatePasswordScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Untuk _buildProgressIndicator
  final int _totalProgressSteps = 3; // Misal ada 3 langkah total
  final int _currentProgressStep = 2; // Langkah saat ini adalah ke-2

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';

      final result = await widget.viewModel.resetPasswordCreatePassword(
        email: email,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        Navigator.pushNamed(
          context,
          '/ResetPasswordCreatePasswordVerificationScreen',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'An error occurred'),
            backgroundColor: Color(0xFF34495E),
          ),
        );
      }
    }
  }

  Widget _buildProgressIndicator(
      int totalSteps, int currentActiveStep, double screenWidth) {
    double defaultIndicatorWidth = max(screenWidth * 0.2, 60.0);
    double activeIndicatorWidth = max(screenWidth * 0.2, 60.0);
    double indicatorHeight = max(screenWidth * 0.008, 3.0);
    double iconSize = max(screenWidth * 0.045, 16.0);
    double maxItemHeight = indicatorHeight + iconSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps, (index) {
        bool isStepCompletedOrActive = index < currentActiveStep;
        return Container(
          margin:
              EdgeInsets.symmetric(horizontal: max(screenWidth * 0.015, 4.0)),
          width: activeIndicatorWidth,
          height: maxItemHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    color: isStepCompletedOrActive
                        ? Colors.blueAccent.withOpacity(0.8)
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(indicatorHeight / 2),
                  ),
                ),
              ),
              Positioned(
                bottom: indicatorHeight - 0.2,
                child: Icon(
                  Icons.circle,
                  color: isStepCompletedOrActive
                      ? Colors.blueAccent
                      : Colors.grey[500],
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
            stops: [0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            // Column utama untuk layout atas-ke-bawah
            children: <Widget>[
              Expanded(
                // Konten form akan mengambil ruang yang tersedia
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: 20.0, // Bisa disesuaikan jika perlu
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Default rata kiri untuk children form
                      children: <Widget>[
                        SizedBox(
                            height:
                                screenHeight * 0.02), // Spasi setelah AppBar
                        Center(
                          // Membuat judul "Create Password" di tengah
                          child: Text(
                            AppLocalizations.of(context)!.createPassword,
                            style: TextStyle(
                              fontSize: max(screenWidth * 0.07, 20.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: max(screenHeight * 0.015, 12.0)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: Text(
                            AppLocalizations.of(context)!.passwordMustBe8Characters,
                            textAlign: TextAlign.center, // Subjudul di tengah
                            style: TextStyle(
                              fontSize: max(screenWidth * 0.04, 14.0),
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.5),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.password,
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 16.5),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.blueAccent.withOpacity(0.7),
                                  width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.red.shade700, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.red.shade700, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 20.0),
                          ),
                          validator: _validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Title
                         Text(
                          AppLocalizations.of(context)!.confirmPassword,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.5),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .confirmPassword,
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 16.5),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.blueAccent.withOpacity(0.7),
                                  width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.red.shade700, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Colors.red.shade700, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 20.0),
                          ),
                          validator: _validateConfirmPassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        SizedBox(
                            height:
                                screenHeight * 0.05), // Spasi sebelum tombol

                        // Button Continue
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: screenWidth * 0.25),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                            ),
                            onPressed: _isLoading ? null : _submitForm,
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.continues,
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                            height: screenHeight *
                                0.02), // Sedikit spasi di akhir scroll view jika perlu
                      ],
                    ),
                  ),
                ),
              ),
              // Progress Indicator di luar Expanded, akan berada di bawah
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.03 > 20
                      ? screenHeight * 0.03
                      : 20.0, // Pastikan padding bawah cukup
                  top: screenHeight * 0.01 > 10
                      ? screenHeight * 0.01
                      : 10.0, // Sedikit padding atas
                ),
                child: _buildProgressIndicator(
                    _totalProgressSteps, _currentProgressStep, screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
