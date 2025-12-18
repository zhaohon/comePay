import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Cardselviecamerascreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Cardselviecamerascreen({super.key, required this.cameras});

  @override
  State<Cardselviecamerascreen> createState() => _CardselviecamerascreenState();
}

class _CardselviecamerascreenState extends State<Cardselviecamerascreen> {
  late CameraController _controller;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      widget.cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraReady
          ? Column(
        children: [
          // Bagian atas: Title dan subtitle, dengan padding atas untuk posisi paling atas
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Selfie verification",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Hold your phone at eye level and look directly into the camera,\nwhen the frame turns blue take a photo",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Frame di tengah: Gunakan CustomPaint untuk frame dengan sudut
          Expanded(
            flex: 3,
            child: Center(
              child: CustomPaint(
                painter: CornerFramePainter(),
                child: Container(
                  width: 200, // Sesuaikan dengan gambar
                  height: 200, // Sesuaikan dengan gambar
                  child: ClipRect(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0, // Pastikan proporsi persegi
                        child: Container(
                          width: 200, // Ukuran pratinjau
                          height: 200, // Ukuran pratinjau
                          child: CameraPreview(_controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bagian bawah: Tombol capture bulat paling bawah
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final image = await _controller.takePicture();
                      // TODO: save or process photo
                      Navigator.pushNamed(context, '/CardVerificationStatusScreen');
                    } catch (e) {
                      debugPrint("Error taking photo: $e");
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

/// 🎨 Painter untuk membuat frame dengan sudut seperti gambar
class CornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30; // Panjang garis sudut sesuai gambar
    const double innerBoxSize = 100; // Ukuran area garis dalam
    const double padding = 10; // Padding di antara garis dan pratinjau
    const double previewSize = innerBoxSize - 2 * padding; // Ukuran pratinjau (80 piksel)
    final double outerBoxSize = size.width; // Ukuran total frame (150)

    // Pastikan size.width sama dengan size.height untuk frame persegi
    assert(size.width == size.height, "Frame harus berbentuk persegi");

    // Garis luar kotak
    canvas.drawRect(
      Rect.fromLTWH(0, 0, outerBoxSize, outerBoxSize),
      paint..strokeWidth = 1, // Garis luar tipis
    );

    // Garis dalam kotak (area pratinjau dengan padding)
    canvas.drawRect(
      Rect.fromLTWH(
        (outerBoxSize - innerBoxSize) / 2,
        (outerBoxSize - innerBoxSize) / 2,
        innerBoxSize,
        innerBoxSize,
      ),
      paint..strokeWidth = 5, // Garis biru tebal untuk pratinjau
    );

    // Garis sudut luar
    // Kiri atas
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);
    // Kanan atas
    canvas.drawLine(Offset(outerBoxSize, 0), Offset(outerBoxSize - cornerLength, 0), paint);
    canvas.drawLine(Offset(outerBoxSize, 0), Offset(outerBoxSize, cornerLength), paint);
    // Kiri bawah
    canvas.drawLine(Offset(0, outerBoxSize), Offset(cornerLength, outerBoxSize), paint);
    canvas.drawLine(Offset(0, outerBoxSize), Offset(0, outerBoxSize - cornerLength), paint);
    // Kanan bawah
    canvas.drawLine(Offset(outerBoxSize, outerBoxSize), Offset(outerBoxSize - cornerLength, outerBoxSize), paint);
    canvas.drawLine(Offset(outerBoxSize, outerBoxSize), Offset(outerBoxSize, outerBoxSize - cornerLength), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}