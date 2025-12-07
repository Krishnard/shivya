import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../place holders/help_support_page.dart';
import '../pages/setting_page.dart';
import 'package:flutter/foundation.dart';


class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Shopify account URL – handles login, signup, orders, addresses, etc.
  static final Uri _accountUri = Uri.parse(
    'https://shivyahealthcare.com/account',
  );

  Future<void> _openAccount(BuildContext context) async {
    // On web: open in SAME tab so user can use browser Back to return
    if (kIsWeb) {
      final ok = await launchUrl(
        _accountUri,
        webOnlyWindowName: '_self', // replace current tab
      );

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open account page in browser.'),
          ),
        );
      }
      return;
    }

    // On mobile app: open in in-app browser view (Chrome Custom Tab / SFSafariView)
    final ok = await launchUrl(_accountUri, mode: LaunchMode.inAppBrowserView);

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open account page.')),
      );
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade900,
        ),
      ),
    );
  }

  Widget menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: Icon(icon, color: Colors.green.shade800),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(fontSize: 12))
              : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("My Account"),
        elevation: 0,
        backgroundColor: const Color(0xFFE8F7F3),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// PROFILE CARD
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.person,
                      size: 34,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Guest User",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Login / signup with your Shivya account",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),

                        /// LOGIN Button – opens Shopify /account
                        TextButton(
                          onPressed: () => _openAccount(context),
                          child: const Text(
                            "Login / Signup",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// Orders Card – also open Shopify account
            GestureDetector(
              onTap: () => _openAccount(context),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 28,
                      color: Colors.green.shade800,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Orders",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            sectionTitle("YOUR INFORMATION"),

            // Address Book -> open Shopify account page
            menuTile(
              icon: Icons.location_on_outlined,
              title: "Address Book",
              subtitle: "Manage your addresses in Shivya account",
              onTap: () => _openAccount(context),
            ),

            // Contact details -> also let Shopify handle
            menuTile(
              icon: Icons.phone_android,
              title: "Contact Details",
              subtitle: "Update email / phone in your Shivya account",
              onTap: () => _openAccount(context),
            ),

            sectionTitle("OTHER INFORMATION"),

            menuTile(
              icon: Icons.support_agent,
              title: "Help & Support",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportPage()),
              ),
            ),

            menuTile(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),

            menuTile(
              icon: Icons.star_border,
              title: "Rate App",
              onTap: () {
                // TODO: implement store rating
              },
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
