import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:comecomepay/utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// 扫码页面，用于扫描收款地址二维码，扫描成功后返回地址字符串。
class ScanAddressQrScreen extends StatefulWidget {
  const ScanAddressQrScreen({super.key});

  @override
  State<ScanAddressQrScreen> createState() => _ScanAddressQrScreenState();
}

class _ScanAddressQrScreenState extends State<ScanAddressQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _hasScanned = false;
  bool _isPermissionGranted = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _isPermissionGranted = true;
          _isCheckingPermission = false;
        });
      }
    } else {
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _isPermissionGranted = status.isGranted;
        _isCheckingPermission = false;
      });

      if (!status.isGranted) {
        _showPermissionDialog(status.isPermanentlyDenied);
      }
    }
  }

  void _showPermissionDialog(bool permanentlyDenied) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.scanQRCodeCameraRequired),
        content: Text(permanentlyDenied
            ? l10n.scanQRCodePermissionDeniedMessage
            : l10n.scanQRCodeCameraRequired),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit scan screen
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (permanentlyDenied) {
                await openAppSettings();
              } else {
                _requestPermission();
              }
            },
            child: Text(permanentlyDenied ? l10n.goToSettings : l10n.retry),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final list = capture.barcodes;
    if (list.isEmpty) return;
    final barcode = list.first;
    final String? value = barcode.rawValue ?? barcode.displayValue;
    if (value == null || value.trim().isEmpty) return;
    _hasScanned = true;
    if (!mounted) return;
    Navigator.pop(context, value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.scanQRCodeTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isPermissionGranted)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                final message =
                    error.errorDetails?.message ?? l10n.scanQRCodeError;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.white70),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Center(
              child: Icon(Icons.camera_alt_outlined,
                  size: 64, color: Colors.white24),
            ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              l10n.scanQRCodeHint,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
