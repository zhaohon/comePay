import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/forgot_password_viewmodel.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:provider/provider.dart';

class ResetPasswordConfirmEmailScreen extends StatefulWidget {
  const ResetPasswordConfirmEmailScreen({super.key});

  @override
  _ResetPasswordConfirmEmailScreenState createState() =>
      _ResetPasswordConfirmEmailScreenState();
}

class _ResetPasswordConfirmEmailScreenState
    extends State<ResetPasswordConfirmEmailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String email = 'comecomepay@info.com';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Get the email from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          email = args;
        });
      } else {
        // Fallback if no email provided
        email = 'your email';
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => getIt<ForgotPasswordViewModel>(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0xFF2C3E50), // Warna gelap di tengah
                    Color(0xFF34495E), // Warna sedikit lebih terang di luar
                  ],
                  stops: [0.4, 1.0],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 50.0,
                      left: 20.0,
                      right: 20.0,
                      bottom: 30.0), // Padding utama untuk semua konten
                  child: FadeTransition(
                    opacity: _animation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // 1. Icon di tengah agak naik dengan padding
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 24.0,
                              top: 16.0,
                              left: 16.0,
                              right: 16.0), // Padding untuk icon
                          child: Image.asset(
                            'assets/abstract.png', // Pastikan file ini ada di folder assets
                            width: 350, // Sesuaikan ukuran icon
                            height: 350, // Sesuaikan ukuran icon
                          ),
                        ),
                        const SizedBox(
                            height: 20), // Jarak antara icon dan title

                        // 2. Title "Confirm Your Email"
                        Text(
                          AppLocalizations.of(context)!.confirmYourEmail,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                            height: 8), // Jarak antara title dan subtitle

                        // 3. Subtitle "We sent email to [email]"
                        Text(
                          AppLocalizations.of(context)!.weSentEmailTo +
                              " $email",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(
                            height: 80), // Jarak antara subtitle dan button

                        // 4. Button "confirmasi"
                        ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol diklik
                            Navigator.pushNamed(
                                context, '/ResetPasswordOtpScreen',
                                arguments: email);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Warna tombol
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.confirm,
                            style: TextStyle(
                                color: Colors
                                    .white), // Tambahkan ini jika teks tidak terlihat
                          ),
                        ),
                        const Spacer(), // Jarak antara button dan subtitle bawah

                        // 5. Subtitle "I didn’t receive my email"
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            bottom: 40.0,
                          ),
                          child: InkWell(
                            onTap: viewModel.isLoading
                                ? null
                                : () async {
                                    final response =
                                        await viewModel.forgotPassword(email);
                                    if (response != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Password reset email resent to $email')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                viewModel.errorMessage ??
                                                    'Failed to resend email')),
                                      );
                                    }
                                  },
                            child: RichText(
                              // GANTI Text DENGAN RichText
                              textAlign: TextAlign
                                  .center, // Tetap pusatkan seluruh RichText
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors
                                      .white70, // Warna default untuk "I " dan " my email"
                                  decorationColor: Colors.white70,
                                ),
                                children: <TextSpan>[
                                  const TextSpan(
                                      text:
                                          'I '), // Bagian pertama dengan style default
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .didnReceive, // Bagian yang ingin diubah warnanya
                                    style: const TextStyle(
                                      color: Colors
                                          .blueAccent, // Warna biru untuk bagian ini
                                      // Anda bisa menambahkan fontWeight atau properti style lain di sini jika perlu
                                      // fontSize dan decoration akan diwarisi dari style induk jika tidak di-override
                                    ),
                                  ),
                                  TextSpan(
                                      text: ' ' +
                                          AppLocalizations.of(context)!
                                              .myEmail), // Bagian terakhir dengan style default
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
