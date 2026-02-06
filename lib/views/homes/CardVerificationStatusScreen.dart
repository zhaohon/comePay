import 'package:Demo/views/homes/CardCompliteStatusScreen.dart'
    show CardCompliteStatusScreen;
import 'package:flutter/material.dart';

// Ganti StatelessWidget dengan StatefulWidget
class CardVerificationStatusScreen extends StatefulWidget {
  const CardVerificationStatusScreen({super.key});

  @override
  State<CardVerificationStatusScreen> createState() =>
      _CardVerificationStatusScreenState();
}

class _CardVerificationStatusScreenState
    extends State<CardVerificationStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // Ganti dengan halaman berikutnya (contoh: Navigator.push)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const CardCompliteStatusScreen(), // Ganti dengan halaman tujuan
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Latar belakang abu-abu muda seperti gambar
      appBar: AppBar(
        // 1. Toolbar: Tombol back, title di tengah
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Tombol back
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Title di tengah
        backgroundColor: Colors.white,
        elevation: 0, // Tanpa shadow untuk flat seperti gambar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding keseluruhan
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Title
              const Text(
                'Verification Status',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // 3. Subtitle
              const Text(
                'The system is reviewing your documents.\nThis will take about 2 minutes.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              // 4. 2 buah button vertical dengan icon dan text
              // Button 1: Dokumen
              ElevatedButton.icon(
                onPressed: () {
                  // Aksi untuk dokumen (kosong untuk demo)
                },
                icon: const Icon(Icons.document_scanner,
                    color: Colors.white, size: 24),
                label: const Text(
                  'Under review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Warna biru seperti gambar
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 50), // Lebar penuh, tinggi 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 12),
              // Button 2: Selfie/Foto
              ElevatedButton.icon(
                onPressed: () {
                  // Aksi untuk foto (kosong untuk demo)
                },
                icon: const Icon(Icons.photo_camera,
                    color: Colors.white, size: 24),
                label: const Text(
                  'Under review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Warna biru seperti gambar
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 50), // Lebar penuh, tinggi 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
              const Spacer(), // Ruang kosong untuk mendorong text ke bawah
              // 5. Text paling bawah
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Your verification status will change automatically\n',
                    ),
                    const TextSpan(
                      text:
                          'once the review is complete. If you experience any\n',
                    ),
                    const TextSpan(
                      text: 'issues, contact support.',
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20), // Jarak bawah
            ],
          ),
        ),
      ),
    );
  }
}
