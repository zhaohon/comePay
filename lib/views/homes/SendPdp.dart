import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/services/withdraw_service.dart';

class SendPdp extends StatefulWidget {
  const SendPdp({super.key});

  @override
  _SendPdpState createState() => _SendPdpState();
}

class _SendPdpState extends State<SendPdp> {
  WalletBalance? balance;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final WithdrawService _withdrawService = WithdrawService();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['balance'] != null) {
      setState(() {
        balance = args['balance'] as WalletBalance;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _setMaxAmount() {
    if (balance != null) {
      _amountController.text = balance!.balance.toString();
    }
  }

  Future<void> _submitWithdraw() async {
    // Validate
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入接收地址')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }

    if (amount > balance!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('余额不足')),
      );
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract network from currency (e.g., "USDT-TRC20" -> "TRC20")
      String network = '';
      if (balance!.currency.contains('-')) {
        network = balance!.currency.split('-').last;
      } else {
        // Default fallback if no network specified
        network =
            balance!.mainSymbol.isNotEmpty ? balance!.mainSymbol : 'UNKNOWN';
      }

      // Call withdraw API
      final request = WithdrawRequestModel(
        currency: balance!.currency,
        amount: amount,
        address: _addressController.text.trim(),
        network: network,
      );

      final response = await _withdrawService.withdraw(request);

      if (!mounted) return;

      // Success - Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Wait a bit then go back
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('提现失败: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (balance == null) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/WithdrawHistory');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token Info Card
            Container(
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
              child: Row(
                children: [
                  // Token icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: balance!.logo.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              balance!.logo,
                              width: 48,
                              height: 48,
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
                        Text(
                          balance!.currency,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance!.coinName.isNotEmpty
                              ? balance!.coinName
                              : balance!.symbol,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // To Address section
            const Text(
              '接收地址',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              enabled: !_isLoading,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '请输入或粘贴地址',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPlaceholder,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.border.withOpacity(0.5), width: 1),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          // TODO: Implement QR scanner
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('扫描二维码功能开发中')),
                          );
                        },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '数量',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '可用: ${balance!.balance} ${balance!.symbol}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: !_isLoading,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPlaceholder,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.border.withOpacity(0.5), width: 1),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${balance!.symbol} ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _setMaxAmount,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient:
                                _isLoading ? null : AppColors.primaryGradient,
                            color: _isLoading ? Colors.grey : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '全部',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppColors.primaryGradient,
                  color: _isLoading ? Colors.grey : null,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitWithdraw,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '确认',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}
