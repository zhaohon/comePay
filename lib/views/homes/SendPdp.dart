import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:comecomepay/models/wallet_model.dart';
import 'package:comecomepay/services/withdraw_service.dart';
import 'package:comecomepay/models/requests/internal_transfer_request_model.dart';
import 'package:comecomepay/widgets/otp_input.dart';
import 'package:comecomepay/utils/transaction_password_guard.dart';

import '../../l10n/app_localizations.dart';
import 'ScanAddressQrScreen.dart';

class SendPdp extends StatefulWidget {
  const SendPdp({super.key});

  @override
  _SendPdpState createState() => _SendPdpState();
}

class _SendPdpState extends State<SendPdp> with SingleTickerProviderStateMixin {
  WalletBalance? balance;

  // External Transfer Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Internal Transfer Controllers
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _internalAmountController =
      TextEditingController();

  final WithdrawService _withdrawService = WithdrawService();
  bool _isLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['balance'] != null) {
      if (balance == null) {
        setState(() {
          balance = args['balance'] as WalletBalance;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _uidController.dispose();
    _internalAmountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _setMaxAmount(bool isInternal) {
    if (balance != null) {
      if (isInternal) {
        _internalAmountController.text = balance!.balance.toString();
      } else {
        _amountController.text = balance!.balance.toString();
      }
    }
  }

  Future<void> _openScanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanAddressQrScreen(),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      _addressController.text = result;
    }
  }

  Future<void> _submitExternalWithdraw() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.pleaseEnterRecipientAddress)),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseEnterValidAmount)),
      );
      return;
    }

    if (amount > balance!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.balanceInsufficient)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String network = '';
      if (balance!.currency.contains('-')) {
        network = balance!.currency.split('-').last;
      } else {
        network =
            balance!.mainSymbol.isNotEmpty ? balance!.mainSymbol : 'UNKNOWN';
      }

      final request = WithdrawRequestModel(
        currency: balance!.currency,
        amount: amount,
        address: _addressController.text.trim(),
        network: network,
      );

      final response = await _withdrawService.withdraw(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .withdrawFailedWithError(e.toString())),
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

  Future<void> _submitInternalTransfer() async {
    if (_uidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.enterRecipientUid)),
      );
      return;
    }

    final amount = double.tryParse(_internalAmountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseEnterValidAmount)),
      );
      return;
    }

    if (amount > balance!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.balanceInsufficient)),
      );
      return;
    }

    // 通过接口检查交易密码是否已设置
    final isPasswordSet = await TransactionPasswordGuard.check(context);
    if (!isPasswordSet) return; // 未设置，已弹窗提示

    // Show Password Bottom Sheet
    final password = await _showTransactionPasswordBottomSheet();
    if (password == null || password.isEmpty) return; // User cancelled

    setState(() {
      _isLoading = true;
    });

    try {
      final request = InternalTransferRequestModel(
        amount: amount,
        currency: balance!.currency,
        description: 'Internal transfer',
        recipientUid: int.parse(_uidController.text.trim()),
        transactionPassword: password,
      );

      final response = await _withdrawService.transferByUid(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.internalTransferFailed(
              e.toString().replaceAll("Exception: ", ""))),
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



  Future<String?> _showTransactionPasswordBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.confirmTransaction,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!
                      .enter6DigitTransactionPasswordToVerify,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.8)),
                ),
              ),
              const SizedBox(height: 40),
              // Centered OTP Input
              OtpInput(
                length: 6,
                obscureText: true,
                onCompleted: (val) {
                  Navigator.pop(ctx, val);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTokenInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.currency_bitcoin,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
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
    );
  }

  Widget _buildExternalTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recipientAddress,
          style: const TextStyle(
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
            hintText: AppLocalizations.of(context)!.enterOrPasteAddress,
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
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
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
              onPressed: _isLoading ? null : _openScanQr,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.balanceAvailable(
                  balance!.balance.toString(), balance!.symbol),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
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
                    onTap: _isLoading ? null : () => _setMaxAmount(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _isLoading ? null : AppColors.primaryGradient,
                        color: _isLoading ? Colors.grey : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.all,
                        style: const TextStyle(
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
      ],
    );
  }

  Widget _buildInternalTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recipientUid,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _uidController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterRecipientUidHint,
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
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.5), width: 1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.balanceAvailable(
                  balance!.balance.toString(), balance!.symbol),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _internalAmountController,
          enabled: !_isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
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
                    onTap: _isLoading ? null : () => _setMaxAmount(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _isLoading ? null : AppColors.primaryGradient,
                        color: _isLoading ? Colors.grey : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.all,
                        style: const TextStyle(
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
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.internalTransferTip,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
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
        title: Text(
          AppLocalizations.of(context)!.send,
          style: const TextStyle(
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
      body: Column(
        children: [
          // Premium sliding Segmented Control
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA), // iOS style light gray
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                // Sliding Pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: _tabController.index == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tab Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _tabController.animateTo(0);
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.tokenWithdrawal,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _tabController.index == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _tabController.index == 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _tabController.animateTo(1);
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.internalTransfer,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _tabController.index == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _tabController.index == 1
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTokenInfoCard(),
                  const SizedBox(height: 20),

                  // Conditional form rendering
                  if (_tabController.index == 0)
                    _buildExternalTab()
                  else
                    _buildInternalTab(),

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
                        onPressed: _isLoading
                            ? null
                            : (_tabController.index == 0
                                ? _submitExternalWithdraw
                                : _submitInternalTransfer),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.confirm,
                                style: const TextStyle(
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
          ),
        ],
      ),
    );
  }
}
