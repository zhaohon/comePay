import 'package:flutter/material.dart';
import 'package:comecomepay/views/homes/CardCompliteStatusScreen.dart';

class CardCompliteScreen extends StatefulWidget {
  const CardCompliteScreen({super.key});

  @override
  _CardCompliteScreenState createState() => _CardCompliteScreenState();
}

class _CardCompliteScreenState extends State<CardCompliteScreen> {
  @override
  void initState() {
    super.initState();
    // 3秒后自动跳转到状态页
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CardCompliteStatusScreen(),
          ),
        );
      }
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
