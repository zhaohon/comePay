import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/services/card_service.dart';

class QueryPinScreen extends StatefulWidget {
  final String publicToken;
  final String email;

  const QueryPinScreen({
    super.key,
    required this.publicToken,
    required this.email,
  });

  @override
  State<QueryPinScreen> createState() => _QueryPinScreenState();
}

class _QueryPinScreenState extends State<QueryPinScreen> {
  final TextEditingController _otpController = TextEditingController();
  final CardService _cardService = CardService();
  bool _isLoading = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
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

  Future<void> _onQueryPressed() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.pleaseEnterVerificationCode)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟验证码校验成功
      await Future.delayed(const Duration(milliseconds: 800));

      final pin = await _cardService.getPin(widget.publicToken);

      if (mounted) {
        _showPinSuccessBottomSheet(pin);
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

  void _showPinSuccessBottomSheet(String pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.cardPinIs,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D1E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFFC4C4C4)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.keepPinSafeTip,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final maskedEmail = _maskEmail(widget.email);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: Color(0xFF1A1D1E), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.queryPinCode,
          style: const TextStyle(
            color: Color(0xFF1A1D1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.securityVerification,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1E),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.emailVerificationCode,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.35),
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF1A1D1E)),
                        decoration: InputDecoration(
                          hintText: localizations.pleaseEnterVerificationCode,
                          hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: _countdown > 0 ? null : _startTimer,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _countdown > 0
                              ? "${localizations.resendCode} $_countdown 秒"
                              : localizations.resendCode,
                          style: TextStyle(
                            color: _countdown > 0
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.emailCodeSentToHint(maskedEmail),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1D1E),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onQueryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1129),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          localizations.query,
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
