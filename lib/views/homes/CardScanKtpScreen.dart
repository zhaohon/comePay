import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanKtpOverlayScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScanKtpOverlayScreen({super.key, required this.cameras});

  @override
  State<ScanKtpOverlayScreen> createState() => _ScanKtpOverlayScreenState();
}

class _ScanKtpOverlayScreenState extends State<ScanKtpOverlayScreen> {
  CameraController? controller;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
    setState(() => isCameraReady = true);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCameraReady
          ? Stack(
        children: [
          // Camera
          CameraPreview(controller!),

          // Overlay dengan frame kotak
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: OverlayPainter(),
          ),

          // Judul + instruksi
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Scan document",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Now hold the phone directly over the ID card,\nwhen the frame turns blue, take the picture.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Tombol capture
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final image = await controller!.takePicture();
                  print("Image saved: ${image.path}");
                  Navigator.pushNamed(context, '/Cardselvieverificationscreen');
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 6),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// Custom Painter untuk overlay dengan corner frame biru
class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Ukuran kotak KTP di tengah
    final holeWidth = size.width * 0.85;
    final holeHeight = 200.0;
    final left = (size.width - holeWidth) / 2;
    final top = (size.height - holeHeight) / 2.5; // sedikit lebih ke atas
    final holeRect = Rect.fromLTWH(left, top, holeWidth, holeHeight);

    // Path penuh layar
    final background = Path()..addRect(rect);
    // Lubang kotak
    final cutout = Path()..addRect(holeRect);

    // Gabungkan dengan even-odd fill
    canvas.drawPath(
      Path.combine(PathOperation.difference, background, cutout),
      paint,
    );

    // Corner guide (garis biru di sudut)
    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;

    // Kiri atas
    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), borderPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + cornerLength), borderPaint);

    // Kanan atas
    canvas.drawLine(
        Offset(left + holeWidth, top),
        Offset(left + holeWidth - cornerLength, top),
        borderPaint);
    canvas.drawLine(
        Offset(left + holeWidth, top),
        Offset(left + holeWidth, top + cornerLength),
        borderPaint);

    // Kiri bawah
    canvas.drawLine(
        Offset(left, top + holeHeight),
        Offset(left + cornerLength, top + holeHeight),
        borderPaint);
    canvas.drawLine(
        Offset(left, top + holeHeight),
        Offset(left, top + holeHeight - cornerLength),
        borderPaint);

    // Kanan bawah
    canvas.drawLine(
        Offset(left + holeWidth, top + holeHeight),
        Offset(left + holeWidth - cornerLength, top + holeHeight),
        borderPaint);
    canvas.drawLine(
        Offset(left + holeWidth, top + holeHeight),
        Offset(left + holeWidth, top + holeHeight - cornerLength),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
