import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';

class ReceiveDetailScreen extends StatefulWidget {
  const ReceiveDetailScreen({super.key});

  @override
  _ReceiveDetailScreenState createState() => _ReceiveDetailScreenState();
}

class _ReceiveDetailScreenState extends State<ReceiveDetailScreen> {
  late Map<String, dynamic> token;
  late String network;
  late String walletAddress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    token = args['token'];
    network = args['network'];

    debugPrint('=== ReceiveDetailScreen didChangeDependencies ===');
    debugPrint('token symbol: ${token['symbol']}');
    debugPrint('token chain: ${token['chain']}');
    debugPrint('token networks: ${token['networks']}');
    debugPrint('network: $network');
    debugPrint('token tokenAddressKey: ${token['tokenAddressKey']}');
    debugPrint('token full keys: ${token.keys.toList()}');

    // Access WalletViewModel to get wallet data
    final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
    final wallets = walletViewModel.walletResponse?.data.wallets ?? [];
    debugPrint('total wallets count: ${wallets.length}');
    
    for (final w in wallets) {
      debugPrint(
        'wallet chain=${w.chain}, '
        'firstAddress=${w.firstAddress}, '
        'tokenAddresses=${w.tokenAddresses}',
      );
    }

    // Find the wallet matching the token's chain (BTC/ETH/BNB/MATIC/BASE/TRX/SOL)
    final tokenChain = token['chain'] as String? ?? '';
    debugPrint('=== Looking for wallet with chain: "$tokenChain" ===');
    
    final matchingWallet = wallets.firstWhere(
      (wallet) {
        final matches = wallet.chain == tokenChain;
        debugPrint('  comparing wallet.chain="${wallet.chain}" == tokenChain="$tokenChain" => $matches');
        return matches;
      },
      orElse: () {
        debugPrint('  ❌ NO MATCHING WALLET FOUND for chain="$tokenChain"');
        return Wallet(
          id: 0,
          idWallet: '',
          idUser: 0,
          tenantId: '',
          tenantExternalId: '',
          chain: '',
          firstAddress: '',
          tokenAddresses: {},
          createdAt: '',
          updatedAt: '',
        );
      },
    );

    debugPrint('=== Matching wallet result ===');
    debugPrint('matchingWallet.chain: "${matchingWallet.chain}"');
    debugPrint('matchingWallet.firstAddress: "${matchingWallet.firstAddress}"');
    debugPrint('matchingWallet.tokenAddresses: ${matchingWallet.tokenAddresses}');

    // Set walletAddress:
    // - 对于 BTC/ETH/HKD 等主币，直接用 firstAddress
    // - 对于 USDT/USDC 等代币，从 tokenAddresses['USDT'/'USDC'] 里取，取不到就回退 firstAddress
    if (matchingWallet.chain.isNotEmpty) {
      final String? tokenKey = token['tokenAddressKey'] as String?;
      debugPrint('=== Getting address ===');
      debugPrint('tokenAddressKey: $tokenKey');
      
      if (tokenKey != null && tokenKey.isNotEmpty) {
        final tokenAddr = matchingWallet.tokenAddresses[tokenKey];
        debugPrint('tokenAddresses[$tokenKey] = $tokenAddr');
        walletAddress = tokenAddr ?? matchingWallet.firstAddress;
        debugPrint('final walletAddress (from tokenAddresses): "$walletAddress"');
      } else {
        walletAddress = matchingWallet.firstAddress;
        debugPrint('final walletAddress (from firstAddress): "$walletAddress"');
      }
    } else {
      // Fallback if no matching wallet found
      walletAddress = 'No wallet address available';
      debugPrint('❌ walletAddress set to: "$walletAddress" (no matching wallet)');
    }
    
