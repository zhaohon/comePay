import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:comecomepay/viewmodels/kyc_viewmodel.dart';

class Profilkycscreen extends StatelessWidget {
  const Profilkycscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => KycViewModel()..fetchKycData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'KYC',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<KycViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.busy) {
              return Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            final kycData = viewModel.kycData.isNotEmpty ? viewModel.kycData[0] : null;
            final isPassed = kycData?.status == 'passed';

            return RefreshIndicator(
              onRefresh: viewModel.refreshKycData,
              child: viewModel.kycData.isEmpty
                  ? Center(child: Text('No KYC data available'))
                  : ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      itemCount: viewModel.kycData.length,
                      itemBuilder: (context, index) {
                        final kycData = viewModel.kycData[index];
                        final isPassed = kycData.status == 'passed';
                        return Card(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4.0,
                          margin: EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white, // Putih di bawah
                                  Color.fromRGBO(0, 122, 255, 0.1), // Biru muda di atas
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Tinggi card menyesuaikan konten
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level 1 Verification',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Feature and Permissions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  Text(
                                    'Apply card',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Complete authentication',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'User: ${kycData.firstNameEn} ${kycData.lastNameEn}\nEmail: ${kycData.email}\nPhone: ${kycData.phone}\nAddress: ${kycData.address}\nDocument authentication verification: ${isPassed ? 'Passed' : 'Pending'}\nFace recognition: ${isPassed ? 'Passed' : 'Pending'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: isPassed ? Color(0xFF4CAF50).withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPassed ? Icons.check : Icons.hourglass_empty,
                                          color: isPassed ? Color(0xFF4CAF50) : Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
