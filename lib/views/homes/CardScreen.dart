import 'package:comecomepay/views/homes/CardApplyConfirmScreen.dart'
    show CardApplyConfirmScreen;
import 'package:comecomepay/views/homes/CardTransactionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/views/homes/SecurityInfoItem.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/viewmodels/card_trade_viewmodel.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/models/card_list_model.dart';
import 'package:comecomepay/models/card_account_details_model.dart';
import 'package:comecomepay/views/homes/CardAuthorizationScreen.dart';
import 'package:comecomepay/views/homes/ApplyPhysicalCardScreen.dart';
import 'package:comecomepay/views/homes/ActivatePhysicalCardScreen.dart';

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
  bool get _isBusy => _isLoadingCards || _isLoadingCardDetails;
  bool _isRefreshing = false;
  DateTime? _lastTransactionFetchTime; // Record last transaction fetch time
  double?
      _lastBalance; // Record last known balance for smart transaction refresh
  bool _isInitialLoading = true;
  bool _isCardNumberVisible = false;
  bool _isCardLocked = false;
  bool _isBalanceVisible = true; // 余额是否可见
  Map<String, String> _cvvCache = {}; // 临时存储CVV，不持久化
  Map<String, String> _pinCache = {}; // 临时存储PIN，不持久化

  // Auto-refresh on visibility - debounce mechanism
  DateTime? _lastRefreshTime;
  bool _hasInitialLoaded = false; // Track if initial load is complete

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileScreenViewModel();
    _cardTradeViewModel = CardTradeViewModel();

    // 监听 CardViewModel 变更
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cardViewModel =
            Provider.of<CardViewModel>(context, listen: false);
        cardViewModel.addListener(_onCardViewModelChanged);
      }
    });

    // 优先使用缓存的卡片列表
    final cachedList = CardViewModel.cachedCardList;
    if (cachedList != null) {
      setState(() {
        _cardList = cachedList;
        _isInitialLoading = false;
      });
      if (cachedList.hasCards) {
        _currentCardIndex = 0;
      }
    } else {
      // 如果没有缓存，加载卡片列表
      _loadCardList();
    }

    _setupScrollListener();

    // Mark initial load as complete after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasInitialLoaded = true;
    });
  }

  void _onCardViewModelChanged() {
    if (!mounted) return;
    // 当 ViewModel 刷新时，静默同步本地数据
    _loadCardList(isSilent: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新显示时，检查是否需要刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRefreshCardList();
    });
  }

  /// Check and refresh card list (if cache updated)
  void _checkAndRefreshCardList() {
    final cachedList = CardViewModel.cachedCardList;
    if (cachedList != null && _cardList != null) {
      // 如果缓存中的卡片内容与当前不同，静默刷新
      if (cachedList.total != _cardList!.total) {
        _loadCardList(isSilent: true);
      }
    }
  }

  /// Auto-refresh when page becomes visible (with debounce)
  Future<void> _refreshOnVisible() async {
    // Skip if initial load hasn't completed yet
    if (!_hasInitialLoaded) return;

    // Prevent concurrent requests
    if (_isRefreshing) return;

    // Debounce: Don't refresh if refreshed within last 2 seconds
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < const Duration(seconds: 2)) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _lastRefreshTime = now;
    });

    try {
      // Auto-refresh is now silent to avoid interrupting user
      await _loadCardList(isSilent: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      final cardViewModel = Provider.of<CardViewModel>(context, listen: false);
      cardViewModel.removeListener(_onCardViewModelChanged);
    } catch (e) {
      // Ignore if provider not found
    }
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

  /// 格式化日期 (yyyy-MM-dd)
  String _formatExpiryDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '***';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MM/yy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// 加载卡片列表
  Future<void> _loadCardList(
      {bool isRefresh = false, bool isSilent = false}) async {
    if (!isRefresh && !isSilent && _cardList == null) {
      setState(() {
        _isLoadingCards = true;
        _cardError = null;
        _isInitialLoading = true;
      });
    }

    try {
      // 1. First, load card list
      final newList = await _cardService.getCardList();

      // 2. Update global cache
      CardViewModel.setCachedCardList(newList);

      // 3. Update state with incremental logic
      setState(() {
        final oldList = _cardList;

        if (oldList != null &&
            oldList.hasCards &&
            newList.hasCards &&
            isSilent) {
          // Silent incremental sync
          final List<CardListItemModel> mergedCards = List.from(oldList.cards);
          bool hasChanges = false;

          for (final newCard in newList.cards) {
            final existingIndex = mergedCards
                .indexWhere((c) => c.publicToken == newCard.publicToken);
            if (existingIndex == -1) {
              // Add new card to the end
              mergedCards.add(newCard);
              hasChanges = true;
            } else {
              // Update existing card status if changed
              if (mergedCards[existingIndex].status != newCard.status) {
                mergedCards[existingIndex] = newCard;
                hasChanges = true;
              }
            }
          }

          // If count decreased, something was deleted, trigger full refresh
          if (newList.cards.length < oldList.cards.length) {
            _cardList = newList;
            // Reset index if current card is gone
            if (_currentCardIndex >= newList.cards.length) {
              _currentCardIndex = 0;
            }
          } else if (hasChanges) {
            _cardList =
                CardListResponseModel(total: newList.total, cards: mergedCards);
          }
        } else {
          // Full refresh or initial load
          // Try to preserve current selected card
          if (isRefresh &&
              _cardList != null &&
              _cardList!.hasCards &&
              newList.hasCards) {
            final currentPublicToken =
                _cardList!.cards[_currentCardIndex].publicToken;
            final newIndex = newList.cards
                .indexWhere((c) => c.publicToken == currentPublicToken);
            if (newIndex != -1) {
              _currentCardIndex = newIndex;
            } else {
              _currentCardIndex = 0;
            }
          } else if (!isRefresh) {
            _currentCardIndex = 0;
          }
          _cardList = newList;
        }

        _isLoadingCards = false;
        _isInitialLoading = false;

        // Sync PageController with _currentCardIndex
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentCardIndex);
        }
      });

      // 4. After list is loaded and state updated, load details and transactions
      if (_cardList!.hasCards) {
        await _loadCurrentCardDetails(isSilent: isSilent);
        // Smart transaction refresh logic inside _loadTransactions
        await _loadTransactions(isSilent: isSilent);
      }
    } catch (e) {
      if (!isSilent) {
        setState(() {
          _cardError = e.toString();
          _isLoadingCards = false;
          _isInitialLoading = false;
          _cardList = CardListResponseModel(total: 0, cards: []);
        });
      }
      print('Error loading card list: $e');
    }
  }

  /// 加载当前选中卡片的详情
  Future<void> _loadCurrentCardDetails({bool isSilent = false}) async {
    if (_cardList == null || !_cardList!.hasCards) return;
    if (_currentCardIndex >= _cardList!.cards.length) return;

    final currentCard = _cardList!.cards[_currentCardIndex];

    if (!isSilent) {
      setState(() {
        _isLoadingCardDetails = true;
      });
    }

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
  Future<void> _loadTransactions(
      {bool isLoadMore = false, bool isSilent = false}) async {
    if (_cardList == null || !_cardList!.hasCards) return;
    if (_currentCardIndex >= _cardList!.cards.length) return;

    final currentCard = _cardList!.cards[_currentCardIndex];

    // Smart Refresh Logic for Transactions
    if (isSilent && !isLoadMore) {
      final now = DateTime.now();
      final bool balanceChanged = _lastBalance != _currentCardDetails?.balance;
      final bool isTimeout = _lastTransactionFetchTime == null ||
          now.difference(_lastTransactionFetchTime!) >
              const Duration(minutes: 5);

      // If neither balance changed nor timeout reached, skip refreshing transactions
      if (!balanceChanged && !isTimeout) {
        return;
      }
    }

    if (!isLoadMore) {
      setState(() {
        _transactions = [];
        _transactionPage = 1;
        _hasMoreTransactions = true;
      });
    }

    if (!_hasMoreTransactions) return;

    setState(() {
      if (!isSilent) {
        _isLoadingTransactions = true;
      }
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
          _lastTransactionFetchTime = DateTime.now();
          _lastBalance = _currentCardDetails?.balance;
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
    _loadCurrentCardDetails(isSilent: false);
    _loadTransactions(isSilent: false);
  }

  /// 修改卡片状态 (锁卡/解锁)
  Future<void> _modifyCardStatus(String statusCode) async {
    if (_cardList == null ||
        !_cardList!.hasCards ||
        _currentCardIndex >= _cardList!.cards.length) return;

    final currentToken = _cardList!.cards[_currentCardIndex].publicToken;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _cardService.modifyCardStatus(currentToken, statusCode);

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusCode == 'G1'
                ? AppLocalizations.of(context)!.cardLockedSuccessfully
                : AppLocalizations.of(context)!.cardUnlockedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // Refresh card details to reflect new status
      _loadCurrentCardDetails(isSilent: true);
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusCode == 'G1'
                ? AppLocalizations.of(context)!.failedToLockCard
                : AppLocalizations.of(context)!.failedToUnlockCard),
            backgroundColor: AppColors.error,
          ),
        );
      }
      print('Error modifying card status: $e');
    }
  }

  /// 显示确认弹窗
  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style: const TextStyle(color: AppColors.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('card-screen'),
      onVisibilityChanged: (info) {
        // When page becomes visible (visibility > 0.01), trigger refresh
        if (info.visibleFraction > 0.01) {
          _refreshOnVisible();
        }
      },
      child: Stack(
        children: [
          _buildContent(),
          // 悬浮在最右侧居中的邮寄进度按钮
          if (_cardList != null && _cardList!.hasCards)
            // Positioned(
            //   right: 0,
            //   top: MediaQuery.of(context).size.height * 0.45,
            //   child: _buildMailingProgressTab(context),
            // ),
            if (_isBusy)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        ],
      ),
    );
  }

  /// Build the actual screen content
  Widget _buildContent() {
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

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      // appBar: AppBar(
      //   backgroundColor: AppColors.pageBackground,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCardList(isRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                                  AppLocalizations.of(context)!
                                      .availableCreditEstimate,
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
                              _loadCardList(isSilent: true);
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

              // ===== 卡片展示区域（全宽） =====
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      constraints.maxWidth - 16; // 水平方向总共有16的margin
                  final cardHeight = cardWidth * (853 / 1280);
                  return SizedBox(
                    height: cardHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: cardCount,
                      onPageChanged: _onCardChanged,
                      itemBuilder: (context, index) {
                        final card = _cardList!.cards[index];
                        return _buildCardWidget(card);
                      },
                    ),
                  );
                },
              ),

              // ===== 卡片指示点 =====
              if (cardCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      cardCount,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentCardIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentCardIndex == index
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                )
              else
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
                    _buildActionCard(
                      Icons.info_outline,
                      AppLocalizations.of(context)!.cardInformation,
                      onTap: () {
                        if (_isBusy) return;
                        if (_currentCardDetails == null) return;
                        _showCardSecurityInfo();
                      },
                    ),
                    _buildActionCard(
                      (_currentCardDetails?.status == 'frozen')
                          ? Icons.lock_open_outlined
                          : Icons.lock_outline,
                      (_currentCardDetails?.status == 'frozen')
                          ? AppLocalizations.of(context)!.unlockCard
                          : AppLocalizations.of(context)!.lockCard,
                      onTap: () {
                        if (_isBusy) return;
                        if (_currentCardDetails == null) return;
                        // 'normal' -> Lock (G1)
                        // 'frozen' -> Unlock (00)
                        if (_currentCardDetails!.status == 'normal') {
                          _showConfirmationDialog(
                            title:
                                AppLocalizations.of(context)!.confirmLockTitle,
                            content: AppLocalizations.of(context)!
                                .confirmLockContent,
                            onConfirm: () => _modifyCardStatus('G1'),
                          );
                        } else if (_currentCardDetails!.status == 'frozen') {
                          _showConfirmationDialog(
                            title: AppLocalizations.of(context)!
                                .confirmUnlockTitle,
                            content: AppLocalizations.of(context)!
                                .confirmUnlockContent,
                            onConfirm: () => _modifyCardStatus('00'),
                          );
                        } else {
                          // cancelled or others
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .featureComingSoon),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    _buildActionCard(
                      Icons.touch_app_outlined,
                      AppLocalizations.of(context)!.cardAuthorization,
                      onTap: () {
                        if (_isBusy) return;
                        if (_currentCardDetails == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CardAuthorizationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      Icons.credit_card_outlined,
                      AppLocalizations.of(context)!.applyPhysicalCard,
                      onTap: () {
                        if (_isBusy) return;
                        if (_currentCardDetails == null) return;
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(AppLocalizations.of(context)!
                        //         .featureComingSoon),
                        //     duration: const Duration(seconds: 1),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplyPhysicalCardScreen(
                              cardDetails: _currentCardDetails,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      Icons.link_off_outlined,
                      AppLocalizations.of(context)!.reportLoss,
                      onTap: () {
                        if (_isBusy) return;
                        if (_currentCardDetails == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .featureComingSoon),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ===== 交易记录区域（暂时隐藏） =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bill,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.grid_view),
                          onPressed: () {
                            // TODO: 查看更多交易或筛选
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 交易记录列表（暂时隐藏）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    if (_isLoadingTransactions && _transactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_transactions.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.noTransactionsYet,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._transactions
                          .map((transaction) =>
                              _buildTransactionItem(transaction))
                          .toList(),

                    // 加载更多指示器
                    if (_isLoadingTransactions && _transactions.isNotEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/card.jpg'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return Stack(
            children: [
              // 底部暗色渐变，增强文字区分度
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 内容统一从左下角定位
              Positioned(
                left: width * 0.08,
                bottom: height * 0.10,
                right: width * 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 卡号
                    GestureDetector(
                      onTap:
                          isCurrentCard ? () => _showCardSecurityInfo() : null,
                      child: Row(
                        children: [
                          Text(
                            card.cardNo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                    color: Colors.black87),
                              ],
                            ),
                          ),
                          if (isCurrentCard) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.visibility_off,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                              shadows: [
                                Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03), // 卡号和底部信息之间的间距

                    // 底部一行：姓名 + 到期日 (移除硬编码标签)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 姓名部分
                        Expanded(
                          flex: 1,
                          child: Text(
                            _currentCardDetails?.memberName ?? 'NAME',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                    color: Colors.black87),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 到期日部分
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: isCurrentCard
                                  ? () => _showCardSecurityInfo()
                                  : null,
                              child: const Text(
                                '**/**',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2.0,
                                        color: Colors.black),
                                    Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 6.0,
                                        color: Colors.black87),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 遮罩层和锁图标（当卡片被锁定时）
              if (isCurrentCard && cardDetails?.status == 'frozen') ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 构建交易记录项
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] ?? 0.0;
    final isPositive = amount > 0;
    final description = transaction['description'] ??
        transaction['merchant'] ??
        AppLocalizations.of(context)!.transactionDefault;
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
        title: Text(AppLocalizations.of(context)!.availableCreditEstimate),
        content: Text(
          AppLocalizations.of(context)!.availableAmountEstimateDesc,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
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
                    AppLocalizations.of(context)!.cardSecurityInfo,
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
                    SecurityInfoItem(
                        label: AppLocalizations.of(context)!.cardNumber,
                        value: cardNumber),
                    const SizedBox(height: 20),
                    SecurityInfoItem(
                        label: AppLocalizations.of(context)!.expiryDate,
                        value:
                            _formatExpiryDate(_currentCardDetails?.expiryDate)),
                    const SizedBox(height: 20),
                    SecurityInfoItem(
                        label: AppLocalizations.of(context)!.cvvCode,
                        value: cvv),
                    const SizedBox(height: 20),
                    // _buildSecurityInfoItem(
                    //     AppLocalizations.of(context)!.pinCode, pin),
                    // const SizedBox(height: 20),
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
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: const TextStyle(
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

  /// 构建安全信息项 (向后兼容包装器)
  Widget _buildSecurityInfoItem(String label, String value) {
    return SecurityInfoItem(label: label, value: value);
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
                      AspectRatio(
                        aspectRatio: 1280 / 813, // 保持原图比例
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            "assets/visa.jpg",
                            width: double.infinity,
                            fit: BoxFit.contain, // 完整显示，不裁剪
                          ),
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

  Widget _buildActionCard(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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

  /// 构建右侧悬浮的“邮寄进度”按钮
  Widget _buildMailingProgressTab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMailingProgressBottomSheet(context, isShipped: true);
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDE68A), // 黄色背景
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(-2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: const Text(
          '邮\n寄\n进\n度',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
      ),
    );
  }

  /// 显示邮寄进度底部弹窗
  void _showMailingProgressBottomSheet(BuildContext context,
      {bool isShipped = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题与关闭按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "邮寄进度",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 进度时间线区域
              _buildTimeline(isShipped: isShipped),
              const SizedBox(height: 48),

              // 已收到卡片大按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 关闭进度底部弹窗
                    Navigator.pop(ctx);
                    // 弹出确实收到卡片对话框
                    _showActivationConfirmDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // 深色按钮
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '已收到卡片',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivationConfirmDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 34), // 底部留些安全距离
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题与关闭按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "温馨提示",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogCtx),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 提示文案
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "请确认您已收到实体卡再进行激活操作！",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 按钮1: 未收到卡片 (粉红)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E), // 粉红色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '未收到卡片，稍后激活',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 按钮2: 已收到卡片 (深蓝)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx); // 关掉确认框
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ActivatePhysicalCardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // 深蓝色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '已收到卡片，马上激活',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline({required bool isShipped}) {
    return Column(
      children: [
        // 1. 升级卡片申请
        _buildTimelineStep(
          title: "升级卡片申请",
          isActive: true,
          isNextActive: true, // 默认制卡中肯定是亮的
          isLast: false,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildProgressDetailRow("申请时间", "2026-02-10 17:10:20"),
              const SizedBox(height: 16),
              _buildProgressDetailRow("收卡地址", "河北省石家庄市开发区润都荣园"),
              const SizedBox(height: 16),
              _buildProgressDetailRow("收件人", "赵宏 150****8358"),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // 2. 制卡中
        _buildTimelineStep(
          title: "制卡中",
          isActive: true,
          isNextActive: isShipped, // 这根线只在已经发货时变绿
          isLast: false,
          content: const SizedBox(height: 16), // 空隙
        ),
        // 3. 卡片已寄出
        _buildTimelineStep(
          title: "卡片已寄出",
          isActive: isShipped,
          isNextActive: false, // 只有激活了才变绿，默认这步还没激活，线置灰
          isLast: false,
          content: isShipped
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildProgressDetailRow("寄出时间", "2026-02-26 16:01:16"),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("快递查询",
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        Row(
                          children: [
                            const Text("SF5107905219317",
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_outlined,
                                size: 14, color: AppColors.textSecondary),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox(height: 16),
        ),
        // 4. 激活卡片
        _buildTimelineStep(
          title: "激活卡片",
          isActive: false, // 永远是灰色，直至用户真的激活
          isNextActive: false,
          isLast: true,
          content: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              "收到卡片后请激活后使用！",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required bool isActive,
    required bool isNextActive,
    required bool isLast,
    Widget? content,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧轴线与圆点
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isNextActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // 右侧内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (content != null) content,
              ],
            ),
          ),
        ],
      ),
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
