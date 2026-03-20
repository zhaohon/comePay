import 'dart:async';
import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/views/homes/ActivatePhysicalCardSuccessScreen.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/services/hive_storage_service.dart';

import '../../l10n/app_localizations.dart';

class ActivatePhysicalCardScreen extends StatefulWidget {
  final bool isReset;
  final String publicToken;

  const ActivatePhysicalCardScreen({
    super.key,
    this.isReset = false,
    required this.publicToken,
  });

  @override
  State<ActivatePhysicalCardScreen> createState() =>
      _ActivatePhysicalCardScreenState();
}

class _ActivatePhysicalCardScreenState
    extends State<ActivatePhysicalCardScreen> {
  final TextEditingController _pinController1 = TextEditingController();
  final TextEditingController _pinController2 = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  final CardService _cardService = CardService();

  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _hasSentCode = false;
  int _countdown = 0;
  Timer? _timer;
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final profile = await HiveStorageService.getProfileData();
    if (mounted) {
      setState(() {
        _userEmail = profile?.user.email ?? "";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController1.dispose();
    _pinController2.dispose();
    _emailCodeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _onGetCodePressed() async {
    if (_isSendingCode || _countdown > 0) return;

    setState(() {
      _isSendingCode = true;
    });

    try {
      await _cardService.sendPinCode(
        widget.publicToken,
        widget.isReset
            ? 'card_pin_activate'
            : 'card_pin_activate', // 接口文档中激活和更新都可用 activate
      );
      _startTimer();
      setState(() {
        _hasSentCode = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.verificationCodeSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _onSubmitPressed() async {
    // 基础校验
    if (_pinController1.text.length < 4 || _pinController2.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseEnter6DigitPinHint)),
      );
      return;
    }
    if (_pinController1.text != _pinController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.pinCodesDoNotMatch)),
      );
      return;
    }
    if (_emailCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .pleaseEnterEmailVerificationCode)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _cardService.setPin(
        widget.publicToken,
        _pinController1.text,
        _emailCodeController.text,
      );

      if (mounted) {
        if (widget.isReset) {
          // 重置场景：成功提示，返回上页
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.pinResetSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          // 激活场景：跳转到成功详情页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ActivatePhysicalCardSuccessScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isReset
              ? AppLocalizations.of(context)!.resetPinCode
              : AppLocalizations.of(context)!.activatePhysicalCard,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== 1. 设置PIN码区域 =====
              Text(
                widget.isReset
                    ? AppLocalizations.of(context)!.resetPinCode
                    : AppLocalizations.of(context)!.setPinCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pinCodeUsageWarning,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFEF4444), // 红色警示文字
                ),
              ),
              const SizedBox(height: 24),

              // PIN输入1
              Text(
                AppLocalizations.of(context)!.pleaseSetNew6DigitPin,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _pinController1,
                  keyboardType: TextInputType.number,
                  obscureText: true, // 密码掩码
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: "",
                    hintText:
                        AppLocalizations.of(context)!.pleaseEnter6DigitPinHint,
                    hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PIN输入2
              Text(
                AppLocalizations.of(context)!.pleaseConfirmNew6DigitPin,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _pinController2,
                  keyboardType: TextInputType.number,
                  obscureText: true, // 密码掩码
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: AppLocalizations.of(context)!
                        .pleaseConfirm6DigitPinHint,
                    hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ===== 2. 安全验证区域 =====
              Text(
                AppLocalizations.of(context)!.verificationMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.emailVerificationCode,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: AppLocalizations.of(context)!
                              .pleaseEnterVerificationCode,
                          hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: GestureDetector(
                        onTap: (_isSendingCode || _countdown > 0)
                            ? null
                            : _onGetCodePressed,
                        child: Center(
                          child: _isSendingCode
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  _countdown > 0
                                      ? "$_countdown 秒"
                                      : (_hasSentCode
                                          ? localizations.resendCode
                                          : localizations.getCode),
                                  style: TextStyle(
                                    color: _countdown > 0
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.emailCodeSentToHint(_maskEmail(_userEmail)),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 48),

              // 立即激活按钮
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
                    onPressed: _isLoading ? null : _onSubmitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.isReset
                                ? localizations.confirm
                                : localizations.activateNow,
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
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return "";
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    return "${username.substring(0, 2)}********@$domain";
  }
}
