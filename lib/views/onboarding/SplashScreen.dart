import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Durasi animasi fade-in
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Defer authentication check to after build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Load authentication data dari storage
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await loginViewModel.loadAuthDataFromStorage();

    // Navigasi setelah animasi selesai dengan sedikit penundaan tambahan
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            // Check jika user sudah login dan ada token
            if (loginViewModel.hasStoredAuthData &&
                loginViewModel.storedAccessToken != null &&
                loginViewModel.storedRefreshToken != null) {
              // User sudah login, langsung ke home
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              // User belum login, ke onboarding
              Navigator.pushReplacementNamed(context, '/onboarding_screen');
            }
          }
        });
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
    // Gunakan SafeArea untuk menghindari notch atau status bar
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final smallestDimension =
              screenWidth < screenHeight ? screenWidth : screenHeight;

          // Ukuran logo disesuaikan dengan 35% dari dimensi terkecil, dibatasi untuk layar ekstrem
          final logoSize = smallestDimension *
              0.35; // 35% untuk visibilitas yang lebih baik pada layar besar

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0, // Radius lebih fleksibel untuk semua rasio layar
                colors: [
                  Color(0xFF2C3E50), // Warna gelap di tengah
                  Color(0xFF34495E), // Warna sedikit lebih terang di luar
                ],
                stops: [
                  0.4,
                  1.0
                ], // Sesuaikan stops untuk efek gradien yang lebih natural
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/which.png', // Pastikan path benar dan didefinisikan di pubspec.yaml
                  width: logoSize.clamp(
                      100, 300), // Batasan ukuran logo (100-300 piksel)
                  height: logoSize.clamp(100, 300), // Batasan ukuran logo
                  fit: BoxFit.contain, // Menjaga proporsi gambar
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
