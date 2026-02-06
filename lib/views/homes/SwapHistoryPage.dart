import 'package:flutter/material.dart';
import 'package:Demo/services/swap_service.dart';
import 'package:Demo/models/swap_transaction_model.dart';
import 'package:Demo/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:Demo/l10n/app_localizations.dart';

class SwapHistoryPage extends StatefulWidget {
  const SwapHistoryPage({super.key});

  @override
  State<SwapHistoryPage> createState() => _SwapHistoryPageState();
}

class _SwapHistoryPageState extends State<SwapHistoryPage> {
  final SwapService _swapService = SwapService();
  final ScrollController _scrollController = ScrollController();

  List<SwapTransaction> _transactions = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadHistory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _swapService.getSwapHistory(page: 1, limit: 20);
      final historyResponse = SwapHistoryResponse.fromJson(response);

      if (mounted) {
        setState(() {
          _transactions = historyResponse.transactions;
          _currentPage = 1;
          _hasMore = historyResponse.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.loadingFailed}: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response =
          await _swapService.getSwapHistory(page: nextPage, limit: 20);
      final historyResponse = SwapHistoryResponse.fromJson(response);

      if (mounted) {
        setState(() {
          _transactions.addAll(historyResponse.transactions);
          _currentPage = nextPage;
          _hasMore = historyResponse.hasMore;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.swapHistoryTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noSwapHistory,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _transactions.length) {
                          // 加载更多指示器
                          return _isLoadingMore
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        return _buildTransactionCard(_transactions[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildTransactionCard(SwapTransaction transaction) {
    final dateTime = DateTime.parse(transaction.createdAt);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    // 格式化金额：根据币种决定小数位数
    String formatAmount(double amount, String currency) {
      if (currency == 'BTC') {
        return amount.toStringAsFixed(8);
      } else if (currency == 'HKD' || currency == 'USD') {
        return amount.toStringAsFixed(2);
      } else {
        return amount.toStringAsFixed(6);
      }
    }

    final fromAmountStr =
        formatAmount(transaction.fromAmount, transaction.fromCurrency);
    final toAmountStr =
        formatAmount(transaction.toAmount, transaction.toCurrency);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
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
          // 时间
          Text(
            formattedDate,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // "消耗"标签
          Text(
            AppLocalizations.of(context)!.consumed,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // 消耗部分（红色减号 + 金额 + 完整币种）
          Row(
            children: [
              _getCoinIcon(transaction.fromCurrency, isRed: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$fromAmountStr ${transaction.fromCurrency}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 获得部分（绿色加号 + 金额 + 完整币种）
          Row(
            children: [
              _getCoinIcon(transaction.toCurrency, isRed: false),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$toAmountStr ${transaction.toCurrency}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getCoinIcon(String currency, {required bool isRed}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRed ? Colors.red.shade50 : Colors.green.shade50,
      ),
      child: Center(
        child: Icon(
          isRed ? Icons.remove : Icons.add,
          size: 14,
          color: isRed ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
