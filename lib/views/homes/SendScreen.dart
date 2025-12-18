import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/crypto_viewmodel.dart';
import 'package:intl/intl.dart' show NumberFormat;

class Sendscreen extends StatefulWidget {
  const Sendscreen({super.key});

  @override
  _SendscreenState createState() => _SendscreenState();
}

class _SendscreenState extends State<Sendscreen> {
  final CryptoViewModel _cryptoViewModel = CryptoViewModel();
  List<Map<String, dynamic>> filteredTokens = [];
  double totalAssets = 0.0;

  final TextEditingController _searchController = TextEditingController();

  final Map<String, IconData> _icons = {
    'BTC': Icons.currency_bitcoin,
    'ETH': Icons.token,
    'USDT': Icons.attach_money,
    'USDC': Icons.account_balance_wallet,
    'BNB': Icons.circle,
    'MATIC': Icons.account_balance,
    'BASE': Icons.foundation,
    'TRX': Icons.flash_on,
    'SOL': Icons.wb_sunny,
  };

  final Map<String, Color> _colors = {
    'BTC': Colors.orange,
    'ETH': Colors.blue,
    'USDT': Colors.green,
    'USDC': Colors.teal,
    'BNB': Colors.yellow,
    'MATIC': Colors.purple,
    'BASE': Colors.grey,
    'TRX': Colors.red,
    'SOL': Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    _cryptoViewModel.fetchCryptoData().then((_) => _updateFilteredTokens());
    _searchController.addListener(_filterTokens);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is double) totalAssets = args;
  }

  void _updateFilteredTokens() {
    setState(() {
      filteredTokens = _cryptoViewModel.cryptoData.map((crypto) => {
        'name': crypto.name,
        'symbol': crypto.symbol.toUpperCase(),
        'image': crypto.image,
        'chain': '',
        'icon': _icons[crypto.symbol.toUpperCase()] ?? Icons.help,
        'color': _colors[crypto.symbol.toUpperCase()] ?? Colors.black,
        'networks': [crypto.symbol.toUpperCase()],
        'balance': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice),
        'usdBalance': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice * totalAssets),
        'usdBalanceFormatted': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice * totalAssets),
      }).toList();
    });
  }

  void _filterTokens() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredTokens = _cryptoViewModel.cryptoData
          .map((crypto) => {
        'name': crypto.name,
        'symbol': crypto.symbol.toUpperCase(),
        'image': crypto.image,
        'chain': '',
        'icon': _icons[crypto.symbol.toUpperCase()] ?? Icons.help,
        'color': _colors[crypto.symbol.toUpperCase()] ?? Colors.black,
        'networks': [crypto.symbol.toUpperCase()],
        'balance': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice),
        'usdBalance': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice * totalAssets),
        'usdBalanceFormatted': NumberFormat.simpleCurrency(locale: 'en_US')
            .format(crypto.currentPrice * totalAssets),
      })
          .where((token) =>
      (token["name"] as String).toLowerCase().contains(query) ||
          (token["symbol"] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  void _showNetworkBottomSheet(Map<String, dynamic> token) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48),
                            Text(
                              AppLocalizations.of(context)!.selectNetwork,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // List Network
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: token["networks"].length,
                        itemBuilder: (context, index) {
                          String network = token["networks"][index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: Image.network(
                                token["image"],
                                width: 35,
                                height: 35,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                              ),
                            ),
                            title: Text(token["symbol"]),
                            subtitle: Text(network),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  token["usdBalanceFormatted"] ??
                                      AppLocalizations.of(context)!
                                          .balancePlaceholder,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  token["usdBalanceFormatted"] ??
                                      AppLocalizations.of(context)!
                                          .usdBalancePlaceholder,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/SendPdp', arguments: {
                                'token': token,
                                'network': network,
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

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
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchTokenHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Token List
            _cryptoViewModel.busy
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredTokens.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final token = filteredTokens[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showNetworkBottomSheet(token),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: Image.network(
                                token["image"],
                                width: 35,
                                height: 35,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    token["symbol"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    token["balance"] ??
                                        AppLocalizations.of(context)!
                                            .balancePlaceholder,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  token["usdBalanceFormatted"] ??
                                      AppLocalizations.of(context)!
                                          .balancePlaceholder,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  token["usdBalanceFormatted"] ??
                                      AppLocalizations.of(context)!
                                          .usdBalancePlaceholder,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
