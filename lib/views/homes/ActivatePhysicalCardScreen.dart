import 'package:flutter/material.dart';
import 'package:comecomepay/utils/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/views/homes/ActivatePhysicalCardSuccessScreen.dart';

import '../../l10n/app_localizations.dart';

class ActivatePhysicalCardScreen extends StatefulWidget {
  final bool isReset;

  const ActivatePhysicalCardScreen({
    super.key,
    this.isReset = false,
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

  @override
  void dispose() {
    _pinController1.dispose();
    _pinController2.dispose();
    _emailCodeController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() async {
    // 基础校验
    if (_pinController1.text.length != 6 || _pinController2.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnter6DigitPin)),
      );
      return;
    }
    if (_pinController1.text != _pinController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pinCodesDoNotMatch)),
      );
      return;
    }
    if (_emailCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterEmailVerificationCode)),
      );
      return;
    }

    // 弹出加载中的提示框 (模拟提交)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingCtx) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  widget.isReset ? AppLocalizations.of(context)!.resetting : AppLocalizations.of(context)!.activating,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 假装请求接口耗时1.5秒
    await Future.delayed(const Duration(milliseconds: 1500));

    if (context.mounted) {
      // 关掉加载框
      Navigator.pop(context);

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
  }

  @override
  Widget build(BuildContext context) {
    // 假设测试邮箱
    final maskEmail = "285***@qq.com";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isReset ? AppLocalizations.of(context)!.resetPinCode : AppLocalizations.of(context)!.activatePhysicalCard,
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
                widget.isReset ? AppLocalizations.of(context)!.resetPinCode : AppLocalizations.of(context)!.setPinCode,
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
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: AppLocalizations.of(context)!.pleaseEnter6DigitPinHint,
                    hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: AppLocalizations.of(context)!.pleaseConfirm6DigitPinHint,
                    hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          hintText: AppLocalizations.of(context)!.pleaseEnterVerificationCode,
                          hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement get code functionality
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context)!.getCode,
                          style: const TextStyle(
                            color: Color(0xFF10B981), // 绿色按钮文字
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.emailCodeSentToHint(maskEmail),
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
                child: ElevatedButton(
                  onPressed: _onSubmitPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // 深色按钮
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isReset ? AppLocalizations.of(context)!.confirm : AppLocalizations.of(context)!.activateNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}
