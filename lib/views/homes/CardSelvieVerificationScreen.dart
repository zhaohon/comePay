import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'CardSelvieCameraScreen.dart';


class Cardselvieverificationscreen extends StatelessWidget {
  const Cardselvieverificationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F2E), // warna gelap navy
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Judul
            Text(
              "Selfie verification",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subjudul
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "We will complete the photo in your document with your selfie to confirm your identity",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 0),

            // Ilustrasi wajah
            Expanded(
              child: Center(
                child: Image.asset(
                  "assets/autofocus.png", // ganti dengan ilustrasi wajah
                  width: 300,
                  height: 300,
                ),
              ),
            ),

            // Tombol kamera
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6CF7), Color(0xFF6B8CFF)], // gradasi biru
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final cameras = await availableCameras(); // pastikan sudah import package camera
                    // if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cardselviecamerascreen(cameras: cameras),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, // supaya tidak menimpa gradient
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Open camera",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Informasi keamanan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "The data you share will be encrypted, stored securely, and only used to verify your identity",
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
