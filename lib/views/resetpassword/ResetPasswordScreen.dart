import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/forgot_password_viewmodel.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 1;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator(int totalSteps, int currentStep) {
    const double defaultIndicatorWidth = 80.0;
    const double activeIndicatorWidth = 80.0;
    const double indicatorHeight = 3.0;
    const double iconSize = 18.0;
    const double maxItemHeight = indicatorHeight + iconSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps, (index) {
        bool isActive = index + 1 == currentStep;
        double currentIndicatorWidth =
            isActive ? activeIndicatorWidth : defaultIndicatorWidth;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
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
                child: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height: kToolbarHeight +
                                          (screenHeight * 0.02)),
                                  Text(
                                    AppLocalizations.of(context)!.passwordReset,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .enterRegisterEmailPassword,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.05),
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16.5),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .emailAddress,
                                      hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 16.5),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 15.0, right: 10.0),
                                        child: Icon(Icons.email_outlined,
                                            color: Colors.grey),
                                      ),
                                      suffixIcon: (_formKey.currentState
                                                      ?.validate() ??
                                                  false) &&
                                              _emailController.text.isNotEmpty
                                          ? const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 12.0),
                                              child: Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 22),
                                            )
                                          : null,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: Colors.blueAccent
                                                .withOpacity(0.7),
                                            width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade700,
                                            width: 1.5),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: Colors.red.shade700,
                                            width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18.0, horizontal: 20.0),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegExp = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                                      if (!emailRegExp.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: screenHeight * 0.04),
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                final response = await viewModel
                                                    .forgotPassword(
                                                        _emailController.text);
                                                if (response != null) {
                                                  // Call send email API after successful forgot password
                                                  final emailSent =
                                                      await viewModel.sendEmail(
                                                    response.email,
                                                    response.name ?? 'User',
                                                    response.otp,
                                                  );

                                                  if (emailSent) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Password reset email sent to ${_emailController.text}'),
                                                          backgroundColor:
                                                              Color(
                                                                  0xFF34495E)),
                                                    );
                                                    Navigator.pushNamed(context,
                                                        '/ResetPasswordConfirmEmailScreen',
                                                        arguments:
                                                            _emailController
                                                                .text);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'Failed to send email notification'),
                                                          backgroundColor:
                                                              Color(
                                                                  0xFF34495E)),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(viewModel
                                                                .errorMessage ??
                                                            'Failed to send reset email'),
                                                        backgroundColor:
                                                            Color(0xFF34495E)),
                                                  );
                                                }
                                              }
                                            },
                                      child: viewModel.isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text(
                                              AppLocalizations.of(context)!
                                                  .continues,
                                              style: TextStyle(
                                                  color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.05),
                                  _buildProgressIndicator(_totalProgressSteps,
                                      _currentProgressStep),
                                  SizedBox(height: screenHeight * 0.03),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.policies,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
