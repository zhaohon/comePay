import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/views/homes/widgets/token_network_list_send.dart';

class Sendscreen extends StatelessWidget {
  const Sendscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double totalAssets =
        ModalRoute.of(context)?.settings.arguments as double? ?? 0.0;
    return _SendscreenContent(totalAssets: totalAssets);
  }
}

class _SendscreenContent extends StatefulWidget {
  final double totalAssets;
  const _SendscreenContent({required this.totalAssets});

  @override
  _SendscreenContentState createState() => _SendscreenContentState();
}

class _SendscreenContentState extends State<_SendscreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/home', (Route<dynamic> route) => false),
        ),
        title: Text(
          AppLocalizations.of(context)!.send,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TokenNetworkListSend(totalAssets: widget.totalAssets),
      ),
    );
  }
}
