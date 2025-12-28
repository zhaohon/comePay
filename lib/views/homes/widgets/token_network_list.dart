import 'package:flutter/material.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:provider/provider.dart';

/// 通用的代币网络列表（使用钱包真实数据）
class TokenNetworkList extends StatefulWidget {
  final double totalAssets;

  const TokenNetworkList({
    super.key,
    required this.totalAssets,
  });

  @override
  State<TokenNetworkList> createState() => _TokenNetworkListState();
}

class _TokenNetworkListState extends State<TokenNetworkList> {
  @override
  void initState() {
    super.initState();
    // 初始化时获取钱包数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewModel>(context, listen: false).fetchWalletData();
    });
  }

  void _goToReceiveDetail(BuildContext context, WalletBalance balance) {
    // HKD 暂时不支持接收
    if (balance.currency == "HKD") {
      return;
    }

    Navigator.pushNamed(
      context,
      '/ReceiveDetailScreen',
      arguments: {
        'balance': balance,
      },
    );
  }

  /// 格式化余额：去掉尾部的0，如果是0则只显示"0"
  String _formatBalance(double balance, int decimals) {
    if (balance == 0) {
      return '0';
    }

    // 根据decimals决定最大小数位数
    int maxDecimals = decimals > 0 ? decimals.clamp(0, 8) : 2;
    String formatted = balance.toStringAsFixed(maxDecimals);

    // 去掉尾部的0和可能的小数点
    formatted = formatted.replaceAll(RegExp(r'\.?0+$'), '');

    // 如果结果为空或者只剩下小数点，返回'0'
    if (formatted.isEmpty || formatted == '.') {
      return '0';
    }

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // 列表
            Expanded(
              child: viewModel.busy
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : viewModel.balances.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                                  size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              Text(
                                '暂无资产',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
                          itemCount: viewModel.balances.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _buildTokenItem(
                                context, viewModel.balances[index]);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTokenItem(BuildContext context, WalletBalance balance) {
    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToReceiveDetail(context, balance),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 币种图标
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: balance.logo.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          balance.logo,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.currency_bitcoin,
                              color: AppColors.primary,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.currency_bitcoin,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 币种名称
                    Text(
                      balance.currency,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 币种全名
                    Text(
                      balance.coinName.isNotEmpty
                          ? balance.coinName
                          : balance.symbol,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 余额数量（优化格式）
                  Text(
                    _formatBalance(balance.balance, balance.decimals),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 币种符号
                  Text(
                    balance.symbol,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
