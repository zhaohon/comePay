import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/services/card_service.dart';
import 'package:comecomepay/models/card_apply_model.dart';
import 'package:comecomepay/views/homes/CardApplyProgressScreen.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';

class CardOtpScreen extends StatefulWidget {
  const CardOtpScreen({super.key});

  @override
  State<CardOtpScreen> createState() => _CardOtpScreenState();
}

class _CardOtpScreenState extends State<CardOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final CardService _cardService = CardService();
  bool _isProcessing = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  /// 验证OTP并申请卡片
  Future<void> _verifyAndApply() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入6位验证码')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: 这里应该先验证OTP，如果后端有验证接口的话
      // 目前直接调用申请接口

      // 申请虚拟卡
      final request = CardApplyRequestModel(physical: false);
      final response = await _cardService.applyCard(request);

      if (!mounted) return;

      // 跳转到开卡进度页面
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardApplyProgressScreen(
            taskId: response.taskId,
          ),
        ),
      );
      
      // 如果返回true，表示开卡成功，需要刷新卡片列表
      if (result == true && mounted) {
        // 刷新卡片列表缓存
        try {
          final cardViewModel = Provider.of<CardViewModel>(context, listen: false);
          await cardViewModel.refreshCardList();
        } catch (e) {
          print('Error refreshing card list: $e');
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('申请失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mobile verification",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // WhatsApp Icon
            const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 40),
            const SizedBox(height: 20),

            // Instruction text
            const Text(
              "Enter Whats App OTP we sent to\n+6289666666666666",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // OTP TextField
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                ),
              ),
              child: TextField(
                controller: otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Resend code
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Didn’t get a code? ", style: TextStyle(color: Colors.black54, fontSize: 13)),
                GestureDetector(
                  onTap: () {
                    // TODO: handle resend action
                  },
                  child: const Text(
                    "Send again",
                    style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _verifyAndApply,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isProcessing
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                          ),
                    color: _isProcessing ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Verify",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
