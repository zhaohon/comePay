import 'package:comecomepay/models/carddetail_response_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart'
    show HiveStorageService;
import 'package:comecomepay/views/homes/AuthorizationRecordScreen.dart'
    show AuthorizationRecordScreen;
import 'package:comecomepay/views/homes/CardApplyConfirmScreen.dart'
    show CardApplyConfirmScreen;
import 'package:comecomepay/views/homes/CardTransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/viewmodels/card_trade_viewmodel.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Add TextEditingController for verification code
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String? email;
  String? userId;

  late ProfileScreenViewModel _viewModel;
  late CardTradeViewModel _cardTradeViewModel;
  final CardService _cardService = CardService();

  // 卡片列表相关状态
  CardListResponseModel? _cardList;
  bool _isLoadingCards = false;
  String? _cardError;

  // 当前选中的卡片索引
  int _currentCardIndex = 0;
  final PageController _pageController = PageController();

  // 当前卡片详情
  CardAccountDetailsModel? _currentCardDetails;
  bool _isLoadingCardDetails = false;

  // 交易记录相关
  List<Map<String, dynamic>> _transactions = [];
  int _transactionPage = 1;
  bool _isLoadingTransactions = false;
  bool _hasMoreTransactions = true;

  // UI状态
  bool _isInitialLoading = true;
  bool _isCardNumberVisible = false;
  bool _isCardLocked = false;
  bool _isBalanceVisible = true; // 余额是否可见
  Map<String, String> _cvvCache = {}; // 临时存储CVV，不持久化
  Map<String, String> _pinCache = {}; // 临时存储PIN，不持久化

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileScreenViewModel();
    _cardTradeViewModel = CardTradeViewModel();

    // 优先使用缓存的卡片列表
    final cachedList = CardViewModel.cachedCardList;
    if (cachedList != null) {
      setState(() {
        _cardList = cachedList;
        _isInitialLoading = false;
      });
      // 如果有卡片，加载第一张卡片的详情和交易记录
      if (cachedList.hasCards) {
        _currentCardIndex = 0;
        _loadCurrentCardDetails();
        _loadTransactions();
      }
    } else {
      // 如果没有缓存，加载卡片列表
      _loadCardList();
    }

    _setupScrollListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新显示时，检查是否需要刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRefreshCardList();
    });
  }

  /// 检查并刷新卡片列表（如果缓存已更新）
  void _checkAndRefreshCardList() {
    final cachedList = CardViewModel.cachedCardList;
    if (cachedList != null && _cardList != null) {
      // 如果缓存中的卡片数量与当前不同，刷新列表
      if (cachedList.total != _cardList!.total) {
        setState(() {
          _cardList = cachedList;
        });
        if (cachedList.hasCards) {
          _currentCardIndex = 0;
          _loadCurrentCardDetails();
          _loadTransactions();
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreTrades();
      }
    });
  }

  Future<void> _loadMoreTrades() async {
    if (_cardList != null &&
        _cardList!.hasCards &&
        _currentCardIndex < _cardList!.cards.length) {
      final currentCard = _cardList!.cards[_currentCardIndex];
      if (_hasMoreTransactions && !_isLoadingTransactions) {
        await _loadTransactions(isLoadMore: true);
      }
    }
  }

  /// 加载卡片列表
  Future<void> _loadCardList() async {
    setState(() {
      _isLoadingCards = true;
      _cardError = null;
      _isInitialLoading = true;
    });

    try {
      final cardList = await _cardService.getCardList();

      setState(() {
        _cardList = cardList;
        _isLoadingCards = false;
        _isInitialLoading = false;
      });

      // 如果有卡片，加载第一张卡片的详情和交易记录
      if (cardList.hasCards) {
        _currentCardIndex = 0;
        await _loadCurrentCardDetails();
        await _loadTransactions();
      }
      // 如果没有卡片，_cardList已经设置为空列表，build方法会显示申请页面
    } catch (e) {
      // 如果还有异常（理论上不应该发生，因为CardService已经处理了），创建一个空的卡片列表
      setState(() {
        _cardError = e.toString();
        _isLoadingCards = false;
        _isInitialLoading = false;
        _cardList = CardListResponseModel(total: 0, cards: []);
      });
      print('Error loading card list: $e');
    }
  }

  /// 加载当前选中卡片的详情
  Future<void> _loadCurrentCardDetails() async {
    if (_cardList == null || !_cardList!.hasCards) return;
    if (_currentCardIndex >= _cardList!.cards.length) return;

    final currentCard = _cardList!.cards[_currentCardIndex];

    setState(() {
      _isLoadingCardDetails = true;
    });

    try {
      final details =
          await _cardService.getCardAccountDetails(currentCard.publicToken);

      setState(() {
        _currentCardDetails = details;
        _isLoadingCardDetails = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCardDetails = false;
      });
      print('Error loading card details: $e');
    }
  }

  /// 加载交易记录
  Future<void> _loadTransactions({bool isLoadMore = false}) async {
    if (_cardList == null || !_cardList!.hasCards) return;
    if (_currentCardIndex >= _cardList!.cards.length) return;

    final currentCard = _cardList!.cards[_currentCardIndex];

    if (!isLoadMore) {
      setState(() {
        _transactions = [];
        _transactionPage = 1;
        _hasMoreTransactions = true;
      });
    }

    if (!_hasMoreTransactions) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final result = await _cardService.getTransactionHistory(
        publicToken: currentCard.publicToken,
        page: _transactionPage,
        limit: 20,
      );

      final transactions = result['transactions'] as List<dynamic>? ?? [];
      final total = result['total'] as int? ?? 0;

      setState(() {
        if (isLoadMore) {
          _transactions.addAll(
            transactions.map((t) => t as Map<String, dynamic>).toList(),
          );
        } else {
          _transactions =
              transactions.map((t) => t as Map<String, dynamic>).toList();
        }
        _transactionPage++;
        _hasMoreTransactions = _transactions.length < total;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTransactions = false;
      });
      print('Error loading transactions: $e');
    }
  }

  /// 切换卡片
  void _onCardChanged(int index) {
    if (index == _currentCardIndex) return;

    setState(() {
      _currentCardIndex = index;
      _isCardNumberVisible = false; // 切换卡片时隐藏卡号
    });

    // 加载新卡片的详情和交易记录
    _loadCurrentCardDetails();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // 初始加载中
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 如果有卡片，显示卡片详情页面
    if (_cardList != null && _cardList!.hasCards) {
      return _buildCardDetailScreen();
    }

    // 如果没有卡片（包括_cardList为null、total=0、或接口报错），都显示申请页面
    return _buildApplyScreen();
  }

  /// 构建卡片详情页面（支持多卡片切换）
  Widget _buildCardDetailScreen() {
    final currentCard = _cardList!.cards[_currentCardIndex];
    final cardCount = _cardList!.cards.length;
    final hasLeftCard = _currentCardIndex > 0;
    final hasRightCard = _currentCardIndex < cardCount - 1;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      // appBar: AppBar(
      //   backgroundColor: AppColors.pageBackground,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCardList();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== 余额和加号（一行，最右边） =====
              SizedBox(
                height: 24,
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _isBalanceVisible &&
                                          _currentCardDetails != null
                                      ? _currentCardDetails!.balance
                                          .toStringAsFixed(2)
                                      : _isBalanceVisible
                                          ? '0.00'
                                          : '****',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentCardDetails?.currencyCode ??
                                      currentCard.currency,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isBalanceVisible = !_isBalanceVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isBalanceVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '可用額度估值',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    _showBalanceTip();
                                  },
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 加号按钮
                      if (cardCount < 50)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CardApplyConfirmScreen(
                                  skipKycCheck: true,
                                ),
                              ),
                            ).then((_) {
                              _loadCardList();
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ===== 卡片展示区域（全宽，带边缘渐变效果） =====
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // 卡片轮播
                    PageView.builder(
                      controller: _pageController,
                      itemCount: cardCount,
                      onPageChanged: _onCardChanged,
                      itemBuilder: (context, index) {
                        final card = _cardList!.cards[index];
                        return _buildCardWidget(card);
                      },
                    ),
                    // 左侧渐变遮罩（表示有前一张卡片）
                    if (hasLeftCard)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.pageBackground,
                                AppColors.pageBackground.withOpacity(0),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    // 右侧渐变遮罩（表示有后一张卡片）
                    if (hasRightCard)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                AppColors.pageBackground,
                                AppColors.pageBackground.withOpacity(0),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              bottomLeft: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ===== 操作按钮区域（3列布局） =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero, // 移除默认padding
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionCard(Icons.info_outline, '卡信息'),
                    _buildActionCard(Icons.lock_outline, '鎖卡'),
                    _buildActionCard(Icons.touch_app_outlined, '卡片授權'),
                    _buildActionCard(Icons.credit_card_outlined, '申領實體卡'),
                    _buildActionCard(Icons.link_off_outlined, '掛失'),
                  ],
                ),
              ),

              // ===== 交易记录区域（暂时隐藏） =====
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             '賬單',
              //             style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 18,
              //               color: AppColors.textPrimary,
              //             ),
              //           ),
              //           IconButton(
              //             icon: const Icon(Icons.grid_view),
              //             onPressed: () {
              //               // TODO: 查看更多交易或筛选
              //             },
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              // // 交易记录列表（暂时隐藏）
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Column(
              //     children: [
              //       if (_isLoadingTransactions && _transactions.isEmpty)
              //         const Center(
              //           child: Padding(
              //             padding: EdgeInsets.all(16.0),
              //             child: CircularProgressIndicator(),
              //           ),
              //         )
              //       else if (_transactions.isEmpty)
              //         Center(
              //           child: Column(
              //             children: [
              //               Icon(Icons.inbox,
              //                   size: 48, color: AppColors.textSecondary),
              //               const SizedBox(height: 8),
              //               Text(
              //                 '暫無交易記錄',
              //                 style: TextStyle(
              //                   color: AppColors.textSecondary,
              //                   fontSize: 14,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         )
              //       else
              //         ..._transactions
              //             .map((transaction) =>
              //                 _buildTransactionItem(transaction))
              //             .toList(),

              //       // 加载更多指示器
              //       if (_isLoadingTransactions && _transactions.isNotEmpty)
              //         const Center(
              //           child: Padding(
              //             padding: EdgeInsets.all(8.0),
              //             child: CircularProgressIndicator(),
              //           ),
              //         ),

              //       const SizedBox(height: 20),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建单张卡片Widget
  Widget _buildCardWidget(CardListItemModel card) {
    final isCurrentCard =
        card.publicToken == _cardList!.cards[_currentCardIndex].publicToken;
    final cardDetails = isCurrentCard ? _currentCardDetails : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 200,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 卡片右上角：费率信息
          Positioned(
            right: 16,
            top: 16,
            child: Row(
              children: [
                Text(
                  '費率',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.help_outline,
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),

          // 卡片左上角：P logo（文字）
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 卡片中间：卡号（可点击查看）
          Positioned(
            left: 16,
            top: 80,
            child: GestureDetector(
              onTap: isCurrentCard ? () => _showCardSecurityInfo() : null,
              child: Row(
                children: [
                  Text(
                    card.cardNo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (isCurrentCard) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.visibility_off,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 卡片左下角：持卡人姓名
          Positioned(
            left: 16,
            bottom: 50,
            child: Text(
              'CARDHOLDER NAME', // TODO: 从详情中获取
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),

          // 卡片左下角：CVV和到期日（可点击查看）
          Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: isCurrentCard ? () => _showCardSecurityInfo() : null,
                  child: Text(
                    'CVV: ***',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '到期日: ${cardDetails?.expiryDate ?? '***'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 卡片右下角：VISA Platinum
          Positioned(
            right: 16,
            bottom: 16,
            child: Text(
              'VISA Platinum',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建交易记录项
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] ?? 0.0;
    final isPositive = amount > 0;
    final description =
        transaction['description'] ?? transaction['merchant'] ?? '交易';
    final date = transaction['date'] ?? transaction['created_at'] ?? '';
    final status = transaction['status'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPositive ? AppColors.success : AppColors.error,
        ),
        title: Text(description),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
            ),
            if (status.isNotEmpty)
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardTransactionDetailScreen(
                transaction: transaction,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 显示余额提示
  void _showBalanceTip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('可用額度估值'),
        content: const Text(
          '除交易手續費及匯率波動後預估可用金額',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  /// 显示卡片安全信息（底部弹出）
  Future<void> _showCardSecurityInfo() async {
    if (_cardList == null || !_cardList!.hasCards) return;
    final currentCard = _cardList!.cards[_currentCardIndex];

    // 先显示全屏loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 并行获取所有信息
      final results = await Future.wait([
        _cardService.getFullCardNumber(currentCard.publicToken),
        _cardService.getCvv(currentCard.publicToken),
        _cardService.getPin(currentCard.publicToken),
      ]);

      final fullCardNumber =
          (results[0] as Map<String, String>)['card_number'] ?? '';
      final cvv = results[1] as String;
      final pin = results[2] as String;

      // 关闭loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 显示安全信息弹窗
      _showSecurityInfoBottomSheet(fullCardNumber, cvv, pin);
    } catch (e) {
      // 关闭loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取卡片信息失败: $e')),
      );
    }
  }

  /// 显示安全信息底部弹窗
  void _showSecurityInfoBottomSheet(String cardNumber, String cvv, String pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '卡片安全信息',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSecurityInfoItem('卡號', cardNumber),
                    const SizedBox(height: 20),
                    _buildSecurityInfoItem(
                        '到期日', _currentCardDetails?.expiryDate ?? '***'),
                    const SizedBox(height: 20),
                    _buildSecurityInfoItem('CVV碼', cvv),
                    const SizedBox(height: 20),
                    _buildSecurityInfoItem('PIN碼', pin),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // 确认按钮
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '確認',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建安全信息项
  Widget _buildSecurityInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // 复制到剪贴板
                  // TODO: 实现复制功能
                },
                child: Icon(
                  Icons.copy,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建申请页面
  Widget _buildApplyScreen() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final size = MediaQuery.of(context).size;
        final textScale = MediaQuery.of(context).textScaleFactor;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isTablet = constraints.maxWidth >= 600;
                double titleFont = isTablet ? 26 : 20;
                double descFont = isTablet ? 18 : 14;
                double buttonWidthFactor = isTablet ? 0.4 : 0.6;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.comeComePayCard,
                        style: TextStyle(
                          fontSize: titleFont * textScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.05),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/visa.png",
                          height: size.height * (isTablet ? 0.3 : 0.25),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildChip(AppLocalizations.of(context)!.noMonthlyFee,
                              isTablet),
                          _buildChip(
                              AppLocalizations.of(context)!.lowTransactionFee,
                              isTablet),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),
                      Text(
                        AppLocalizations.of(context)!.spendCryptoLikeFiat,
                        style: TextStyle(
                          fontSize: descFont * textScale,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.08),
                      FractionallySizedBox(
                        widthFactor: buttonWidthFactor,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CardApplyConfirmScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ).copyWith(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                (states) => null, // biar gradient tetap jalan
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)!.applyNow,
                                  style: TextStyle(
                                    fontSize: (isTablet ? 18 : 16) * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == '卡信息') {
          _showCardSecurityInfo();
        } else if (label == '鎖卡') {
          // TODO: 实现锁卡功能
        } else if (label == '卡片授權') {
          // TODO: 实现卡片授权功能
        } else if (label == '申領實體卡') {
          // TODO: 实现申领实体卡功能
        } else if (label == '掛失') {
          // TODO: 实现挂失功能
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showSecurityVerificationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Security verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Choose verification method title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose verification method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Email verification field (non-editable)
              TextFormField(
                initialValue: 'email verification',
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              // Verification title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Verification code text field with get code
              TextFormField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter verification code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: TextButton(
                    onPressed: () {
                      // TODO: Implement get code logic
                    },
                    child: const Text(
                      'Get code',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement confirm logic
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showApplyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kindly Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Centered text
              const Center(
                child: Text(
                  'Please confirm that you have received the physical card before activating it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // White button with shadow
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement action for "Card Not Received, Active later"
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Card Not Received, Active later',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Second title
              const Center(
                child: Text(
                  'Card Received, active immediately',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRenewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Card Replace/Renew',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Report Loss button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Report Loss action
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Report Loss',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Reward news button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Reward news action
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reward news',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height / 1.5,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
