import 'package:flutter/material.dart';

class CardApplyCardScreen extends StatefulWidget {
  const CardApplyCardScreen({super.key});

  @override
  State<CardApplyCardScreen> createState() => _CardApplyCardScreenState();
}

class _CardApplyCardScreenState extends State<CardApplyCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('Apply Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text('Card name'),
                subtitle: Text('Come Come Pay Card'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Card organization'),
                subtitle: Text('VISA'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Card fee'),
                subtitle: Text('5 USD'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Coupon'),
                subtitle: Text('Available'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle coupon selection
                },
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit action
                  Navigator.pushNamed(context, '/CardCompliteApplyScreen');
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Replace 'primary' with 'backgroundColor'
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}