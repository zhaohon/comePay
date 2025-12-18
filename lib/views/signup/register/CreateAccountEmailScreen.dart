import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/signup_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/services/global_service.dart';

class CreateAccountEmailScreen extends StatefulWidget {
  const CreateAccountEmailScreen({super.key});

  @override
  _CreateAccountEmailScreenState createState() =>
      _CreateAccountEmailScreenState();
}

class _CreateAccountEmailScreenState extends State<CreateAccountEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailFormatPotentiallyCorrect = false;

  // ViewModel
  late final SignupViewModel _signupViewModel;
  late final GlobalService _globalService;

  final int _totalProgressSteps = 3;
  final int _currentProgressStep = 1;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateEmailFormatStatus);
    _signupViewModel = getIt<SignupViewModel>();
    _globalService = getIt<GlobalService>();
  }

  void _updateEmailFormatStatus() {
    // Regex yang lebih ketat untuk validasi format email dasar
    final emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
    final bool isCurrentlyPotentiallyCorrect =
        emailRegExp.hasMatch(_emailController.text);
    if (_isEmailFormatPotentiallyCorrect != isCurrentlyPotentiallyCorrect) {
      // Hanya panggil setState jika ada perubahan status untuk efisiensi
      setState(() {
        _isEmailFormatPotentiallyCorrect = isCurrentlyPotentiallyCorrect;
      });
    }
  }

  Future<void> _validateEmailAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      // The loading state is managed by the ViewModel
      final result =
          await _signupViewModel.validateEmail(_emailController.text);

      // Check if still mounted to avoid calling setState on unmounted widget
      if (!mounted) return;

      if (result.success) {
        // Send email with OTP after successful validation
        print(
            '🔥 [EMAIL VALIDATION] Email validation successful, sending OTP email...');
        final otp = _signupViewModel.emailValidationResponse?.otp;
        final email = _emailController.text;

        if (otp != null && email.isNotEmpty) {
          print(
              '🔥 [EMAIL VALIDATION] OTP and email available, calling sendEmail...');
          // Use email prefix as name since we don't have full name yet
          final name = email.split('@').first;
          try {
            final emailSent = await _globalService.sendEmail(email, name, otp);
            if (emailSent) {
              print('🔥 [EMAIL VALIDATION] OTP email sent successfully');
              // Navigate to confirmation screen with response data
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
              print('🔥 [EMAIL VALIDATION] Failed to send OTP email');
              _showErrorAlert('Gagal mengirim email OTP. Silakan coba lagi.');
            }
          } catch (e) {
            print(
                '🔥 [EMAIL VALIDATION] Exception while sending OTP email: $e');
            _showErrorAlert('Gagal mengirim email OTP. Silakan coba lagi.');
          }
        } else {
          print(
              '🔥 [EMAIL VALIDATION] Missing OTP or email for sending: OTP=$otp, Email=$email');
          _showErrorAlert('Data OTP tidak lengkap. Silakan coba lagi.');
        }
      } else {
        // Show error alert - loading state is already reset by ViewModel
        _showErrorAlert(result.message ?? 'Terjadi kesalahan');
      }
    }
  }

  void _showErrorAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF34495E),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateEmailFormatStatus);
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
    // Mendapatkan informasi ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Menentukan apakah ada error validasi pada field email
    // Ini membantu suffixIcon agar tidak muncul jika ada pesan error.
    // Pengecekan _formKey.currentState != null penting sebelum memanggil validate()
    bool emailFieldHasError = false;
    if (_formKey.currentState != null && _emailController.text.isNotEmpty) {
      // Kita asumsikan jika tidak valid, maka ada error
      emailFieldHasError = !_formKey.currentState!.validate();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Pertimbangkan menggunakan Snackbar atau logging yang lebih baik
              debugPrint(
                  "Tidak bisa kembali, ini adalah halaman root atau satu-satunya halaman.");
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
            radius:
                1.0, // Radius bisa disesuaikan berdasarkan ukuran layar jika perlu
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
            stops: [0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, // 6% dari lebar layar
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.05), // 5% dari tinggi layar
                  Text(
                    AppLocalizations.of(context)!.whatsYourEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          28, // Pertimbangkan menggunakan textScaleFactor atau ukuran dinamis
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!
                        .enterTheEmailAddressYouWantToUseToRegisterWithCCP,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // Pertimbangkan menggunakan textScaleFactor
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04), // 4% dari tinggi layar

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black, fontSize: 16.5),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.emailAddress,
                      hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5), fontSize: 16.5),
                      suffixIcon: (_isEmailFormatPotentiallyCorrect &&
                              !emailFieldHasError &&
                              _emailController.text.isNotEmpty)
                          ? const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.check_circle,
                                  color: Colors.green, size: 22),
                            )
                          : null,
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
                        borderSide:
                            BorderSide(color: Colors.red.shade700, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: Colors.red.shade700, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 20.0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      _updateEmailFormatStatus();
                      // Panggil validasi form di sini jika Anda ingin feedback error
                      // langsung muncul saat pengguna mengetik dan setelah kondisi tertentu.
                      // Namun, autovalidateMode.onUserInteraction biasanya sudah cukup.
                      // _formKey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // Jika validasi gagal, pastikan suffix icon disembunyikan
                        if (_isEmailFormatPotentiallyCorrect) {
                          // Gunakan Future.microtask untuk menghindari error setState selama build
                          Future.microtask(() => setState(
                              () => _isEmailFormatPotentiallyCorrect = false));
                        }
                        return AppLocalizations.of(context)!
                            .pleaseEnterYourEmail;
                      }
                      final emailRegExp = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                      if (!emailRegExp.hasMatch(value)) {
                        if (_isEmailFormatPotentiallyCorrect) {
                          Future.microtask(() => setState(
                              () => _isEmailFormatPotentiallyCorrect = false));
                        }
                        return AppLocalizations.of(context)!
                            .pleaseEnterAValidEmailAddress;
                      }
                      // Jika valid, pastikan _isEmailFormatPotentiallyCorrect sudah true
                      // (seharusnya sudah dihandle oleh listener)
                      // Jika belum, bisa di-set di sini juga.
                      if (!_isEmailFormatPotentiallyCorrect) {
                        Future.microtask(() => setState(
                            () => _isEmailFormatPotentiallyCorrect = true));
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                      height: screenHeight * 0.025), // 2.5% dari tinggi layar

                  GestureDetector(
                    onTap: () {
                      debugPrint('Log in here tapped');
                      Navigator.pushReplacementNamed(context, '/login_screen');
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 15, color: Colors.white.withOpacity(0.8)),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  AppLocalizations.of(context)!.haveAnAccount +
                                      " "),
                          TextSpan(
                            text: AppLocalizations.of(context)!.logInHere,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent[100],
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blueAccent[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.07), // 7% dari tinggi layar

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal:
                                screenWidth * 0.1), // Lebar tombol dinamis
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _signupViewModel.isLoading
                          ? null
                          : _validateEmailAndNavigate,
                      child: _signupViewModel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.continues,
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08), // 8% dari tinggi layar
                  _buildProgressIndicator(
                      _totalProgressSteps, _currentProgressStep),
                  SizedBox(height: screenHeight * 0.05), // 5% dari tinggi layar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
