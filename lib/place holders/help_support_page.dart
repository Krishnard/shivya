import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text("Customer Support"),
              subtitle: Text("+91 9876543210"),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text("support@shivyahealthcare.com"),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text("WhatsApp"),
              subtitle: Text("+91 9876543210"),
            ),
          ],
        ),
      ),
    );
  }
}
