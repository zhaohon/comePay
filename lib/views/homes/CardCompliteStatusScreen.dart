import 'package:flutter/material.dart';
import 'package:Demo/views/homes/CardScreen.dart';

class CardCompliteStatusScreen extends StatefulWidget {
  const CardCompliteStatusScreen({super.key});

  @override
  _CardCompliteStatusScreenState createState() =>
      _CardCompliteStatusScreenState();
}

class _CardCompliteStatusScreenState extends State<CardCompliteStatusScreen> {
  @override
  void initState() {
    super.initState();
    // 3秒后返回CardScreen（卡片首页）
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CardScreen(),
          ),
          (route) => false, // 清除所有之前的页面
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
