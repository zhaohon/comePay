import 'package:comecomepay/models/carddetail_response_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart'
    show HiveStorageService;
import 'package:comecomepay/views/homes/AuthorizationRecordScreen.dart'
    show AuthorizationRecordScreen;
import 'package:comecomepay/views/homes/CardApplyConfirmScreen.dart'
    show CardApplyConfirmScreen;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/locale_provider.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/services/kyc_service.dart';
import 'package:comecomepay/models/kyc_model.dart';
import 'package:comecomepay/viewmodels/card_trade_viewmodel.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  // Add TextEditingController for verification code
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String? email;
  String? userId;

  late ProfileScreenViewModel _viewModel;
  late CardTradeViewModel _cardTradeViewModel;

  // KYC related state
  bool _isKycLoading = false;
  String? _kycError;
  List<KycModel>? _kycData;
  CarddetailModel? _cardDetailData;
  bool _showBlankScreen = false;
  int? _kycTotal;
  bool _isInitialLoading = true;
  bool _isCardNumberVisible = false;
  bool _isCardLocked = false;
  bool _hasLoadedTrades = false;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileScreenViewModel();
    _cardTradeViewModel = CardTradeViewModel();
    _loadProfile();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreTrades();
      }
    });
  }

  Future<void> _loadMoreTrades() async {
    if (_cardDetailData?.publicToken != null &&
        _cardTradeViewModel.hasMoreData) {
      await _cardTradeViewModel.fetchCardTrades(
        publicToken: _cardDetailData!.publicToken,
        isLoadMore: true,
      );
    }
  }

  Future<void> _loadProfile() async {
    final accessToken = HiveStorageService.getAccessToken();
    if (accessToken != null) {
      final success = await _viewModel.getProfile(accessToken);
      if (success) {
        final profileEmail = _viewModel.profileResponse?.user.email;
        final profileUserId = _viewModel.profileResponse?.user.id.toString();
        setState(() {
          email = profileEmail;
          userId = profileUserId;
        });
        if (email != null) {
          await _loadKycData(email!);
        }

        setState(() {
          _isInitialLoading = false;
        });
      } else {
        // Fallback to auth data if profile fetch fails
        final user = HiveStorageService.getUser();
        setState(() {
          email = user?.email;
          userId = user?.id.toString();
          _isInitialLoading = false;
        });
      }
    } else {
      // Fallback to auth data if no access token
      final user = HiveStorageService.getUser();
      setState(() {
        email = user?.email;
        userId = user?.id.toString();
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadKycData(String kycEmail) async {
    setState(() {
      _isKycLoading = true;
      _kycError = null;
    });

    try {
      final kycService = KycService();
      final result = await kycService.getUserKyc(kycEmail);
      final total = result['total'] as int;
      final kycData = result['list'] as List<KycModel>;

      setState(() {
        _kycData = kycData;
        _kycTotal = total;
        _isKycLoading = false;
        // Don't set _showBlankScreen here, wait for card data
      });
      await _loadCardData(kycData[0].id);
    } catch (e) {
      setState(() {
        _isKycLoading = false;
        _kycError = e.toString();
        // Jika error, tampilan tetap normal
        _showBlankScreen = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadCardData(int kyc_id) async {
    try {
      final cardResponse = await _viewModel.getCardData(kyc_id);

      if (cardResponse != null) {
        setState(() {
          _cardDetailData = cardResponse.data;
          // Set _showBlankScreen only if card data loaded and KYC total >=1
          _showBlankScreen = (_kycTotal != null && _kycTotal! >= 1);
        });

        // Load initial card trades if card data is available and not loaded yet
        if (_cardDetailData?.publicToken != null && !_hasLoadedTrades) {
          setState(() {
            _hasLoadedTrades = true;
          });
          await _cardTradeViewModel.fetchCardTrades(
            publicToken: _cardDetailData!.publicToken,
          );
        }
      } else {
        // If cardResponse is null, try to create card
        if (_kycData != null &&
            _kycData!.isNotEmpty &&
            _viewModel.profileResponse != null) {
          final createSuccess = await _viewModel.createCard(
              _kycData!, _viewModel.profileResponse!);
          if (createSuccess) {
            // If create card succeeds, call _loadCardData again
            await _loadCardData(kyc_id);
            return;
          }
        }
        setState(() {
          _cardDetailData = null;
          _showBlankScreen = false;
        });
      }
    } catch (e) {
      // If in catch block, try to create card
      if (_kycData != null &&
          _kycData!.isNotEmpty &&
          _viewModel.profileResponse != null) {
        try {
          final createSuccess = await _viewModel.createCard(
              _kycData!, _viewModel.profileResponse!);
          if (createSuccess) {
            // If create card succeeds, call _loadCardData again
            await _loadCardData(kyc_id);
            return;
          }
        } catch (createError) {
          // If create card also fails, continue with original error handling
        }
      }
      setState(() {
        _cardDetailData = null;
        _showBlankScreen = false;
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika masih loading awal, tampilkan loading screen
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Jika showBlankScreen true, tampilkan blank screen dengan "hello world"

    if (_showBlankScreen) {
      String selectedCurrency = 'USD'; // default currency

      return StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ===== Saldo + Mata uang + Icon Mata + Dropdown =====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '1.48',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Nama currency di sebelah kiri ikon mata
                      Text(
                        selectedCurrency,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Ikon mata
                      const Icon(
                        Icons.visibility,
                        size: 20,
                        color: Colors.black,
                      ),

                      const SizedBox(width: 4),

                      // Dropdown hanya icon panah, tapi ubah value currency
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          items: <String>['USD', 'IDR', 'EUR', 'SGD']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCurrency = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Estimated Available Balance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== Gambar Kartu =====
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Susunan kolom di kanan atas
                        Positioned(
                          right: 16,
                          top: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // VISA
                              Text(
                                _cardDetailData?.cardScheme ?? 'VISA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Comepay logo (tengah)
                              Image.asset(
                                'assets/which.png',
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 20),

                              // Chip icon (bawah)
                              Image.asset(
                                'assets/chip.png',
                                height: 28,
                                width: 40,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),

                        // Icon besar di tengah kartu
                        if (_isCardLocked)
                          const Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.blueAccent,
                              size: 48,
                            ),
                          ),

                        // Detail kartu di pojok kiri bawah
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nomor kartu dengan ikon mata
                              Row(
                                children: [
                                  Text(
                                    _isCardNumberVisible
                                        ? (_cardDetailData?.cardNo ??
                                            '**** **** **** ****')
                                        : '**** **** **** ****', // Placeholder nomor kartu
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isCardNumberVisible =
                                            !_isCardNumberVisible;
                                      });
                                    },
                                    child: Icon(
                                      _isCardNumberVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Nama
                              Text(
                                _cardDetailData?.memberName ??
                                    'CARDHOLDER NAME', // Placeholder nama
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // CVV dan Expire Date
                              Row(
                                children: [
                                  Text(
                                    'CVV: ${_cardDetailData?.kycId ?? '***'}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Expire Date: ${_cardDetailData?.expiryDate ?? 'MM/YY'}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== Cards =====
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(Icons.info, 'Card Info'),
                      _buildActionCard(Icons.lock, 'Lock Card'),
                      _buildActionCard(Icons.refresh, 'Autorecharge'),
                      _buildActionCard(Icons.add, 'Apply'),
                      _buildActionCard(Icons.update, 'Renew'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ===== Bagian Latest Transactions =====
                  Text(
                    'Latest transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Show loading indicator for trades
                  if (_cardTradeViewModel.busy)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_cardTradeViewModel.hasError)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(_cardTradeViewModel.errorMessage ??
                              'Error loading transactions'),
                          TextButton(
                            onPressed: () {
                              if (_cardDetailData?.publicToken != null) {
                                _cardTradeViewModel.fetchCardTrades(
                                  publicToken: _cardDetailData!.publicToken,
                                );
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_cardTradeViewModel.totalTrades == 0)
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.inbox, size: 48, color: Colors.blueAccent),
                          SizedBox(height: 8),
                          Text('transaction is empty'),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cardTradeViewModel.cardTrades.length +
                          (_cardTradeViewModel.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _cardTradeViewModel.cardTrades.length) {
                          // Loading indicator for pagination
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final displayData =
                            _cardTradeViewModel.tradeDisplayData[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: Icon(
                              displayData['isPositive']
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: displayData['isPositive']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(displayData['description']),
                            subtitle: Text(displayData['date']),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  displayData['amount'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: displayData['isPositive']
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  displayData['type'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final size = MediaQuery.of(context).size;
        final textScale = MediaQuery.of(context).textScaleFactor;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isTablet = constraints.maxWidth >= 600;
                double titleFont = isTablet ? 26 : 20;
                double descFont = isTablet ? 18 : 14;
                double buttonWidthFactor = isTablet ? 0.4 : 0.6;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Loading indicator untuk KYC
                      if (_isKycLoading)
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: CircularProgressIndicator(),
                        ),

                      Text(
                        AppLocalizations.of(context)!.comeComePayCard,
                        style: TextStyle(
                          fontSize: titleFont * textScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.05),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/visa.png",
                          height: size.height * (isTablet ? 0.3 : 0.25),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildChip(AppLocalizations.of(context)!.noMonthlyFee,
                              isTablet),
                          _buildChip(
                              AppLocalizations.of(context)!.lowTransactionFee,
                              isTablet),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),

                      Text(
                        AppLocalizations.of(context)!.spendCryptoLikeFiat,
                        style: TextStyle(
                          fontSize: descFont * textScale,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.08),

                      FractionallySizedBox(
                        widthFactor: buttonWidthFactor,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CardApplyConfirmScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ).copyWith(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                (states) => null, // biar gradient tetap jalan
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF0D47A1)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)!.applyNow,
                                  style: TextStyle(
                                    fontSize: (isTablet ? 18 : 16) * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
      },
    );
  }

  Widget _buildChip(String label, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Card Info') {
          _showSecurityVerificationDialog();
        } else if (label == 'Lock Card') {
          setState(() {
            _isCardLocked = !_isCardLocked;
          });
        } else if (label == 'Autorecharge') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthorizationRecordScreen(),
            ),
          );
        } else if (label == 'Apply') {
          _showApplyDialog();
        } else if (label == 'Renew') {
          _showRenewDialog();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityVerificationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Security verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Choose verification method title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose verification method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Email verification field (non-editable)
              TextFormField(
                initialValue: 'email verification',
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              // Verification title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Verification code text field with get code
              TextFormField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter verification code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: TextButton(
                    onPressed: () {
                      // TODO: Implement get code logic
                    },
                    child: const Text(
                      'Get code',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement confirm logic
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showApplyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kindly Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Centered text
              const Center(
                child: Text(
                  'Please confirm that you have received the physical card before activating it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // White button with shadow
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement action for "Card Not Received, Active later"
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Card Not Received, Active later',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Second title
              const Center(
                child: Text(
                  'Card Received, active immediately',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRenewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Card Replace/Renew',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Report Loss button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Report Loss action
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Report Loss',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Reward news button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Reward news action
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reward news',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height / 1.5,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
