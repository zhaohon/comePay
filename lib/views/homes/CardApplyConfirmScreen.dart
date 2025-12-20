import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/viewmodels/token_receive_viewmodel.dart';
import 'package:comecomepay/views/homes/CardVerificationScreen.dart';
import 'package:provider/provider.dart';

class CardApplyConfirmScreen extends StatefulWidget {
  const CardApplyConfirmScreen({Key? key}) : super(key: key);

  @override
  State<CardApplyConfirmScreen> createState() => _CardApplyConfirmScreenState();
}

class _CardApplyConfirmScreenState extends State<CardApplyConfirmScreen> {
  Map<String, dynamic>? _selectedNetwork;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TokenReceiveViewModel>(
      create: (context) => TokenReceiveViewModel()
        ..fetchCryptoData()
        ..setTotalAssets(0.0),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppLocalizations.of(context)!.applyVirtualCard,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<TokenReceiveViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 卡信息
                  _buildSectionTitle(
                      AppLocalizations.of(context)!.cardInformation),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    AppLocalizations.of(context)!.cardName,
                    'Come Come Pay Card',
                    isClickable: true,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    AppLocalizations.of(context)!.cardOrganization,
                    'VISA',
                    isClickable: false,
                  ),
                  const SizedBox(height: 24),

                  // 卡费
                  _buildSectionTitle(AppLocalizations.of(context)!.cardFee),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    AppLocalizations.of(context)!.fee,
                    '5 USD',
                    isClickable: false,
                  ),
                  const SizedBox(height: 8),
                  _buildNetworkSelectionRow(viewModel),
                  const SizedBox(height: 32),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedNetwork == null
                          ? null
                          : () async {
                              // TODO: 将选择的网络地址发送到后端
                              // 暂时使用假数据
                              final networkAddress =
                                  _selectedNetwork!['address'] ??
                                      'mock_address';
                              print(
                                  'Selected network: ${_selectedNetwork!['symbol']}');
                              print('Address: $networkAddress');

                              // 跳转到填资料页面
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Cardverificationscreen(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.submit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {required bool isClickable}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelectionRow(TokenReceiveViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        _showNetworkSelectionBottomSheet(viewModel);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.selectNetwork,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  _selectedNetwork == null
                      ? AppLocalizations.of(context)!.pleaseSelect
                      : _getNetworkDisplayName(_selectedNetwork!),
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        _selectedNetwork == null ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getNetworkDisplayName(Map<String, dynamic> network) {
    final symbol = network['symbol'] as String? ?? '';
    final networks = network['networks'] as List? ?? [];
    if (networks.isEmpty ||
        symbol == 'BTC' ||
        symbol == 'ETH' ||
        symbol == 'HKD') {
      return symbol;
    }
    return '$symbol (${networks[0]})';
  }

  void _showNetworkSelectionBottomSheet(TokenReceiveViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selectNetwork,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Network list
                Expanded(
                  child: viewModel.busy
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.filteredTokens.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final token = viewModel.filteredTokens[index];
                            // 过滤掉 HKD
                            if (token['symbol'] == 'HKD') {
                              return const SizedBox.shrink();
                            }
                            return _buildNetworkItem(token);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNetworkItem(Map<String, dynamic> token) {
    final isSelected = _selectedNetwork != null &&
        _selectedNetwork!['symbol'] == token['symbol'] &&
        (_selectedNetwork!['networks'] as List?)?.isNotEmpty ==
            (token['networks'] as List?)?.isNotEmpty &&
        (((_selectedNetwork!['networks'] as List?)?.isEmpty ?? true) ||
            (_selectedNetwork!['networks'] as List?)?[0] ==
                (token['networks'] as List?)?[0]);

    return Card(
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedNetwork = token;
          });
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Image.asset(token['iconPath'], width: 28, height: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getNetworkDisplayName(token),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\$0.00',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '0',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '\$0.00',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
