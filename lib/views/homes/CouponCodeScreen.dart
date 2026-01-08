import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/coupon_viewmodel.dart';

class CouponCodeScreen extends StatefulWidget {
  const CouponCodeScreen({super.key});

  @override
  State<CouponCodeScreen> createState() => _CouponCodeScreenState();
}

class _CouponCodeScreenState extends State<CouponCodeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _couponController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    setState(() {
      _isButtonPressed = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isButtonPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final paddingHorizontal = screenWidth * 0.05; // 5% horizontal padding
    final paddingVertical = screenHeight * 0.02; // 2% vertical padding
    final fontSizeLabel = screenWidth * 0.035; // adaptive font size for label
    final fontSizeButton =
        screenWidth * 0.04; // adaptive font size for button text

    return ChangeNotifierProvider(
      create: (_) => CouponViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            localizations.couponCodeBinding,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
        body: Consumer<CouponViewModel>(
          builder: (context, viewModel, child) {
            // Show success dialog if coupon claimed
            if (viewModel.claimedCoupon != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(localizations.success),
                      content: Text(viewModel.claimedCoupon!.message),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context)
                                .pop(); // Go back to previous screen
                          },
                          child: Text(localizations.okButton),
                        ),
                      ],
                    );
                  },
                );
              });
            }

            // Show error if any
            if (viewModel.claimError != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.claimError!)),
                );
                viewModel.clearClaimError();
              });
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: paddingVertical),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.couponCode,
                      style: TextStyle(
                          fontSize: fontSizeLabel, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: localizations.enterACouponCode,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: GestureDetector(
                        onTapDown: (_) => _onButtonPressed(),
                        onTapUp: (_) => _onButtonPressed(),
                        onTapCancel: () {
                          setState(() {
                            _isButtonPressed = false;
                          });
                        },
                        child: AnimatedScale(
                          scale: _isButtonPressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: ElevatedButton(
                            onPressed: viewModel.isClaiming
                                ? null
                                : () {
                                    final code = _couponController.text.trim();
                                    if (code.isNotEmpty) {
                                      viewModel.claimCoupon(code);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(localizations
                                                .pleaseEnterACouponCode)),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ).copyWith(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => null,
                              ),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              elevation: WidgetStateProperty.all(0),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF0D47A1)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: viewModel.isClaiming
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        localizations.confirm,
                                        style: TextStyle(
                                            fontSize: fontSizeButton,
                                            fontWeight: FontWeight.w500),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