    debugPrint('=== Final walletAddress ===');
    debugPrint('walletAddress: "$walletAddress"');
    debugPrint('==========================================');
  }

  // Constants for maintainability (disesuaikan dengan persentase layar)
  final double kPaddingFactor =
      0.04; // 4% dari lebar layar sebagai padding/margin dasar
  final double kQRSizeFactor = 0.4; // 40% dari lebar layar untuk QR code
  final double kLogoHeightFactor = 0.1; // 10% dari lebar layar untuk logo
  final double kButtonHeightFactor = 0.07; // 7% dari tinggi layar untuk tombol
  final double kMarginFactor = 0.02; // 2% dari lebar/tinggi layar untuk margin

  void _showShareBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * kMarginFactor, // Margin kiri dan kanan
            vertical: screenHeight * kMarginFactor, // Margin atas dan bawah
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: screenWidth * 0.13, // 13% dari lebar layar
                height: screenHeight * 0.01, // 1% dari tinggi layar
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preview",
                  style: TextStyle(
                    fontSize: 18 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Preview Card
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * kMarginFactor),
                child: Container(
                  width: screenWidth * 0.7, // 80% dari lebar layar
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03,
                    horizontal: screenWidth * kPaddingFactor,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, screenHeight * 0.01),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: screenWidth * 0.07, // 7% dari lebar layar
                        backgroundColor: Colors.grey.shade200,
                        child: Image.asset(
                          token['iconPath'],
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        () {
                          final symbol = token['symbol'] as String? ?? '';
                          // BTC / ETH / HKD 不需要括号，其它带上网络
                          if (symbol == 'BTC' ||
                              symbol == 'ETH' ||
                              symbol == 'HKD') {
                            return "Receive $symbol";
                          }
                          return "Receive $symbol ($network)";
                        }(),
                        style: TextStyle(
                          fontSize: 20 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Only support receiving $network network assets",
                        style: TextStyle(
                          fontSize: 13 * MediaQuery.of(context).textScaleFactor,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // QR Code
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue, width: 4),
                          color: Colors
                              .blue, // Latar belakang biru untuk area kotak QR
                        ),
                        child: Column(
                          children: [
                            // QR Code dengan logo tengah
                            QrImageView(
                              data: walletAddress,
                              version: QrVersions.auto,
                              size: screenWidth *
                                  kQRSizeFactor, // 40% dari lebar layar
                              backgroundColor: Colors
                                  .white, // Latar belakang QR code itu sendiri (putih)
                              embeddedImage: const AssetImage(
                                  'assets/frame_logomark.png'), // Gambar dari assets
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(screenWidth * 0.15,
                                    screenWidth * 0.15), // 15% dari lebar layar
                                // Opsional: Tambahkan color jika ingin overlay warna pada logo
                              ),
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square, // Bentuk mata QR
                                color: Colors.blue, // Warna mata QR
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                color: Colors.black, // Warna modul data QR
                                dataModuleShape: QrDataModuleShape
                                    .square, // Bentuk modul data
                              ),
                              errorCorrectionLevel: QrErrorCorrectLevel
                                  .H, // Tingkat koreksi error tinggi
                            ),
                            // Wallet Address + Copy (opsional, tambahkan sesuai kebutuhan)
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Address
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                walletAddress,
                                style: TextStyle(
                                  fontSize: 13 *
                                      MediaQuery.of(context).textScaleFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: walletAddress));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Wallet address copied")),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Branding
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/which.png', // Replace with Come Come Pay logo
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            color: Colors.black54,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "Come Come Pay Wallet",
                            style: TextStyle(
                              fontSize:
                                  13 * MediaQuery.of(context).textScaleFactor,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareAction(
                    context,
                    iconWidget: Image.asset('assets/save.png',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: "Save",
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(walletAddress);
                    },
                  ),
                  _buildShareAction(
                    context,
                    iconWidget: Image.asset('assets/copylink.png',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: "Copy link",
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(walletAddress);
                    },
                  ),
                  _buildShareAction(
                    context,
                    iconWidget: Image.asset('assets/whatsapp.png',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: "WhatsApp",
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(walletAddress);
                    },
                  ),
                  _buildShareAction(
                    context,
                    iconWidget: Image.asset('assets/telegram.png',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: "Telegram",
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(walletAddress);
                    },
                  ),
                  _buildShareAction(
                    context,
                    iconWidget: Image.asset('assets/wechat.png',
                        width: screenWidth * 0.06, height: screenWidth * 0.06),
                    label: "WeChat",
                    onTap: () async {
                      Navigator.pop(context);
                      await Share.share(walletAddress);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareAction(
    BuildContext context, {
    Widget? iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06, // 6% dari lebar layar
            backgroundColor: Colors.grey.shade200,
            child: iconWidget ?? const SizedBox.shrink(),
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            label,
            style: TextStyle(
                fontSize: 12 * MediaQuery.of(context).textScaleFactor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    debugPrint('=== ReceiveDetailScreen build ===');
    debugPrint('walletAddress in build: "$walletAddress"');
    debugPrint('token symbol: ${token['symbol']}');
    debugPrint('network: $network');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      screenWidth * kMarginFactor, // Margin kiri dan kanan
                  vertical:
                      screenHeight * kMarginFactor, // Margin atas dan bawah
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    CircleAvatar(
                      radius: screenWidth * 0.08,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset(
                        token['iconPath'],
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * kPaddingFactor),
                    // Title
                    Text(
                      () {
                        final symbol = token['symbol'] as String? ?? '';
                        if (symbol == 'BTC' ||
                            symbol == 'ETH' ||
                            symbol == 'HKD') {
                          return "Receive $symbol";
                        }
                        return "Receive $symbol ($network)";
                      }(),
                      style: TextStyle(
                        fontSize: 24 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Subtitle
                    Text(
                      "Only support receiving $network network assets",
                      style: TextStyle(
                        fontSize: 14 * textScaleFactor,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * kPaddingFactor * 2),
                    // QR Code Box
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue, width: 4),
                        color: Colors
                            .blue, // Latar belakang biru untuk area kotak QR
                      ),
                      child: Column(
                        children: [
                          // QR Code dengan logo tengah
                          QrImageView(
                            data: walletAddress,
                            version: QrVersions.auto,
                            size: screenWidth *
                                kQRSizeFactor, // 40% dari lebar layar
                            backgroundColor: Colors
                                .white, // Latar belakang QR code itu sendiri (putih)
                            embeddedImage: const AssetImage(
                                'assets/frame_logomark.png'), // Gambar dari assets
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: Size(screenWidth * 0.15,
                                  screenWidth * 0.15), // 15% dari lebar layar
                              // Opsional: Tambahkan color jika ingin overlay warna pada logo
                            ),
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square, // Bentuk mata QR
                              color: Colors.blue, // Warna mata QR
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              color: Colors.black, // Warna modul data QR
                              dataModuleShape:
                                  QrDataModuleShape.square, // Bentuk modul data
                            ),
                            errorCorrectionLevel: QrErrorCorrectLevel
                                .H, // Tingkat koreksi error tinggi
                          ),
                          // Wallet Address + Copy (opsional, tambahkan sesuai kebutuhan)
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * kPaddingFactor * 2),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth *
                            kMarginFactor, // Margin kiri dan kanan
                      ),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, screenHeight * 0.005),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                walletAddress,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14 * textScaleFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: walletAddress));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Wallet address copied")),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Promo Banner
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight *
                            kMarginFactor, // Margin atas dan bawah
                        horizontal: screenWidth *
                            kMarginFactor, // Margin kiri dan kanan
                      ),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, screenHeight * 0.005),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.card_giftcard, color: Colors.blue),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                "Send USDT on Tron - 2gas - free transactions, 50% off gas fee forever. Try it now!",
                                style:
                                    TextStyle(fontSize: 13 * textScaleFactor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: screenWidth * kMarginFactor),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * kButtonHeightFactor,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showShareBottomSheet(context),
                child: Text(
                  "Share with sender",
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * kMarginFactor),
        ],
      ),
    );
  }
}
