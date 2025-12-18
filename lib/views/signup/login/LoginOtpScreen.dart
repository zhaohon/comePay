import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
// For WidgetsBinding
import 'dart:math';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  // Kita akan membutuhkan 5 controller, satu untuk setiap TextField
  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  // Fokus node untuk mengatur perpindahan fokus antar TextField
  final List<FocusNode> _otpFocusNodes = List.generate(5, (_) => FocusNode());

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 2; // Asumsi ini adalah langkah ke-2

  late LoginViewModel _loginViewModel;
  String _email =
      "john.doe3@example.com"; // Default email, will be updated from arguments

  @override
  void initState() {
    super.initState();
    _loginViewModel = getIt<LoginViewModel>();

    // Get arguments from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _email = args['email'] ?? _email;
      }
      setState(() {});
    });

    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 &&
            i < _otpControllers.length - 1) {
          _otpFocusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _loginViewModel.clearError();
    super.dispose();
  }

  Widget _buildProgressIndicator(
      int totalSteps, int currentStep, double screenWidth) {
    double defaultIndicatorWidth = max(screenWidth * 0.2, 60.0);
    double activeIndicatorWidth = max(screenWidth * 0.2, 60.0);
    double indicatorHeight = max(screenWidth * 0.008, 3.0);
    double iconSize = max(screenWidth * 0.045, 16.0);
    double maxItemHeight = indicatorHeight + iconSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps, (index) {
        bool isActive = index + 1 == currentStep;
        double currentIndicatorWidth =
            isActive ? activeIndicatorWidth : defaultIndicatorWidth;

        return Container(
          margin:
              EdgeInsets.symmetric(horizontal: max(screenWidth * 0.015, 4.0)),
          width: currentIndicatorWidth,
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
                    color: isActive
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
                  color: isActive ? Colors.blueAccent : Colors.grey[500],
                  size: iconSize,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOtpTextField(
      TextEditingController controller,
      FocusNode focusNode,
      bool isLast,
      double screenWidth,
      double screenHeight) {
    return Container(
      width: max(screenWidth * 0.12, 40.0),
      height: max(screenWidth * 0.15, 50.0),
      margin: EdgeInsets.only(right: isLast ? 0 : max(screenWidth * 0.02, 6.0)),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
            fontSize: max(screenWidth * 0.06, 18.0),
            color: Colors.black,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide:
                BorderSide(color: Colors.blueAccent.withOpacity(0.7), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(vertical: max(screenHeight * 0.02, 12.0)),
        ),
        onChanged: (value) {
          if (value.length == 1 && focusNode != _otpFocusNodes.last) {
            FocusScope.of(context).requestFocus(
                _otpFocusNodes[_otpFocusNodes.indexOf(focusNode) + 1]);
          } else if (value.isEmpty && focusNode != _otpFocusNodes.first) {
            FocusScope.of(context).requestFocus(
                _otpFocusNodes[_otpFocusNodes.indexOf(focusNode) - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: _loginViewModel,
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            extendBodyBehindAppBar: true,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
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
                      // Column utama untuk layout
                      children: <Widget>[
                        Expanded(
                          // Konten yang bisa di-scroll mengambil ruang yang tersedia
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: max(screenWidth * 0.06, 16.0),
                              vertical: max(screenHeight * 0.025, 20.0),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // SizedBox atas bisa disesuaikan atau dihilangkan
                                  // jika ingin konten lebih terpusat secara default
                                  SizedBox(
                                      height: max(screenHeight * 0.03, 20.0)),
                                  Text(
                                    AppLocalizations.of(context)!.pleaseEnterTheCode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: max(screenWidth * 0.07, 20.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                      height: max(screenHeight * 0.015, 12.0)),
                                  Text(
                                    "${AppLocalizations.of(context)!.weSentEmailTo} $_email",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: max(screenWidth * 0.04, 14.0),
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  SizedBox(
                                      height: max(screenHeight * 0.04, 24.0)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return _buildOtpTextField(
                                          _otpControllers[index],
                                          _otpFocusNodes[index],
                                          index == 4,
                                          screenWidth,
                                          screenHeight);
                                    }),
                                  ),
                                  SizedBox(
                                      height: max(screenHeight * 0.03, 16.0)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.didntGetACode,
                                        style: TextStyle(
                                            fontSize:
                                                max(screenWidth * 0.0375, 14.0),
                                            color:
                                                Colors.white.withOpacity(0.8)),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          // Call resend OTP
                                          final result =
                                              await viewModel.resendOtp(_email);

                                          if (result.success) {
                                            // Show success message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result.message ??
                                                    'New OTP sent to your email'),
                                                backgroundColor:
                                                    Color(0xFF34495E),
                                              ),
                                            );
                                          } else {
                                            // Show error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result.message ??
                                                    'Failed to resend OTP'),
                                                backgroundColor:
                                                    Color(0xFF34495E),
                                              ),
                                            );
                                          }

                                          // Clear OTP input fields after resend attempt
                                          for (var controller
                                              in _otpControllers) {
                                            controller.clear();
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.sendAgain,
                                          style: TextStyle(
                                            fontSize:
                                                max(screenWidth * 0.0375, 14.0),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent[100],
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                Colors.blueAccent[100],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: max(screenHeight * 0.05, 32.0)),
                                  // Show loading indicator when verifying OTP
                                  if (viewModel.isLoading)
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                max(screenHeight * 0.02, 16.0),
                                            horizontal:
                                                max(screenWidth * 0.2, 40.0)),
                                        textStyle: TextStyle(
                                            fontSize:
                                                max(screenWidth * 0.045, 16.0),
                                            fontWeight: FontWeight.bold),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed: () async {
                                        String otp = _otpControllers
                                            .map(
                                                (controller) => controller.text)
                                            .join();
                                        if (otp.length == 5) {
                                          // Call OTP verification
                                          final result = await viewModel
                                              .verifyOtp(_email, otp);

                                          if (result.success) {
                                            // Navigate to welcome back screen
                                            Navigator.pushReplacementNamed(
                                                context,
                                                '/login_welcomback_screen');
                                          } else {
                                            // Show error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(result.message ??
                                                    'Login failed. Please try again.'),
                                                backgroundColor:
                                                    Color(0xFF34495E),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please fill all OTP fields')),
                                          );
                                        }
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.verify,
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  // SizedBox besar di bawah tombol "Entered" dihilangkan dari sini
                                  // karena indikator progres akan mengisi ruang di bawah.
                                  // Jika Anda masih ingin ada jarak tambahan sebelum indikator
                                  // (misalnya jika konten sangat pendek), Anda bisa menambahkan
                                  // Spacer() di sini di dalam Column ini, atau
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween pada Column ini.
                                  // Namun, dengan Expanded, biasanya tidak perlu.
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Indikator Progres di luar SingleChildScrollView, di bagian bawah Column
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: max(screenHeight * 0.05,
                                20.0), // Jarak dari bawah layar
                            top: max(screenHeight * 0.02,
                                10.0), // Jarak dari konten scrollable di atasnya
                          ),
                          child: _buildProgressIndicator(_totalProgressSteps,
                              _currentProgressStep, screenWidth),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
