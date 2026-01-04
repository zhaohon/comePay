import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/unified_transaction_viewmodel.dart';
import 'package:comecomepay/widgets/transaction_item_widget.dart';
import 'package:comecomepay/views/transactions/transaction_detail_screen.dart';

/// 统一交易记录列表页面 - 优化版
/// 支持下拉刷新和上拉加载更多
class UnifiedTransactionListScreen extends StatefulWidget {
  const UnifiedTransactionListScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedTransactionListScreen> createState() =>
      _UnifiedTransactionListScreenState();
}

class _UnifiedTransactionListScreenState
    extends State<UnifiedTransactionListScreen> {
  final ScrollController _scrollController = ScrollController();
  late UnifiedTransactionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        Provider.of<UnifiedTransactionViewModel>(context, listen: false);

    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchTransactions(refresh: true);
    });

    // 监听滚动事件，实现上拉加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听，触发上拉加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 距离底部还有200像素时开始加载
      if (!_viewModel.isLoadingMore && _viewModel.hasMore) {
        _viewModel.loadMore();
      }
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await _viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '资金流水',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        // 添加底部分隔线
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: Consumer<UnifiedTransactionViewModel>(
        builder: (context, viewModel, child) {
          // 错误状态
          if (viewModel.hasError) {
            return _buildErrorState(viewModel.errorMessage ?? 'Unknown error');
          }

          // 加载状态（首次加载）
          if (viewModel.isLoading && viewModel.transactions.isEmpty) {
            return _buildLoadingState();
          }

          // 空状态
          if (viewModel.transactions.isEmpty && !viewModel.isLoading) {
            return _buildEmptyState();
          }

          // 数据列表
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFFA855F7),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              itemCount: viewModel.transactions.length + 1,
              itemBuilder: (context, index) {
                // 交易记录项
                if (index < viewModel.transactions.length) {
                  final transaction = viewModel.transactions[index];
                  return TransactionItemWidget(
                    transaction: transaction,
                    isInList: true, // 使用卡片样式
                    onTap: () {
                      // 导航到交易详情页面
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                  );
                }

                // 底部加载更多指示器
                return _buildLoadMoreIndicator(viewModel);
              },
            ),
          );
        },
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
          ),
          SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无交易记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '您还没有任何交易记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _viewModel.refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '重新加载',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(UnifiedTransactionViewModel viewModel) {
    if (!viewModel.hasMore) {
      // 没有更多数据
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '没有更多了',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ),
            Container(
              width: 40,
              height: 1,
              color: Colors.grey[300],
            ),
          ],
        ),
      );
    }

    if (viewModel.isLoadingMore) {
      // 正在加载更多
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
          ),
        ),
      );
    }

    // 可以加载更多
    return const SizedBox.shrink();
  }
}
