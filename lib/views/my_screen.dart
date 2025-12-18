import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Latar belakang putih
        elevation: 0, // Hilangkan bayangan
        title: Row(
          children: [
            Image.asset(
              'assets/pokepay_logo.png', // Logo PokePay (ganti dengan path yang sesuai)
              height: 30, // Sesuaikan ukuran logo
            ),
            SizedBox(width: 10), // Jarak antara logo dan teks
            Text(
              'My',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text(
          'My Page',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
