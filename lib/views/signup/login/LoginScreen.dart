import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'dart:math';
import 'package:comecomepay/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showLoginForm = false;

  // Controllers untuk form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Offset logo berdasarkan state dan tinggi layar (contoh sederhana)
    final double logoTextOffsetY =
        _showLoginForm ? -screenHeight * 0.02 : -screenHeight * 0.15;

    // Padding responsif dengan minimum
    final EdgeInsets formPadding = EdgeInsets.symmetric(
        horizontal: max(screenWidth * 0.05, 16.0),
        vertical: max(screenHeight * 0.01, 8.0));
    final EdgeInsets generalPadding =
        EdgeInsets.all(max(screenWidth * 0.04, 12.0));

    Widget loginWidgets;
    if (_showLoginForm) {
      loginWidgets = KeyedSubtree(
        key: const ValueKey('loginForm'),
        child: Padding(
          padding: formPadding,
          child: Column(
            key: const ValueKey('loginFormColumn'),
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.loginToYourAccount,
                textAlign: TextAlign
                    .center, // Tambahkan agar lebih baik di layar sempit
                style: TextStyle(
                  fontSize: max(screenWidth * 0.06, 18.0), // Minimum 18px
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: max(screenWidth * 0.04, 14.0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: max(screenWidth * 0.04, 12.0),
                      vertical: max(screenHeight * 0.015, 12.0)),
                ),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: max(screenWidth * 0.04, 14.0)),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _passwordFocusNode.requestFocus();
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !Provider.of<LoginViewModel>(context, listen: true)
                    .isPasswordVisible,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: max(screenWidth * 0.04, 14.0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: max(screenWidth * 0.04, 12.0),
                      vertical: max(screenHeight * 0.015, 12.0)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Provider.of<LoginViewModel>(context, listen: true)
                              .isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Provider.of<LoginViewModel>(context, listen: false)
                          .togglePasswordVisibility();
                    },
                  ),
                ),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: max(screenWidth * 0.04, 14.0)),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  _handleLogin();
                },
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                onPressed: Provider.of<LoginViewModel>(context).isLoading
                    ? null
                    : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity,
                      max(screenHeight * 0.06, 48.0)), // Minimum 48px height
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Provider.of<LoginViewModel>(context).isLoading
                    ? SizedBox(
                        width: max(screenWidth * 0.04, 16.0),
                        height: max(screenWidth * 0.04, 16.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.login,
                        style:
                            TextStyle(fontSize: max(screenWidth * 0.04, 16.0))),
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/ResetPasswordScreen');
                  },
                  child: Text(
                    AppLocalizations.of(context)!.forgotUserOrPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: max(screenWidth * 0.035, 14.0)),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Image.asset(
                'assets/finger.png',
                width: max(screenWidth * 0.18, 48.0), // Minimum 48px
                height: max(screenWidth * 0.18, 48.0),
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pushNamed(context, '/create_account');
                    });
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: screenWidth * 0.035,
                            decoration: TextDecoration.none,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: AppLocalizations.of(context)!.dontHaveAnAccount,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: max(screenWidth * 0.035, 14.0),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.signUp,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: max(screenWidth * 0.035, 14.0),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
            ],
          ),
        ),
      );
    } else {
      loginWidgets = KeyedSubtree(
        key: const ValueKey('actionButtons'),
        child: Transform.translate(
          offset: Offset(0, -screenHeight * 0.05), // Offset responsif
          child: Padding(
            padding: formPadding,
            child: Column(
              key: const ValueKey('actionButtonsColumn'),
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_account');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(double.infinity, max(screenHeight * 0.06, 48.0)),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.getStarted,
                      style:
                          TextStyle(fontSize: max(screenWidth * 0.04, 16.0))),
                ),
                SizedBox(height: screenHeight * 0.015),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showLoginForm = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(double.infinity, max(screenHeight * 0.06, 48.0)),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.login,
                      style:
                          TextStyle(fontSize: max(screenWidth * 0.04, 16.0))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use constraints for more precise control if needed, but keep MediaQuery for simplicity
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: 1.0, // Radius bisa juga dibuat adaptif jika perlu
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF34495E),
                ],
                stops: [0.4, 1.0],
              ),
            ),
            // Gunakan SafeArea untuk menghindari elemen UI terpotong oleh notch atau status bar
            child: SafeArea(
              child: Padding(
                padding: generalPadding,
                // Struktur Column utama dengan Expanded untuk bagian atas dan SingleChildScrollView untuk bagian bawah (form)
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform:
                              Matrix4.translationValues(0, logoTextOffsetY, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FadeTransition(
                                opacity: _animation,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  // Ukuran logo responsif
                                  width: max(
                                      _showLoginForm
                                          ? screenWidth * 0.28
                                          : screenWidth * 0.35,
                                      80.0), // Minimum 80px
                                  height: max(
                                      _showLoginForm
                                          ? screenWidth * 0.28
                                          : screenWidth * 0.35,
                                      80.0),
                                  child: Image.asset(
                                    'assets/which.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: max(screenHeight * 0.01, 8.0)),
                              FadeTransition(
                                opacity: _animation,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    'Come Come Pay',
                                    style: TextStyle(
                                      // Ukuran font teks logo responsif
                                      fontSize: max(
                                          _showLoginForm
                                              ? screenWidth * 0.05
                                              : screenWidth * 0.06,
                                          20.0), // Minimum 20px
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bagian form atau tombol aksi sekarang di dalam SingleChildScrollView
                    // untuk menangani konten yang mungkin lebih panjang dari sisa ruang.
                    SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: loginWidgets,
                      ),
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

  // Method untuk handle login with enhanced response handling
  Future<void> _handleLogin() async {
    // Get viewmodel dari provider
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    // Clear previous error
    loginViewModel.clearError();

    // Get email dan password dari controllers
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Call login method
    final loginResult = await loginViewModel.login(email, password);

    if (loginResult.success) {
      // Login berhasil - navigate to OTP screen
      if (mounted) {
        Navigator.pushNamed(context, '/login_otp_screen', arguments: {
          'email': loginResult.email,
        });
      }
    } else {
      // Handle different error scenarios
      if (loginResult.responseType == LoginResponseType.otpRequired) {
        // HTTP 403 - Navigate to OTP screen
        if (mounted) {
          Navigator.pushNamed(context, '/login_otp_screen', arguments: {
            'email': loginResult.email,
          });
        }
      } else if (loginResult.responseType == LoginResponseType.error) {
        // HTTP 401 or other errors - show error message
        if (mounted && loginResult.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginResult.message!),
              backgroundColor: Color(0xFF34495E),
            ),
          );
        }
      }
    }
  }
}
