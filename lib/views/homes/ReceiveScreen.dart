import 'package:flutter/material.dart';
import 'package:Demo/l10n/app_localizations.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:Demo/views/homes/widgets/token_network_list.dart';

class TokenReceiveScreen extends StatelessWidget {
  const TokenReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double totalAssets =
        ModalRoute.of(context)?.settings.arguments as double? ?? 0.0;
    return _TokenReceiveScreenContent(totalAssets: totalAssets);
  }
}

class _TokenReceiveScreenContent extends StatefulWidget {
  final double totalAssets;
  const _TokenReceiveScreenContent({required this.totalAssets});

  @override
  _TokenReceiveScreenContentState createState() =>
      _TokenReceiveScreenContentState();
}

class _TokenReceiveScreenContentState
    extends State<_TokenReceiveScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,

      // AppBar
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.receive,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),

      // Body
      body: TokenNetworkList(totalAssets: widget.totalAssets),
    );
  }
}
