import 'package:flutter/material.dart';
import 'SplashScreen1.dart'; // Pastikan path ini benar
import 'SplashScreen2.dart'; // Pastikan path ini benar

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Contoh fungsi untuk pindah ke halaman berikutnya dengan animasi
  void _nextPage() {
    if (_currentPage < 1) { // Sesuaikan dengan jumlah halaman Anda - 1
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500), // Durasi animasi
        curve: Curves.easeInOut, // Jenis kurva animasi
      );
    }
  }

  // Contoh fungsi untuk pindah ke halaman sebelumnya dengan animasi
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Membuat efek 'bounce' saat swipe
        children: const [
          SplashScreen2(), // Halaman pertama (indeks 0)
          SplashScreen1(), // Halaman kedua (indeks 1)
          // Tambahkan halaman lain jika ada
        ],
      ),
    );
  }
}
