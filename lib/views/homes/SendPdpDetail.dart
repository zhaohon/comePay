import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/send_pdp_detail_viewmodel.dart';

class SendPdpDetail extends StatefulWidget {
  const SendPdpDetail({super.key});

  @override
  _SendPdpDetailState createState() => _SendPdpDetailState();
}

class _SendPdpDetailState extends State<SendPdpDetail> {
  late SendPdpDetailViewModel _viewModel;
  Map<String, dynamic>? _args;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SendPdpDetailViewModel>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmAndSend() async {
    if (_args == null) return;

    final token = _args!['token'] as Map<String, dynamic>?;
    final network = _args!['network'] as String?;
    final amount = _args!['amount'] as double?;

    if (token == null || network == null || amount == null) return;

    await _viewModel.previewTransaction(
      toAddress:
          '0x1234567890abcdef1234567890abcdef12345678', // Placeholder, should come from args or input
      tokenSymbol: token['symbol'] ?? 'ETH',
      network: network,
      amount: amount,
    );

    if (_viewModel.errorMessage == null) {
      Navigator.pushNamed(context, '/SendPdpDetailOtp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
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
        title: Text('Send', style: TextStyle(fontSize: 18 * textScaleFactor)),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            EdgeInsets.all(screenWidth * 0.04), // Padding 4% dari lebar layar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment',
              style: TextStyle(
                fontSize: 16 * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: screenHeight *
                      0.01), // Margin vertikal 1% dari tinggi layar
              padding: EdgeInsets.all(
                  screenWidth * 0.02), // Padding 2% dari lebar layar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                textAlign: TextAlign.center,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Text for the recipient (Optional)',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12 * textScaleFactor,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
            Text(
              'Detail Transaction',
              style: TextStyle(
                fontSize: 16 * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% dari tinggi layar
            SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(
                      screenWidth * 0.04), // Padding 4% dari lebar layar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<SendPdpDetailViewModel>(
                        builder: (context, viewModel, child) {
                          final preview = viewModel.previewResponse?.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Recipient',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                  Text(
                                      preview?.toAddress.substring(0, 10) ??
                                          '401e72588b...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                ],
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.01), // 1% dari tinggi layar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sum',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                  Text(
                                      '${preview?.amount ?? 0.02} ${preview?.tokenSymbol ?? 'BTC'}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                ],
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.01), // 1% dari tinggi layar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gas fee',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                  Text(
                                      '${preview?.fee ?? 0.00051003} ${preview?.tokenSymbol ?? 'BTC'}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * textScaleFactor)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(), // Mengisi ruang kosong hingga bagian bawah
            Center(
              child: Consumer<SendPdpDetailViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(screenWidth * 0.9,
                          screenHeight * 0.07), // 90% lebar, 7% tinggi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: viewModel.busy ? null : _handleConfirmAndSend,
                    child: viewModel.busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Confirm and Send',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * textScaleFactor),
                          ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% dari tinggi layar
          ],
        ),
      ),
    );
  }
}
