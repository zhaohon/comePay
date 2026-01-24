import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'dart:async';

class SwapDetailPage extends StatefulWidget {
  const SwapDetailPage({super.key});

  @override
  State<SwapDetailPage> createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  String topCoin = ""; // 默认空，加载后设置为第一条
  String bottomCoin = "HKD"; // 默认HKD
  bool isLoading = true; // 加载状态

  late TextEditingController _amountController;
  late TextEditingController _bottomAmountController;

  Timer? _debounce;
  final Duration _inputDebounce = const Duration(milliseconds: 500);

  // 卡片相关
  final CardService _cardService = CardService();
  CardListResponseModel? _cardList;
  CardListItemModel? _selectedCard;
  CardAccountDetailsModel? _selectedCardDetails;

  // 币种列表（钱包币种）
  List<WalletBalance> _walletCoins = [];
  Map<String, double> _coinBalances = {}; // currency -> balance

  // 默认数组（不变）
  final List<String> _defaultReceiveCoins = ['HKD']; // 默认接收：HKD
  List<String> _defaultSendCoins = []; // 默认发送：wallet列表

  // 展示数组（交换时变化）
  List<String> _displaySendCoins = []; // 发送展示
  List<String> _displayReceiveCoins = ['HKD']; // 接收展示

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _bottomAmountController = TextEditingController();

