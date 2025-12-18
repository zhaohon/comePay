import 'package:flutter/material.dart';
import 'CardVerifyIdentityScreen.dart';

class CardCompliteApplyScreen extends StatefulWidget {
  const CardCompliteApplyScreen({super.key});

  @override
  _CardCompliteApplyScreenState createState() => _CardCompliteApplyScreenState();
}

class _CardCompliteApplyScreenState extends State<CardCompliteApplyScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // navy background
      body: Stack(
        children: [
          // Background gradient / wave effect di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    Color(0xFF1B263B),
                    Color(0xFF0D1B2A),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Completed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),

                // Gambar asset
                Image.asset(
                  "assets/cardcomplite.png",
                  width: 500,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
