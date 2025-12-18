import 'package:comecomepay/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';

class CreatePasswordVerificationScreen extends StatelessWidget {
  const CreatePasswordVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 3. Ada toolbar icon back nya juga.
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan bayangan AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white70), // Warna ikon back
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Jika tidak bisa pop (misalnya ini halaman pertama setelah login)
              // Anda mungkin ingin navigasi ke halaman login atau home
              debugPrint("Tidak bisa kembali dari VerificationSuccessScreen.");
              // Contoh: Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
            }
          },
        ),
        // Anda bisa menambahkan title di AppBar jika diperlukan,
        // namun biasanya untuk halaman sukses seperti ini, title utama ada di body.
        // title: Text("Success", style: TextStyle(color: Colors.white70)),
        // centerTitle: true,
      ),
      extendBodyBehindAppBar:
          true, // Membuat body gradient terlihat di belakang AppBar
      body: Container(
        // 1. Warna samakan dengan yang lain & 2. Ada gradient warnanya.
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2C3E50), // Warna gelap di tengah
              Color(0xFF34495E), // Warna sedikit lebih terang di luar
            ],
            stops: [0.4, 1.0], // Titik henti untuk gradient
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        // Padding umum untuk konten di dalam SafeArea
        // padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Dipindahkan ke dalam Column jika diperlukan padding spesifik per elemen
        child: SafeArea(
          // Memastikan konten tidak terhalang oleh notch atau status bar
          child: Padding(
            // Padding ditambahkan di sini untuk seluruh Column
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Pusatkan semua item secara vertikal
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Membuat item mengambil lebar penuh jika diperlukan (misal button)
              children: <Widget>[
                // 1. Title
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20.0), // Jarak bawah setelah title
                  child: Text(
                    AppLocalizations.of(context)!.verificationSuccess,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, // Ukuran font bisa disesuaikan
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Warna teks putih
                    ),
                  ),
                ),

                // 2. Gambar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0), // Jarak atas dan bawah
                  child: Center(
                    // Memastikan gambar di tengah
                    child: Image.asset(
                      'assets/illustration.png', // Pastikan path ini benar
                      width: screenWidth *
                          0.55, // Ukuran gambar disesuaikan sedikit
                      height: screenHeight *
                          0.28, // Ukuran gambar disesuaikan sedikit
                      fit: BoxFit.contain, // Agar gambar tidak terpotong
                      errorBuilder: (context, error, stackTrace) {
                        // Tampilkan placeholder atau pesan error jika gambar gagal dimuat
                        return Container(
                          width: screenWidth * 0.55,
                          height: screenHeight * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.grey[700]?.withOpacity(
                                0.5), // Warna placeholder lebih lembut
                            borderRadius: BorderRadius.circular(
                                12), // Tambahkan border radius
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
                ),

                // 3. Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16.0), // Jarak atas, bawah, kiri, kanan
                  child: Text(
                    AppLocalizations.of(context)!.verificationSuccessDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // Ukuran font bisa disesuaikan
                      color: Colors.white.withOpacity(
                          0.85), // Warna teks putih dengan sedikit transparansi
                    ),
                  ),
                ),

                // 4. Button
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0,
                      bottom: 20.0,
                      left: 40.0,
                      right: 40.0), // Jarak atas, bawah, kiri, kanan
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Warna tombol
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // Aksi ketika tombol ditekan
                      Navigator.pushNamedAndRemoveUntil(context,
                          '/login_screen', (Route<dynamic> route) => false);
                    },
                    child:  Text(
                      AppLocalizations.of(context)!.startNow,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                // Jika Anda ingin elemen paling bawah (misalnya progress indicator dari VerificationScreen)
                // bisa ditambahkan di sini. Untuk halaman sukses, biasanya tidak ada.
                // Spacer(), // Bisa digunakan jika ada elemen lain di bawah tombol
              ],
            ),
          ),
        ),
      ),
    );
  }
}
