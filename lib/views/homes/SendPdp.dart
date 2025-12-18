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
        title: Text('Send ${token?['symbol'] ?? ''}'),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (_) => SendPdpViewModel(),
        child: Consumer<SendPdpViewModel>(
          builder: (context, vm, child) {
            return _buildBody(context, screenWidth, screenHeight, textScaleFactor, vm);
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
    if (!vm.loading && vm.networks.isEmpty && token != null && token?['symbol'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.fetchNetworks(token!['symbol'].toString());
      });
    }

    return Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.1, // 10% dari tinggi layar
          left: screenWidth * 0.05, // 5% dari lebar layar
          right: screenWidth * 0.05, // 5% dari lebar layar
          bottom: screenHeight * 0.02, // 2% dari tinggi layar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select network',
              style: TextStyle(
                fontSize: 15 * textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
            Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(token?['icon'] ?? Icons.currency_bitcoin,
                      color: token?['color'] ?? Colors.orange,
                      size: 24 * textScaleFactor),
                  SizedBox(width: screenWidth * 0.02), // 2% dari lebar layar
                  Expanded(
                        child: vm.loading
                            ? Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  value: vm.selectedNetwork,
                                  items: vm.networks
                                      .map((n) => DropdownMenuItem<Map<String, dynamic>>(
                                            value: n,
                                            child: Text(
                                              '${n['network_name'] ?? n['network']}',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    vm.selectNetwork(val);
                                    setState(() {
                                      network = val?['network_name'] ?? val?['network']?.toString();
                                    });
                                  },
                                  hint: Text(
                                    '${token?['symbol'] ?? 'BTC'} on ${network ?? 'Network'}',
                                    style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                                    textAlign: TextAlign.center,
                                  ),
                                  style: TextStyle(color: Colors.white, fontSize: 16 * textScaleFactor),
                                ),
                              ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03), // 3% dari tinggi layar
            Text(
              'To',
              style: TextStyle(fontSize: 16 * textScaleFactor),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(screenWidth * 0.9,
                    screenHeight * 0.07), // 90% lebar, 7% tinggi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showAddressInputDialog(context, screenWidth, screenHeight, textScaleFactor);
              },
              child: Text(
                _toAddress?.isNotEmpty == true 
                    ? _toAddress! 
                    : 'Enter receiving address',
                style: TextStyle(
                    color: Colors.white, fontSize: 14 * textScaleFactor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(height: screenHeight * 0.07), // 7% dari tinggi layar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount',
                    style: TextStyle(
                        fontSize: 16 * textScaleFactor,
                        fontWeight: FontWeight.bold)),
                Text(
                    'Available ${token?['symbol'] ?? 'BTC'}: ${token?['balance'] ?? '1.0'} ${token?['symbol'] ?? 'BTC'}',
                    style: TextStyle(
                        fontSize: 16 * textScaleFactor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: screenHeight * 0.015), // 1.5% dari tinggi layar
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // Store the amount for navigation
                setState(() {
                  _amount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    token?['balance'] != null
                        ? (double.tryParse(token!['balance'].toString()) ??
                                0.01)
                            .toStringAsFixed(2)
                        : '0.01',
                    style: TextStyle(fontSize: 16 * textScaleFactor)),
                Text('${token?['symbol'] ?? 'BTC'} || ALL',
                    style: TextStyle(fontSize: 16 * textScaleFactor)),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
            Text(
              'This transfer will not reduce your BRC20 assets',
              style:
                  TextStyle(fontSize: 12 * textScaleFactor, color: Colors.grey),
            ),
            SizedBox(height: screenHeight * 0.07), // 7% dari tinggi layar
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(screenWidth * 0.5,
                      screenHeight * 0.06), // 50% lebar, 6% tinggi
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
                            const SnackBar(content: Text('Please select a receiving address')),
                          );
                          return;
                        }

                        if (_amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Amount must be greater than 0')),
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
                          Navigator.pushNamed(context, '/SendPdpDetail', arguments: {
                            'token': token,
                            'network': network,
                            'amount': _amount,
                          });
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.errorMessage ?? 'Withdrawal failed'),
                            ),
                          );
                        }
                      },
                child: vm.withdrawing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16 * textScaleFactor),
                      ),
              ),
            ),
          ],
        ),
      );
  }

  void _showAddressInputDialog(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    double textScaleFactor,
  ) {
    final addressController = TextEditingController(text: _toAddress ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Enter Receiving Address',
            style: TextStyle(fontSize: 18 * textScaleFactor),
          ),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'Paste or enter wallet address',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                if (addressController.text.isNotEmpty) {
                  setState(() {
                    _toAddress = addressController.text;
                  });
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Please enter an address')),
                  );
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
