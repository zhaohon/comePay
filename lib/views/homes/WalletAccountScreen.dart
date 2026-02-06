import 'package:flutter/material.dart';
import 'package:Demo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// ignore: unused_import
import '../../utils/LinePointer.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import 'widgets/token_network_list.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isVisible = true; // Toggle visibilitas Total Assets

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewModel>(context, listen: false).fetchWalletData();
    });
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
          title: Text(
            AppLocalizations.of(context)!.walletTitle,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/NotificationScreen');
              },
            ),
          ],
        ),
        body: Consumer<WalletViewModel>(
          builder: (context, walletViewModel, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;

            return RefreshIndicator(
              onRefresh: walletViewModel.fetchWalletData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Total Assets Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4D8F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _isVisible
                                    ? walletViewModel.getFormattedBalance()
                                    : "****",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              DropdownButton<String>(
                                value: walletViewModel.selectedCurrency,
                                dropdownColor: const Color(0xFF1A4D8F),
                                underline: Container(),
                                iconEnabledColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: walletViewModel.listAssets.keys
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    walletViewModel.selectCurrency(newValue);
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.totalAssets,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                _isVisible
                                    ? walletViewModel.totalAssets
                                        .toStringAsFixed(2)
                                    : "****",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMenuButton(
                            Icons.send,
                            AppLocalizations.of(context)!.send,
                            () {
                              Navigator.pushNamed(context, '/SendScreen',
                                  arguments: walletViewModel.totalAssets);
                            },
                          ),
                          _buildMenuButton(
                            Icons.download,
                            AppLocalizations.of(context)!.receive,
                            () {
                              Navigator.pushNamed(
                                  context, '/TokenReceiveScreen',
                                  arguments: walletViewModel.totalAssets);
                            },
                          ),
                          _buildMenuButton(
                            Icons.swap_horiz,
                            AppLocalizations.of(context)!.swap,
                            () {
                              Navigator.pushNamed(context, '/SwapScreen',
                                  arguments: walletViewModel.totalAssets);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Token network list（与 ReceiveScreen 共用组件）
                    // 组件会自动撑开，由外层 SingleChildScrollView 统一滚动
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TokenNetworkList(
                        totalAssets: walletViewModel.totalAssets,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Icon(icon, size: 28, color: Colors.blue.shade700),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Color _getCryptoColor(String id) {
    switch (id) {
      case 'bitcoin':
        return Colors.orange;
      case 'ethereum':
        return Colors.blue;
      case 'binancecoin':
        return Colors.yellow.shade700;
      case 'matic-network':
        return Colors.purple;
      case 'base':
        return Colors.blue.shade300;
      case 'tron':
        return Colors.red;
      case 'solana':
        return Colors.purple.shade300;
      case 'hong-kong-dollar':
        return Colors.green;
      case 'usdt-bep20':
      case 'usdt-trc20':
      case 'usdt-erc20':
        return Colors.green.shade400;
      case 'usdc-bep20':
      case 'usdc-polygon':
      case 'usdc-erc20':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }
}
