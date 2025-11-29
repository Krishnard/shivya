import 'package:flutter/material.dart';

class CancellationPage extends StatelessWidget {
  const CancellationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cancellation Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Cancellation & Refund Policy content coming soon...",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
