import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';
import 'dart:async';

class SwapDetailPage extends StatefulWidget {
  const SwapDetailPage({super.key});

  @override
  State<SwapDetailPage> createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  // 限制列表
  final List<String> sendCoinList = ["USDT", "BTC", "ETH", "USDC"];
  final List<String> receiveCoinList = ["HKD"];

  String topCoin = "USDT"; // 默认
  String bottomCoin = "HKD"; // 默认

  late TextEditingController _amountController;
  late TextEditingController _bottomAmountController;

  Timer? _debounce;
  final Duration _inputDebounce = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _bottomAmountController = TextEditingController();

    // 初始获取汇率
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRate();
      // 获取钱包数据以显示余额
      Provider.of<WalletViewModel>(context, listen: false).fetchWalletData();
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
      _calculateBottomAmount();
    });
  }

  Future<void> _openDropdown(bool isTop) async {
    final List<String> coinList = isTop ? sendCoinList : receiveCoinList;
    final String current = isTop ? topCoin : bottomCoin;

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择币种',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...coinList.map((coin) {
                return ListTile(
                  leading: _getCoinIcon(coin),
                  title: Text(coin),
                  selected: coin == current,
                  selectedTileColor: Colors.blue.shade50,
                  onTap: () => Navigator.pop(context, coin),
                );
              }).toList(),
            ],
          ),
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

    if (mounted) {
      setState(() {
        _bottomAmountController.text = result.toStringAsFixed(2);
      });
    }
  }

  void _swapCoins() {
    setState(() {
      final temp = topCoin;
      topCoin = bottomCoin;
      bottomCoin = temp;
    });
    _fetchRate();
  }

  // 直接执行兑换（移除Review弹窗）
  Future<void> _executeDirectSwap() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    final walletViewModel =
        Provider.of<WalletViewModel>(context, listen: false);
    final swapViewModel = Provider.of<SwapViewModel>(context, listen: false);

    // 检查余额是否足够
    final availableBalance = _getAvailableBalance(walletViewModel, topCoin);
    final balance = double.tryParse(availableBalance) ?? 0.0;
    if (balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$topCoin 余额不足')),
      );
      return;
    }

    // 直接执行兑换
    final result = await swapViewModel.executeSwap(
      fromCurrency: topCoin,
      toCurrency: bottomCoin,
      amount: amount,
    );

    if (!mounted) return;

    if (result != null) {
      // 成功，刷新钱包余额
      walletViewModel.fetchWalletData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('兑换成功！'), backgroundColor: Colors.green),
      );

      // 清空输入
      _amountController.clear();
      _bottomAmountController.clear();
      swapViewModel.clearQuote();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('兑换失败: ${swapViewModel.errorMessage}')),
      );
    }
  }

  // 获取币种图标
  Widget _getCoinIcon(String coin) {
    String assetPath = '';
    switch (coin.toUpperCase()) {
      case 'ETH':
        assetPath = 'assets/eth.png';
        break;
      case 'BTC':
        assetPath = 'assets/btc.png';
        break;
      case 'USDT':
        assetPath = 'assets/usdt.png';
        break;
      case 'USDC':
        assetPath = 'assets/usdc.png';
        break;
      case 'HKD':
        assetPath = 'assets/hkd.png';
        break;
      default:
        return const CircleAvatar(
          radius: 20,
          child: Icon(Icons.currency_exchange),
        );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: Image.asset(
        assetPath,
        width: 32,
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.currency_exchange);
        },
      ),
    );
  }

  // 获取可用余额
  String _getAvailableBalance(
      WalletViewModel walletViewModel, String currency) {
    // AvailableCurrency模型包含chain、native、token字段
    // token是一个Map<String, dynamic>，包含各种代币的余额
    final availableCurrencies = walletViewModel.availableCurrenciesList;

    if (availableCurrencies.isEmpty) return '0.00';

    // 尝试从AvailableCurrency的token map中获取余额
    for (var curr in availableCurrencies) {
      // 检查token map中是否有对应币种
      if (curr.token.containsKey(currency)) {
        final balance = curr.token[currency];
        if (balance is num) {
          return balance.toStringAsFixed(2);
        } else if (balance is String) {
          return (double.tryParse(balance) ?? 0.0).toStringAsFixed(2);
        }
      }

      // 如果是原生代币（如ETH、BTC），检查native字段
      if (currency.toUpperCase() == curr.chain.toUpperCase()) {
        final balance = double.tryParse(curr.native) ?? 0.0;
        return balance.toStringAsFixed(2);
      }
    }

    return '0.00';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SwapViewModel, WalletViewModel>(
      builder: (context, swapViewModel, walletViewModel, child) {
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
            actions: [
              // 历史记录图标
              IconButton(
                icon: const Icon(Icons.history, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(context, '/SwapHistory');
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Row - 发送
                _buildSwapRow(
                  amountController: _amountController,
                  symbol: topCoin,
                  isTop: true,
                  onChanged: _onAmountChanged,
                  availableBalance:
                      _getAvailableBalance(walletViewModel, topCoin),
                ),

                const SizedBox(height: 12),

                // Swap Arrow
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.blueAccent,
                        thickness: 1,
                        endIndent: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: _swapCoins,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: const Icon(
                          Icons.swap_vert,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.blueAccent,
                        thickness: 1,
                        indent: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row - 接收
                _buildSwapRow(
                  amountController: _bottomAmountController,
                  symbol: bottomCoin,
                  isTop: false,
                  readOnly: true,
                  availableBalance:
                      _getAvailableBalance(walletViewModel, bottomCoin),
                ),

                const SizedBox(height: 20),

                // 汇率显示
                if (swapViewModel.isLoadingRate)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text("获取汇率中...", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                else if (swapViewModel.errorMessage != null)
                  Text(
                    "错误: ${swapViewModel.errorMessage}",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  )
                else if (swapViewModel.exchangeRate > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "1 $topCoin ≈ ${swapViewModel.exchangeRate.toStringAsFixed(6)} $bottomCoin",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _fetchRate,
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // 兑换按钮（直接兑换，无需Review）
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: swapViewModel.isExecutingSwap
                        ? null
                        : _executeDirectSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: swapViewModel.isExecutingSwap
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "兑换",
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
    required String availableBalance,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 金额输入行
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  readOnly: readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "0",
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _openDropdown(isTop),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getCoinIcon(symbol),
                      const SizedBox(width: 8),
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 可用余额 - 只在发送时显示
          if (isTop)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$availableBalance $symbol available',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
