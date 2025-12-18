import 'dart:math' as math;
import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({Key? key}) : super(key: key);

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
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
    // Membuat animasi dari 0.0 ke 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Opsional: Navigasi setelah beberapa detik
    Future.delayed(const Duration(seconds: 4), () {
      // Beri waktu lebih untuk animasi dan tampilan
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login_screen');
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // --- Ukuran dan Posisi Responsif untuk Kartu ---
    // Ukuran dasar kartu (bisa disesuaikan)
    final double cardBaseWidth =
        screenWidth * 0.55; // Misal 55% dari lebar layar
    final double cardBaseHeight =
        screenHeight * 0.3; // Misal 30% dari tinggi layar

    // Penyesuaian ukuran untuk masing-masing kartu agar terlihat berbeda
    final double card1Width =
        cardBaseWidth * 0.9; // kartu paling depan sedikit lebih kecil
    final double card1Height = cardBaseHeight * 0.9;
    final double card2Width = cardBaseWidth * 1.1; // kartu tengah lebih besar
    final double card2Height = cardBaseHeight * 1.1;
    final double card3Width = cardBaseWidth; // kartu belakang
    final double card3Height = cardBaseHeight;

    // Posisi relatif untuk kartu (perlu eksperimen untuk tampilan terbaik)
    // Menggunakan persentase dari screenHeight dan screenWidth

    // Kartu 1 (paling depan)
    // Lebih ke kiri atas
    final double card1Top = screenHeight * 0.02; // Sedikit dari atas
    final double card1Left = screenWidth * 0.05; // Sedikit dari kiri

    // Kartu 2 (tengah)
    // Sedikit ke kanan dan bawah dari kartu 1
    final double card2Top = screenHeight * 0.10;
    // Posisi tengah dikurangi setengah lebar kartu agar lebih terpusat, lalu digeser
    final double card2Left =
        (screenWidth / 2) - (card2Width / 2) + (screenWidth * 0.05);

    // Kartu 3 (paling belakang)
    // Lebih ke kanan bawah
    final double card3Top = screenHeight * 0.18;
    // Posisi dari kanan
    final double card3Right = screenWidth * 0.05; // Sedikit dari kanan

    // Padding responsif
    final EdgeInsets symmetricPadding = EdgeInsets.symmetric(
        horizontal: screenWidth * 0.07,
        vertical: screenHeight * 0.02); // 7% horizontal, 2% vertical
    final EdgeInsets allPadding = EdgeInsets.all(screenWidth * 0.05); // 5%

    // Ukuran font responsif
    final double titleFontSize = screenWidth * 0.05; // 5% dari lebar layar
    final double descriptionFontSize =
        screenWidth * 0.035; // 3.5% dari lebar layar

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1F252D),
        child: FadeTransition(
          opacity: _animation,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5, // Area untuk Stack kartu
                  child: Stack(
                    alignment: Alignment
                        .topLeft, // Default alignment, bisa disesuaikan
                    children: [
                      // Kartu 3 (paling belakang)
                      Positioned(
                        top: card3Top,
                        right: card3Right,
                        child: Transform.rotate(
                          angle: 10 *
                              math.pi /
                              180, // Angle sedikit diubah agar lebih terlihat
                          child: Image.asset(
                            'assets/card3.png',
                            width: card3Width,
                            height: card3Height,
                            fit: BoxFit
                                .contain, // Gunakan contain agar rasio aspek terjaga
                          ),
                        ),
                      ),

                      // Kartu 2 (tengah)
                      Positioned(
                        top: card2Top,
                        left: card2Left,
                        child: Transform.rotate(
                          angle: -5 * math.pi / 180, // Angle sedikit diubah
                          child: Image.asset(
                            'assets/card2.png',
                            width: card2Width,
                            height: card2Height,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Kartu 1 (paling depan/luar)
                      Positioned(
                        top: card1Top,
                        left: card1Left,
                        child: Transform.rotate(
                          angle: -2 * math.pi / 180,
                          child: Image.asset(
                            'assets/card1.png',
                            width: card1Width,
                            height: card1Height,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Judul
                Padding(
                  padding: symmetricPadding.copyWith(
                      bottom: screenHeight *
                          0.01), // Sesuaikan vertical padding jika perlu
                  child: Text(
                    AppLocalizations.of(context)!.manageCripto,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize *
                          textScaleFactor, // Terapkan textScaleFactor
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Deskripsi
                Expanded(
                  flex: 2, // Lebih sedikit ruang untuk deskripsi
                  child: Padding(
                    padding: symmetricPadding.copyWith(top: 0),
                    child: Text(
                      AppLocalizations.of(context)!.manageCriptoDesc,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: descriptionFontSize *
                            textScaleFactor, // Terapkan textScaleFactor
                        height: 1.5,
                      ),
                      maxLines: 3, // Batasi jumlah baris untuk deskripsi juga
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Bagian bawah (indicator + tombol skip)
                Padding(
                  padding: allPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width:
                                screenWidth * 0.15, // Lebar indikator responsif
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          SizedBox(
                              width: screenWidth * 0.01), // Spasi responsif
                          Container(
                            width:
                                screenWidth * 0.08, // Lebar indikator responsif
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                                context, '/login_screen');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                screenWidth * 0.05, // Padding tombol responsif
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: descriptionFontSize *
                                textScaleFactor *
                                0.9, // Ukuran font tombol
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: screenHeight *
                        0.01), // Sedikit padding di bagian paling bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}
