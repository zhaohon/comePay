import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';

class LoginWelcomeBackScreen extends StatelessWidget {
  const LoginWelcomeBackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk responsivitas jika diperlukan,
    // namun untuk layout yang berpusat dan sederhana, mungkin tidak terlalu dibutuhkan.
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // AppBar tidak diminta, jadi saya hapus untuk tampilan yang lebih bersih
      // Jika Anda tetap memerlukan AppBar, Anda bisa menambahkannya kembali.
      body: Container(
        // Menetapkan warna latar belakang atau gradient jika diinginkan
        // Untuk contoh ini, saya akan gunakan warna solid sederhana.
        // Anda bisa menggantinya dengan gradient seperti di kode asli Anda jika perlu.
        color: const Color(0xFF2C3E50), // Contoh warna latar belakang
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          // Memastikan konten tidak terhalang oleh notch atau status bar
          child: Padding(
            // Padding keseluruhan untuk konten di dalam SafeArea
            // (atas, kiri, kanan, bawah)
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Pusatkan semua item secara vertikal
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Pusatkan item secara horizontal dalam Column
              children: <Widget>[
                // 1. Icon PNG di tengah
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0), // Jarak bawah setelah ikon
                  child: Image.asset(
                    'assets/welcomeback.png', // Pastikan path ini benar dan gambar ada di folder assets
                    width: 300, // Sesuaikan ukuran ikon sesuai kebutuhan
                    height: 300, // Sesuaikan ukuran ikon sesuai kebutuhan
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder jika gambar gagal dimuat
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[700]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Subtitle "Welcome back"
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 32.0), // Jarak bawah setelah subtitle
                  child: Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, // Ukuran font bisa disesuaikan
                      fontWeight: FontWeight.w600, // Sedikit tebal
                      color: Colors.white.withOpacity(0.9), // Warna teks
                    ),
                  ),
                ),

                // 3. Button "starterd"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Warna tombol
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0,
                        vertical: 15.0), // Padding dalam tombol
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30.0), // Membuat tombol lebih bulat
                    ),
                    elevation: 5, // Bayangan tombol
                  ),
                  onPressed: () {
                    // Aksi ketika tombol ditekan
                    // Misalnya, navigasi ke halaman berikutnya
                    // Contoh navigasi:
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (Route<dynamic> route) => false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.getStarted, // Teks tombol
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
