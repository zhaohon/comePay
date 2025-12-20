import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/send_pdp_viewmodel.dart';

class SendPdp extends StatefulWidget {
  const SendPdp({super.key});

  @override
  _SendPdpState createState() => _SendPdpState();
}

class _SendPdpState extends State<SendPdp> {
  Map<String, dynamic>? token;
  String? network;
  double _amount = 1.5; // Default amount
  String? _toAddress; // Address to be filled by user
  // Networks are managed by SendPdpViewModel (MVVM)
  final int _hardcodedUserId = 42; // Hardcoded user_id for now

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        token = args['token'];
        network = args['network'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Send'),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (_) => SendPdpViewModel(),
        child: Consumer<SendPdpViewModel>(
          builder: (context, vm, child) {
            return _buildBody(
                context, screenWidth, screenHeight, textScaleFactor, vm);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    double textScaleFactor,
    SendPdpViewModel vm,
  ) {
    // Trigger fetch when provider is ready and we have a token symbol.
    if (!vm.loading &&
        vm.networks.isEmpty &&
        token != null &&
        token?['symbol'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.fetchNetworks(token!['symbol'].toString());
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select token and network section
          const Text(
            'Select token and network',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildNetworkCard(vm, textScaleFactor),
          const SizedBox(height: 24),

          // To section
          const Text(
            'To',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildAddressCard(textScaleFactor),
          const SizedBox(height: 24),

          // Amount section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Available: ${token?['balance'] ?? '0.0'} ${token?['symbol'] ?? 'BTC'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAmountCard(textScaleFactor),
          const SizedBox(height: 12),

          // BRC20 info text
          const Text(
            'This transfer will not reduce your BRC20 assets',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C7FFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              onPressed: vm.withdrawing
                  ? null
                  : () async {
                      // Validate required fields
                      if (token == null || token?['symbol'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token not found')),
                        );
                        return;
                      }

                      if (_toAddress == null || _toAddress!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select a receiving address')),
                        );
                        return;
                      }

                      if (_amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Amount must be greater than 0')),
                        );
                        return;
                      }

                      // Call withdraw API
                      final success = await vm.withdrawRequest(
                        coinId: 1, // TODO: Get from token data
                        networkId: vm.selectedNetwork?['network_id'] ?? 1,
                        toAddress: _toAddress!,
                        amount: _amount,
                        userId: _hardcodedUserId,
                      );

                      if (success) {
                        // Navigate to SendPdpDetail on success
                        Navigator.pushNamed(context, '/SendPdpDetail',
                            arguments: {
                              'token': token,
                              'network': network,
                              'amount': _amount,
                            });
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(vm.errorMessage ?? 'Withdrawal failed'),
                          ),
                        );
                      }
                    },
              child: vm.withdrawing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(SendPdpViewModel vm, double textScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Token icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              token?['icon'] ?? Icons.currency_bitcoin,
              color: const Color(0xFFFFA726),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token?['symbol'] ?? 'BTC',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Network: ${vm.selectedNetwork?['network_name'] ?? network ?? 'Bitcoin'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (vm.loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C7FFF)),
              ),
            )
          else if (vm.networks.isNotEmpty)
            PopupMenuButton<Map<String, dynamic>>(
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              onSelected: (val) {
                vm.selectNetwork(val);
                setState(() {
                  network = val['network_name'] ?? val['network']?.toString();
                });
              },
              itemBuilder: (context) {
                return vm.networks.map((n) {
                  return PopupMenuItem<Map<String, dynamic>>(
                    value: n,
                    child: Text(n['network_name'] ?? n['network'] ?? ''),
                  );
                }).toList();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(double textScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _toAddress = value;
          });
        },
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'receiving address',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black38,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.black38,
              size: 20,
            ),
            onPressed: () {
              // TODO: Implement QR code scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR scanner not implemented yet')),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(double textScaleFactor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amount = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${token?['symbol'] ?? 'BTC'} | ',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Set to max available balance
                  final balance =
                      double.tryParse(token?['balance']?.toString() ?? '0') ??
                          0.0;
                  setState(() {
                    _amount = balance;
                  });
                },
                child: const Text(
                  'All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4C7FFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
