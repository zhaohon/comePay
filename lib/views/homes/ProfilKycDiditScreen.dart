import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilkycDiditScreen extends StatefulWidget {
  final String url;

  const ProfilkycDiditScreen({Key? key, required this.url}) : super(key: key);

  @override
  _ProfilkycDiditScreenState createState() => _ProfilkycDiditScreenState();
}

class _ProfilkycDiditScreenState extends State<ProfilkycDiditScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setupWebView();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
    ].request();
  }

  void _setupWebView() {
    // Platform-specific params
    final params = defaultTargetPlatform == TargetPlatform.iOS
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {},
          onPageStarted: (url) {},
          onPageFinished: (url) {},
          onWebResourceError: (error) {},
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..loadRequest(Uri.parse(widget.url));

    final platformController = _controller.platform;

    // Handle general permissions
    platformController.setOnPlatformPermissionRequest((request) {
      request.grant();
    });

    // Android-specific
    if (platformController is AndroidWebViewController) {
      platformController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (params) async {
          return const GeolocationPermissionsResponse(
            allow: true,
            retain: true,
          );
        },
        onHidePrompt: () {},
      );
      platformController.setMediaPlaybackRequiresUserGesture(false);
      // setSettings() tidak lagi tersedia di versi terbaru
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'KYC',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
