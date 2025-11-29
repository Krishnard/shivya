import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import 'package:shivya_health/pages/policies/cancellation_page.dart';
import 'package:shivya_health/pages/policies/privacy_page.dart';
import 'package:shivya_health/pages/policies/shipping_page.dart';
import 'package:shivya_health/pages/policies/terms_page.dart';  

class SettingsPage extends StatelessWidget {
   const SettingsPage({super.key});

  Widget settingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.green.shade100,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.green.shade800, size: 26),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade900,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Logged out successfully")));
  }

  void _deleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
          "This action cannot be undone. Confirm deletion?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account deleted.")),
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          settingsCard(
            icon: Icons.article_outlined,
            title: "Terms and Conditions",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsPage()),
            ),
          ),
          settingsCard(
            icon: Icons.shield_outlined,
            title: "Privacy Policy",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPage()),
            ),
          ),
          settingsCard(
            icon: Icons.local_shipping_outlined,
            title: "Shipping Policy",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShippingPage()),
            ),
          ),
          settingsCard(
            icon: Icons.cancel_outlined,
            title: "Cancellation Policy",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CancellationPage()),
            ),
          ),

          const SizedBox(height: 18),
          settingsCard(
            icon: Icons.logout,
            title: "Logout",
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _deleteAccountDialog(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
