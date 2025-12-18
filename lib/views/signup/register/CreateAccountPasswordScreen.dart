import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/set_password_viewmodel.dart';

class CreateAccountPasswordScreen extends StatefulWidget {
  const CreateAccountPasswordScreen({super.key});

  @override
  State<CreateAccountPasswordScreen> createState() =>
      _CreateAccountPasswordScreenState();
}

class _CreateAccountPasswordScreenState
    extends State<CreateAccountPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Untuk _buildProgressIndicator
  final int _totalProgressSteps = 3; // Misal ada 3 langkah total
  final int _currentProgressStep =
      3; // Langkah saat ini adalah ke-3 (final step)

  // Response data from OTP verification
  String _email = '';
  String _message = '';
  String _referralCode = '';
  String _status = '';

  @override
  void initState() {
    super.initState();
    // Extract data from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        setState(() {
          _email = arguments['email'] as String? ?? '';
          _message = arguments['message'] as String? ?? '';
          _referralCode = arguments['referral_code'] as String? ?? '';
          _status = arguments['status'] as String? ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordCannotBeEmpty;
    }
    if (value.length < 8) {
      return AppLocalizations.of(context)!.passwordMustBeAtLeast8Characters;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLocalizations.of(context)!.passwordMustContainUppercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLocalizations.of(context)!.passwordMustContainNumber;
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppLocalizations.of(context)!.passwordMustContainSpecial;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.pleaseConfirmYourPassword;
    }
    if (value != _passwordController.text) {
      return AppLocalizations.of(context)!.passwordsDoNotMatch;
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

  void _submitForm(BuildContext context, SetPasswordViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Call ViewModel to set password
      final result = await viewModel.setPassword(
        email: _email,
        password: _passwordController.text,
      );

      if (result.success) {
        // Success: Show success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? AppLocalizations.of(context)!.passwordSetSuccessfully),
          ),
        );

        // Navigate to verification screen
        Navigator.pushNamed(
          context,
          '/create_account_verification',
          arguments: {
            'email': _email,
            'password': _passwordController.text,
            'referral_code': _referralCode,
            'status': _status,
          },
        );
      } else {
        // Failure: Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? AppLocalizations.of(context)!.failedToSetPassword),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProgressIndicator(int totalSteps, int currentActiveStep) {
    // ignore: unused_local_variable
    const double defaultIndicatorWidth = 80.0;
    const double activeIndicatorWidth = 80.0;
    const double indicatorHeight = 3.0;
    const double iconSize = 18.0;
    const double maxItemHeight = indicatorHeight + iconSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps, (index) {
        bool isStepCompletedOrActive = index < currentActiveStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
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

    return ChangeNotifierProvider(
      create: (context) => SetPasswordViewModel(),
      child: Consumer<SetPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
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
                                  height: screenHeight *
                                      0.02), // Spasi setelah AppBar
                              Center(
                                // Membuat judul "Create Password" di tengah
                                child: Text(
                                  AppLocalizations.of(context)!.createPassword,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04),
                                child: Text(
                                  _message.isNotEmpty
                                      ? _message
                                      : AppLocalizations.of(context)!.passwordMustBe8Characters,
                                  textAlign:
                                      TextAlign.center, // Subjudul di tengah
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ),
                              // Show referral code if available
                              if (_referralCode.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.card_giftcard,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${AppLocalizations.of(context)!.referralCodeLabel}$_referralCode',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
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
                                        color:
                                            Colors.blueAccent.withOpacity(0.7),
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
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
                                  hintText: AppLocalizations.of(context)!.confirmPassword,
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
                                        color:
                                            Colors.blueAccent.withOpacity(0.7),
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.05), // Spasi sebelum tombol

                              // Button Continue
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: screenWidth * 0.25),
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : () => _submitForm(context, viewModel),
                                  child: viewModel.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(AppLocalizations.of(context)!.continues,
                                          style:
                                              TextStyle(color: Colors.white)),
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
                          _totalProgressSteps, _currentProgressStep),
                    ),
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