    // 初始加载：先加载钱包和卡片，再获取汇率
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化数据：顺序加载，避免空币种错误
  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
      });

      print('🔄 [SwapDetailPage] 开始初始化数据...');

      // 先加载卡片列表和钱包数据
      await Future.wait([
        _loadCardList(),
        _loadWalletData(),
      ]);

      print('✅ [SwapDetailPage] 钱包数据加载完成，topCoin: $topCoin');

      // 钱包数据加载完成后，如果有币种才获取汇率
      if (topCoin.isNotEmpty && bottomCoin.isNotEmpty) {
        _fetchRate();
      } else {
        print('⚠️ [SwapDetailPage] 币种为空，跳过汇率获取');
      }
    } catch (e) {
      print('❌ [SwapDetailPage] 初始化数据失败: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('✅ [SwapDetailPage] 初始化完成');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bottomAmountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// 加载钱包数据
  Future<void> _loadWalletData() async {
    try {
      print('🔄 [SwapDetailPage] 开始加载钱包数据...');
      final walletViewModel =
          Provider.of<WalletViewModel>(context, listen: false);
      await walletViewModel.fetchWalletData();

      setState(() {
        _walletCoins = walletViewModel.balances;
        _coinBalances = walletViewModel.balancesByCurrency;

        // 设置默认发送数组（wallet列表）
        _defaultSendCoins = _walletCoins
            .map((balance) => balance.currency)
            .where((currency) => currency.isNotEmpty)
            .toList();

        // 初始化展示数组
        _displaySendCoins = List.from(_defaultSendCoins);
        _displayReceiveCoins = List.from(_defaultReceiveCoins);

        // 如果topCoin为空且有钱包币种，设置为第一条
        if (topCoin.isEmpty && _defaultSendCoins.isNotEmpty) {
          topCoin = _defaultSendCoins.first;
          print('✅ [SwapDetailPage] 设置默认币种: $topCoin');
        }
      });

      print('✅ [SwapDetailPage] 钱包数据加载成功，币种数量: ${_defaultSendCoins.length}');
    } catch (e) {
      print('❌ [SwapDetailPage] 加载钱包数据失败: $e');
      rethrow;
    }
  }

  /// 提取币种主名称（处理USDT-TRC20这种格式）
  String _extractMainCurrency(String currency) {
    print('🔄 [SwapDetailPage] 原始币种: "$currency"');

    // 如果为空，返回空字符串
    if (currency.isEmpty) {
      print('⚠️ [SwapDetailPage] 币种为空，返回空字符串');
      return '';
    }

    // 转换为大写进行判断
    final upperCurrency = currency.toUpperCase();

    // 如果包含USDT，返回USDT
    if (upperCurrency.contains('USDT')) {
      print('✅ [SwapDetailPage] 检测到USDT，转换: "$currency" -> "USDT"');
      return 'USDT';
    }

    // 如果包含"-"，取"-"前面的部分
    if (currency.contains('-')) {
      final mainCurrency = currency.split('-')[0];
      print('✅ [SwapDetailPage] 提取主币种: "$currency" -> "$mainCurrency"');
      return mainCurrency;
    }

    print('✅ [SwapDetailPage] 保持原样: "$currency"');
    return currency;
  }

  /// 获取可用的币种列表
  /// 使用展示数组
  List<String> get _availableCoinsForSend {
    return _displaySendCoins;
  }

  List<String> get _availableCoinsForReceive {
    return _displayReceiveCoins;
  }

  /// 获取币种余额
  double _getCoinBalance(String currency) {
    if (currency == 'HKD' && _selectedCardDetails != null) {
      return _selectedCardDetails!.balance;
    }
    return _coinBalances[currency] ?? 0.0;
  }

  /// 获取币种信息（用于显示logo等）
  WalletBalance? _getCoinInfo(String currency) {
    if (currency == 'HKD') return null; // HKD是固定的，不在钱包列表中
    for (var balance in _walletCoins) {
      if (balance.currency == currency) {
        return balance;
      }
    }
    return null;
  }

  /// 加载卡片列表
  Future<void> _loadCardList() async {
    try {
      final cardList = await _cardService.getCardList();
      setState(() {
        _cardList = cardList;
        // 如果有卡片且未选择，默认选择第一张
        if (_selectedCard == null && cardList.hasCards) {
          _selectedCard = cardList.cards.first;
          _loadCardDetails(cardList.cards.first.publicToken);
        }
      });
    } catch (e) {
      print('Error loading card list: $e');
    }
  }

  /// 加载卡片详情（余额）
  Future<void> _loadCardDetails(String publicToken) async {
    try {
      final details = await _cardService.getCardAccountDetails(publicToken);
      setState(() {
        _selectedCardDetails = details;
      });
    } catch (e) {
      print('Error loading card details: $e');
    }
  }

  /// 判断是否需要选择卡片（涉及HKD时）
  bool _needsCardSelection() {
    return topCoin == 'HKD' || bottomCoin == 'HKD';
  }

  /// 显示卡片选择底部弹窗
  Future<void> _showCardSelectionSheet() async {
    if (_cardList == null || !_cardList!.hasCards) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用卡片，请先申请卡片')),
      );
      return;
    }

    final selected = await showModalBottomSheet<CardListItemModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectCard,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 卡片列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cardList!.cards.length,
                  itemBuilder: (context, index) {
                    final card = _cardList!.cards[index];
                    final isSelected = _selectedCard?.id == card.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          card.cardNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${card.currency} • ${card.cardScheme.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context, card);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCard = selected;
      });
      _loadCardDetails(selected.publicToken);
    }
  }

  void _fetchRate() {
    final viewModel = Provider.of<SwapViewModel>(context, listen: false);

    print('💱 [SwapDetailPage] 开始获取汇率');
    print('   原始发送币种: "$topCoin"');
    print('   原始接收币种: "$bottomCoin"');

    // 提取主币种名称（处理USDT-TRC20这种格式）
    final fromCurrency = _extractMainCurrency(topCoin);
    final toCurrency = _extractMainCurrency(bottomCoin);

    print('   转换后发送币种: "$fromCurrency"');
    print('   转换后接收币种: "$toCurrency"');
    print(
        '   完整URL: http://149.88.65.193:8010/api/v1/wallet/exchange-rate?from=$fromCurrency&to=$toCurrency');

    viewModel.fetchExchangeRate(fromCurrency, toCurrency).then((_) {
      print('✅ [SwapDetailPage] 汇率获取成功: ${viewModel.exchangeRate}');
      _calculateBottomAmount();
    }).catchError((e) {
      print('❌ [SwapDetailPage] 汇率获取失败: $e');
    });
  }

  Future<void> _openDropdown(bool isTop) async {
    // 发送币种：钱包币种；接收币种：钱包币种 + HKD
    final List<String> coinList =
        isTop ? _availableCoinsForSend : _availableCoinsForReceive;
    final String current = isTop ? topCoin : bottomCoin;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.selectCurrency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...coinList.map((coin) {
                return ListTile(
                  leading: _getCoinIcon(coin),
                  title: Text(
                    coin,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  selected: coin == current,
                  selectedTileColor: AppColors.primaryLight,
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
        // 如果切换后涉及HKD，需要重新选择卡片
        if (_needsCardSelection() &&
            _selectedCard == null &&
            _cardList?.hasCards == true) {
          _selectedCard = _cardList!.cards.first;
          _loadCardDetails(_cardList!.cards.first.publicToken);
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
    // 使用正确的汇率计算：1 topCoin = rate bottomCoin
    double result = amount * viewModel.exchangeRate;

    if (mounted) {
      setState(() {
        // 根据目标币种的小数位数格式化
        if (bottomCoin == 'BTC') {
          _bottomAmountController.text = result.toStringAsFixed(8);
        } else {
          _bottomAmountController.text = result.toStringAsFixed(2);
        }
      });
    }
  }

  void _swapCoins() {
    setState(() {
      // 交换topCoin和bottomCoin
      final temp = topCoin;
      topCoin = bottomCoin;
      bottomCoin = temp;

      // 交换展示数组
      final tempDisplay = _displaySendCoins;
      _displaySendCoins = List.from(_displayReceiveCoins);
      _displayReceiveCoins = List.from(tempDisplay);
    });
    _fetchRate();
  }

  /// 处理兑换按钮点击：先预览，再显示弹窗
  Future<void> _handleSwapButtonClick() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterValidAmount),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 如果涉及HKD，检查是否选择了卡片
    if (_needsCardSelection()) {
      if (_selectedCard == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSelectCard),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // 检查余额是否足够
    final availableBalance = _getCoinBalance(topCoin);
    if (availableBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$topCoin 余额不足'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    print('💰 [SwapDetailPage] 开始创建预览...');
    final swapViewModel = Provider.of<SwapViewModel>(context, listen: false);

    // 创建预览（使用完整的币种名称，如USDT-TRC20）
    final success = await swapViewModel.createPreview(
      fromCurrency: topCoin,
      toCurrency: bottomCoin,
      amount: amount,
    );

    if (success) {
      print('✅ [SwapDetailPage] 预览创建成功，显示预览弹窗');
      _showPreviewBottomSheet();
    } else {
      print('❌ [SwapDetailPage] 预览创建失败: ${swapViewModel.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(swapViewModel.errorMessage ?? '获取预览失败'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 显示预览弹窗
  Future<void> _showPreviewBottomSheet() async {
    final swapViewModel = Provider.of<SwapViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.swapPreview,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 兑换金额展示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.swapAmount,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${swapViewModel.fromAmount.toStringAsFixed(2)} ${swapViewModel.fromCurrency}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.arrow_downward, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.netReceived,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${swapViewModel.netAmount.toStringAsFixed(2)} ${swapViewModel.toCurrency}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 汇率信息
              _buildPreviewRow(AppLocalizations.of(context)!.exchangeRate,
                  '1 $topCoin = ${swapViewModel.exchangeRate.toStringAsFixed(4)} $bottomCoin'),

              const Divider(height: 24),

              // 手续费信息
              _buildPreviewRow(AppLocalizations.of(context)!.feeRate,
                  '${(swapViewModel.feeRate * 100).toStringAsFixed(2)}%'),
              _buildPreviewRow(AppLocalizations.of(context)!.feeAmount,
                  '${swapViewModel.feeAmount.toStringAsFixed(2)} HKD'),

              const SizedBox(height: 24),

              // 按钮组
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancelButton,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _executeSwap();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.confirmSwap,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// 构建预览弹窗中的一行信息
  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 执行兑换
  Future<void> _executeSwap() async {
    final swapViewModel = Provider.of<SwapViewModel>(context, listen: false);

    print('💱 [SwapDetailPage] 开始执行兑换...');
    print('   使用quote_id: ${swapViewModel.quoteId}');

    // 执行兑换（使用完整的币种名称，如USDT-TRC20）
    final result = await swapViewModel.executeSwap(
      fromCurrency: topCoin,
      toCurrency: bottomCoin,
      amount: swapViewModel.fromAmount,
      quoteId: swapViewModel.quoteId,
      cardId: _needsCardSelection() ? _selectedCard!.id : null,
    );

    if (!mounted) return;

    if (result != null) {
      // 成功，刷新余额
      _loadWalletData();
      if (_selectedCard != null) {
        _loadCardDetails(_selectedCard!.publicToken);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.swapSuccess),
          backgroundColor: AppColors.success,
        ),
      );

      // 清空输入
      _amountController.clear();
      _bottomAmountController.clear();
      swapViewModel.clearQuote();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('兑换失败: ${swapViewModel.errorMessage}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // 获取币种图标
  Widget _getCoinIcon(String coin) {
    // HKD使用本地图片
    if (coin == 'HKD') {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.cardBackground,
        child: Image.asset(
          'assets/hkd.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.currency_exchange,
              color: AppColors.primary,
            );
          },
        ),
      );
    }

    // 从钱包数据中获取logo
    final coinInfo = _getCoinInfo(coin);
    if (coinInfo != null && coinInfo.logo.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.cardBackground,
        backgroundImage: NetworkImage(coinInfo.logo),
        onBackgroundImageError: (_, __) {},
        child: coinInfo.logo.isEmpty
            ? Icon(
                Icons.currency_exchange,
                color: AppColors.primary,
              )
            : null,
      );
    }

    // 默认图标
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryLight,
      child: Icon(
        Icons.currency_exchange,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SwapViewModel, WalletViewModel>(
      builder: (context, swapViewModel, walletViewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.pageBackground,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Swap",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.pushNamed(context, '/SwapHistory');
                },
              ),
            ],
          ),
          body: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.loading,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Top Row - 发送（按照图一：币种选择在上，输入框在下）
                        _buildSwapRow(
                          amountController: _amountController,
                          symbol: topCoin,
                          isTop: true,
                          onChanged: _onAmountChanged,
                          availableBalance:
                              _getCoinBalance(topCoin).toStringAsFixed(8),
                        ),

                        const SizedBox(height: 12),

                        // Swap Arrow
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.primary,
                                thickness: 1,
                                endIndent: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: _swapCoins,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.swap_vert,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.primary,
                                thickness: 1,
                                indent: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Bottom Row - 接收（按照图一：币种选择在上，输入框在下）
                        _buildSwapRow(
                          amountController: _bottomAmountController,
                          symbol: bottomCoin,
                          isTop: false,
                          readOnly: true,
                          availableBalance:
                              _getCoinBalance(bottomCoin).toStringAsFixed(2),
                        ),

                        const SizedBox(height: 20),

                        // 卡片选择（当涉及HKD时显示）
                        if (_needsCardSelection()) ...[
                          // 转账方向标识
                          Row(
                            children: [
                              Icon(
                                bottomCoin == 'HKD'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                size: 16,
                                color: bottomCoin == 'HKD'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                bottomCoin == 'HKD'
                                    ? AppLocalizations.of(context)!
                                        .transferToCard
                                    : AppLocalizations.of(context)!
                                        .transferFromCard,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: bottomCoin == 'HKD'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bottomCoin == 'HKD'
                                    ? AppLocalizations.of(context)!
                                        .rechargeToCard
                                    : AppLocalizations.of(context)!
                                        .withdrawFromCard,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _showCardSelectionSheet,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: _selectedCard != null
                                    ? AppColors.primaryGradient
                                    : null,
                                color: _selectedCard == null
                                    ? AppColors.cardBackground
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedCard != null
                                      ? Colors.transparent
                                      : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _selectedCard != null
                                          ? Colors.white.withOpacity(0.3)
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _selectedCard != null
                                        ? const Center(
                                            child: Text(
                                              'P',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.credit_card,
                                            color: AppColors.textSecondary,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCard != null
                                              ? _selectedCard!.cardNo
                                              : AppLocalizations.of(context)!
                                                  .selectCard,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedCard != null
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        if (_selectedCard != null &&
                                            _selectedCardDetails != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_selectedCardDetails!.currencyCode} • ${_selectedCardDetails!.balance.toStringAsFixed(2)} ${_selectedCardDetails!.currencyCode}',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: _selectedCard != null
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // 汇率显示
                        if (swapViewModel.isLoadingRate)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.gettingRate,
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          )
                        else if (swapViewModel.errorMessage != null)
                          Text(
                            "${AppLocalizations.of(context)!.error}: ${swapViewModel.errorMessage}",
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12),
                          )
                        else if (swapViewModel.exchangeRate > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "1 $topCoin ≈ ${swapViewModel.exchangeRate.toStringAsFixed(4)} $bottomCoin",
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _fetchRate,
                                  child: Icon(
                                    Icons.refresh,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 40),

                        // 兑换按钮（使用渐变样式）
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: swapViewModel.isExecutingSwap
                                ? null
                                : _handleSwapButtonClick,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                : Text(
                                    AppLocalizations.of(context)!.swapAction,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 币种选择行（按照图一，币种在上）
          GestureDetector(
            onTap: () => _openDropdown(isTop),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Row(
                children: [
                  _getCoinIcon(symbol),
                  const SizedBox(width: 8),
                  Text(
                    symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // 标签（发送币种显示"匯出數量"，接收币种显示"獲得"）
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              isTop
                  ? AppLocalizations.of(context)!.swapAmount
                  : AppLocalizations.of(context)!.getAmount,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),

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
                    hintText: readOnly
                        ? "0"
                        : AppLocalizations.of(context)!.enterAmount,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPlaceholder,
                    ),
                    // 将全部按钮放到suffixIcon位置（仅发送时显示）
                    suffixIcon: (isTop && !readOnly)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                final balance = _getCoinBalance(symbol);
                                _amountController.text =
                                    balance.toStringAsFixed(8);
                                _onAmountChanged(_amountController.text);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.all,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  onChanged: onChanged,
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
                '${AppLocalizations.of(context)!.available}: $availableBalance $symbol',
                style: const TextStyle(
                  color: AppColors.primary,
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
