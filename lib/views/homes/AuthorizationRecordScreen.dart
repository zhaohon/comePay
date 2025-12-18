import 'package:flutter/material.dart';

class AuthorizationRecordScreen extends StatelessWidget {
  const AuthorizationRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(), // Kosongkan di bawah toolbar
    );
  }
}
