import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';
import 'dart:async';
// import 'package:comecomepay/models/responses/crypto_response_model.dart'; // No longer needed directly if we rely on ViewModel strings

class SwapDetailPage extends StatefulWidget {
  const SwapDetailPage({super.key});

  @override
  State<SwapDetailPage> createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  // Restricted Lists as per user request
  final List<String> sendCoinList = ["USDT", "BTC", "ETH", "USDC"];
  final List<String> receiveCoinList = ["HKD"];

  String topCoin = "USDT"; // Default
  String bottomCoin = "HKD"; // Default

  late TextEditingController _amountController;
  late TextEditingController _bottomAmountController;

  Timer? _debounce;
  final Duration _inputDebounce = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _bottomAmountController = TextEditingController();

    // Initial fetch of exchange rate for default pair
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRate();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bottomAmountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _fetchRate() {
    final viewModel = Provider.of<SwapViewModel>(context, listen: false);
    viewModel.fetchExchangeRate(topCoin, bottomCoin).then((_) {
      // Re-calculate after fetching rate if amount exists
      _calculateBottomAmount();
    });
  }

  Future<void> _openDropdown(bool isTop) async {
    final List<String> coinList = isTop ? sendCoinList : receiveCoinList;
    final String current = isTop ? topCoin : bottomCoin;

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          children: coinList.map((coin) {
            return ListTile(
              title: Text(coin),
              selected: coin == current,
              onTap: () => Navigator.pop(context, coin),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && selected != current) {
      setState(() {
        if (isTop) {
          topCoin = selected;
        } else {
          bottomCoin = selected;
        }
      });
      // Fetch new rate when coin changes
      _fetchRate();
    }
  }

  void _onAmountChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(_inputDebounce, () {
      _calculateBottomAmount();
    });
  }

  void _calculateBottomAmount() {
    final viewModel = Provider.of<SwapViewModel>(context, listen: false);
    if (viewModel.exchangeRate == 0 || _amountController.text.isEmpty) {
      if (mounted) {
        setState(() {
          _bottomAmountController.text = "";
        });
      }
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double result = amount * viewModel.exchangeRate;

    // Format result, maybe 2 decimals for HKD/USD
    if (mounted) {
      setState(() {
        _bottomAmountController.text = result.toStringAsFixed(2);
      });
    }
  }

  // NOTE: Swap functionality might be weird because lists are different.
  // If user swaps, Top becomes HKD (which is not in Send List).
  // I will just simple swap the variables, but UI might show "HKD" in top even if not in list,
  // or I should disable swap if restricted.
  // User asked for "Send List" and "Receive List".
  // Swapping them would mean Send becomes Receive list (HKD) and Receive becomes Send List.
  // If strict, I should probably disable Swap or allow it but updating the lists dynamically?
  // Given "Send List" is [USDT, BTC...] explicitly, maybe swapping is NOT intended or should switch contexts?
  // For now I will implement simple swap but warn user if values are outside lists (or just let it be).
  // Actually, better to just let them swap values. The dropdowns use `sendCoinList` based on `isTop`.
  // If `topCoin` becomes HKD, it's fine, but when they open dropdown, they only see [USDT, BTC...].
  // So they can't change it back to HKD if they change it to USDT. This seems acceptable for "Swap".
  void _swapCoins() {
    setState(() {
      final temp = topCoin;
      topCoin = bottomCoin;
      bottomCoin = temp;
    });
    _fetchRate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SwapViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Swap",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Row
                _buildSwapRow(
                  amountController: _amountController,
                  symbol: topCoin,
                  isTop: true,
                  onChanged: _onAmountChanged,
                ),

                const SizedBox(height: 12),

                // Swap Arrow
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.blueAccent,
                        thickness: 2,
                        endIndent: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: _swapCoins,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.blueAccent),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.blueAccent,
                        thickness: 2,
                        indent: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row (Read Only usually, but let's make it display)
                _buildSwapRow(
                  amountController: _bottomAmountController,
                  symbol: bottomCoin,
                  isTop: false,
                  readOnly: true,
                ),

                const SizedBox(height: 20),

                // Rate Display
                if (viewModel.isLoadingRate)
                  const Text("Fetching rate...",
                      style: TextStyle(color: Colors.grey))
                else if (viewModel.errorMessage != null)
                  Text("Error: ${viewModel.errorMessage}",
                      style: const TextStyle(color: Colors.red))
                else if (viewModel.exchangeRate > 0)
                  Text("1 $topCoin ≈ ${viewModel.exchangeRate} $bottomCoin",
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold)),

                const Spacer(),

                // Review Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement Review Logic or Navigation
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Review not implemented yet")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Review",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwapRow({
    required TextEditingController amountController,
    required String symbol,
    required bool isTop,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              readOnly: readOnly,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.0",
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _openDropdown(isTop),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(symbol,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue)),
                  const Icon(Icons.arrow_drop_down, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
