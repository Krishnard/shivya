import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Privacy Policy content coming soon...",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
