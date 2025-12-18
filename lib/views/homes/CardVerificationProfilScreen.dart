import 'package:flutter/material.dart';


class CardVerificationProfilScreen extends StatefulWidget {
  const CardVerificationProfilScreen({super.key});

  @override
  State<CardVerificationProfilScreen> createState() => _CardVerificationProfilScreenState();
}

class _CardVerificationProfilScreenState extends State<CardVerificationProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text('Verification', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'KASINO',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Last name',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'SLAMET',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Cardholder Name',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'KASINO SLAMET',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Document Type',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'ID card',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Document Number',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '56382920234890289023890',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Date of Birth',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '1945-03-09',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Note: The above Authentication information is consistent with certificate information uploaded in the next step, otherwise the authentication fails',
              style: TextStyle(color: Colors.black54, fontSize: 12.0),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/CardApplyCardScreen');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}