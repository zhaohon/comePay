import 'package:flutter/material.dart';
import 'package:comecomepay/services/swap_service.dart';
import 'package:comecomepay/models/swap_transaction_model.dart';
import 'package:intl/intl.dart';

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
          SnackBar(content: Text('加载失败: ${e.toString()}')),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '兑换记录',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            '暂无兑换记录',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间
          Text(
            formattedDate,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // 兑换方向
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 消耗
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '消耗',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _getCoinIcon(transaction.fromCurrency, isRed: true),
                      const SizedBox(width: 8),
                      Text(
                        '${transaction.fromAmount.toStringAsFixed(8)} ${transaction.fromCurrency}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 获得
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '获得',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _getCoinIcon(transaction.toCurrency, isRed: false),
                      const SizedBox(width: 8),
                      Text(
                        '${transaction.toAmount.toStringAsFixed(8)} ${transaction.toCurrency}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getCoinIcon(String currency, {required bool isRed}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRed ? Colors.red.shade50 : Colors.green.shade50,
      ),
      child: Center(
        child: Icon(
          isRed ? Icons.remove : Icons.add,
          size: 16,
          color: isRed ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
