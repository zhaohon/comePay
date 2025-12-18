import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/token_receive_viewmodel.dart';
import 'package:provider/provider.dart';

/// 通用的代币网络列表（BTC/ETH + USDT/USDC 多网络 + HKD）
class TokenNetworkList extends StatefulWidget {
  final double totalAssets;
  /// 是否展示顶部搜索框，钱包页可关闭
  final bool showSearchBar;

  const TokenNetworkList({
    super.key,
    required this.totalAssets,
    this.showSearchBar = true,
  });

  @override
  State<TokenNetworkList> createState() => _TokenNetworkListState();
}

class _TokenNetworkListState extends State<TokenNetworkList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTokens);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTokens() {
    final viewModel =
        Provider.of<TokenReceiveViewModel>(context, listen: false);
    viewModel.filterTokens(_searchController.text);
  }

  void _goToReceiveDetail(BuildContext context, Map<String, dynamic> token) {
    if (token["symbol"] == "HKD") {
      // HKD 仅展示，不跳详情
      return;
    }

    final String network =
        (token["networks"] as List).isNotEmpty ? token["networks"][0] : '';

    Navigator.pushNamed(
      context,
      '/ReceiveDetailScreen',
      arguments: {
        'token': token,
        'network': network,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TokenReceiveViewModel>(
      create: (context) => TokenReceiveViewModel()
        ..fetchCryptoData()
        ..setTotalAssets(widget.totalAssets),
      child: Consumer<TokenReceiveViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              if (widget.showSearchBar) ...[
                // 搜索框
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchTokenHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 列表
              if (widget.showSearchBar)
                // 有搜索框时，使用 Expanded + ListView（接收页场景）
                Expanded(
                  child: viewModel.busy
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: viewModel.filteredTokens.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildTokenItem(context, viewModel.filteredTokens[index]);
                          },
                        ),
                )
              else
                // 无搜索框时，使用 shrinkWrap 让内容自然撑开（钱包页场景，由外层滚动）
                viewModel.busy
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.filteredTokens.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildTokenItem(context, viewModel.filteredTokens[index]);
                        },
                      ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTokenItem(BuildContext context, Map<String, dynamic> token) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToReceiveDetail(context, token),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Image.asset(token["iconPath"], width: 28, height: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      () {
                        final symbol = (token["symbol"] ?? "") as String;
                        final network = (token["networks"] as List).isNotEmpty
                            ? token["networks"][0] as String
                            : "";
                        if (symbol == 'BTC' || symbol == 'ETH' || symbol == 'HKD') {
                          return symbol;
                        }
                        return network.isNotEmpty ? "$symbol ($network)" : symbol;
                      }(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "\$0.00",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 2),
                  Text("\$0.00",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

