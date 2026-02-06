import 'package:flutter/material.dart';
import 'package:Demo/l10n/app_localizations.dart';
import 'package:Demo/viewmodels/crypto_viewmodel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:provider/provider.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  late double totalAssets;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    totalAssets = args is double ? args : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CryptoViewModel>(
      create: (context) => CryptoViewModel()..fetchCryptoData(),
      child: _SwapScreenContent(totalAssets: totalAssets),
    );
  }
}

class _SwapScreenContent extends StatefulWidget {
  final double totalAssets;
  const _SwapScreenContent({required this.totalAssets});

  @override
  _SwapScreenContentState createState() => _SwapScreenContentState();
}

class _SwapScreenContentState extends State<_SwapScreenContent> {
  late double totalAssets;

  @override
  void initState() {
    super.initState();
    totalAssets = widget.totalAssets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.swapFrom,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: viewModel.fetchCryptoData,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: viewModel.busy
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            itemCount: viewModel.cryptoData.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 1),
                            itemBuilder: (context, index) {
                              final crypto = viewModel.cryptoData[index];
                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/SwapDetailScreen',
                                      arguments: crypto,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 20,
                                          child: Image.network(
                                            crypto.image,
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                crypto.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "\$${crypto.currentPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              NumberFormat.simpleCurrency(
                                                      locale: 'en_US')
                                                  .format(crypto.currentPrice *
                                                      totalAssets),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              NumberFormat.simpleCurrency(
                                                      locale: 'en_US')
                                                  .format(crypto.currentPrice *
                                                      totalAssets),
                                              style: TextStyle(
                                                color:
                                                    crypto.priceChangePercentage24h >=
                                                            0
                                                        ? Colors.green
                                                        : Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
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
          ),
        );
      },
    );
  }
}
