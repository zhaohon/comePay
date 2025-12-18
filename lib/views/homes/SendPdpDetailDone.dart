import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'SendScreen.dart';

class SendPdpDetailDone extends StatelessWidget {
  const SendPdpDetailDone({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.01, // 1% dari tinggi layar (diperbaiki dari 0.10)
          left: screenWidth * 0.04, // 4% dari lebar layar
          right: screenWidth * 0.04, // 4% dari lebar layar
          bottom: screenHeight * 0.02, // 2% dari tinggi layar
        ), // Padding untuk kanan, kiri, atas, dan bawah
        child: Column(
          children: [
            Spacer(flex: 1), // Mengisi ruang di atas untuk memusatkan konten
            Icon(
              Icons.check_circle_outline, // Ikon contoh (bisa diganti)
              size: 100.0 * textScaleFactor, // Ukuran ikon disesuaikan dengan textScaleFactor
              color: Colors.green, // Warna ikon sesuai konteks (bisa disesuaikan)
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
            Text(
              'USDT Send',
              style: TextStyle(
                fontSize: 24 * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
            Text(
              'Your transaction has been sent to the network and will be processed \nin a few seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * textScaleFactor,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.04), // 4% dari tinggi layar
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // 4% dari lebar layar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recipient',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                          Text(
                            '401e72588b...',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sum',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                          Text(
                            '0.02 BTC',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gas fee',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                          Text(
                            '-0.00051003 BTC',
                            style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(flex: 1), // Mengisi ruang di bawah card hingga tombol
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(screenWidth * 0.9, screenHeight * 0.07), // 90% lebar, 7% tinggi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Navigasi ke SendScreen dan hapus rute sebelumnya kecuali SendScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Sendscreen()),
                        (Route<dynamic> route) => route.settings.name == '/sendScreen', // Hanya mempertahankan SendScreen
                  );
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
          ],
        ),
      ),
    );
  }
}