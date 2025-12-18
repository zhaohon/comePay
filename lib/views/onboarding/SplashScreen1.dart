import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // --- Ukuran Font Responsif ---
    final double titleFontSize = screenWidth * 0.06; // Misal 6% dari lebar layar
    final double descriptionFontSize = screenWidth * 0.038; // Misal 3.8% dari lebar layar
    final double buttonFontSize = screenWidth * 0.035;

    // --- Padding dan Spasi Responsif ---
    final double horizontalPadding = screenWidth * 0.08; // Misal 8% untuk padding horizontal umum
    final double verticalSpacingSmall = screenHeight * 0.015; // Spasi kecil
    final double verticalSpacingMedium = screenHeight * 0.03; // Spasi sedang (pengganti SizedBox(height: 24))
    final double descriptionTopPadding = screenHeight * 0.05; // Padding atas untuk deskripsi

    // --- Ukuran Indikator Responsif ---
    final double indicatorHeight = 5.0;
    final double activeIndicatorWidth = screenWidth * 0.12; // Indikator aktif lebih lebar
    final double inactiveIndicatorWidth = screenWidth * 0.06; // Indikator tidak aktif

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1F252D),
        child: FadeTransition(
          opacity: _animation,
          child: SafeArea(
            child: Column(
              children: [
                // Bagian atas (gambar + judul)
                Expanded(
                  flex: 7, // Sedikit disesuaikan untuk memberi lebih banyak ruang jika teks judul panjang
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, // Agar judul rata kiri
                      children: [
                        // Gambar
                        Center( // Pusatkan gambar di dalam kolomnya
                          child: Image.asset(
                            'assets/onboarding1.png', // PASTIKAN GAMBAR INI ADA
                            width: screenWidth * 0.75, // Sedikit lebih besar jika perlu
                            height: screenHeight * 0.35, // Batasi tinggi gambar agar tidak terlalu dominan
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: verticalSpacingMedium),

                        // Judul
                        Text(
                          AppLocalizations.of(context)!.forEveryDreamWithComeComePay,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize * textScaleFactor,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bagian tengah (deskripsi)
                Expanded(
                  flex: 3, // Sedikit disesuaikan
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: descriptionTopPadding,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: verticalSpacingSmall, // Tambahkan padding bawah
                    ),
                    child: Align(
                      alignment: Alignment.topLeft, // Jaga agar rata kiri
                      child: Text(
                        AppLocalizations.of(context)!.fasility,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: descriptionFontSize * textScaleFactor,
                          height: 1.5,
                        ),
                        // maxLines: 3, // Batasi jika perlu
                        // overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // Bagian bawah (indicator + tombol skip)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: inactiveIndicatorWidth,
                            height: indicatorHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(indicatorHeight / 2),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.015),
                          Container(
                            width: activeIndicatorWidth,
                            height: indicatorHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(indicatorHeight / 2),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login_screen');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.012,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonFontSize * textScaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01), // Sedikit ruang di paling bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}
