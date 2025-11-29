import 'package:flutter/material.dart';

class ShippingPage extends StatelessWidget {
  const ShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shipping Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Shipping Policy content coming soon...",
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
