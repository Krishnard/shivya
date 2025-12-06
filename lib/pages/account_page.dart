import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../place holders/address_page.dart';
import '../place holders/help_support_page.dart';
import '../place holders/order_page.dart';
import '../pages/setting_page.dart';
import '../pages/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
    final auth = Provider.of<AuthProvider>(context, listen: true);

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
                    child: Icon(Icons.person, size: 34, color: Colors.green.shade800),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isLoggedIn ? auth.userName ?? "User" : "Guest User",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          auth.isLoggedIn
                              ? (auth.userEmail ?? auth.phoneNumber ?? "Profile Updated")
                              : "Sign in to continue",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),

                        /// LOGIN Button if Guest
                        if (!auth.isLoggedIn)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
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

            /// Orders Card
            GestureDetector(
              onTap: () {
                if (!auth.isLoggedIn) return _askLogin(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
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
                    Icon(Icons.shopping_bag_outlined,
                        size: 28, color: Colors.green.shade800),
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

            menuTile(
              icon: Icons.location_on_outlined,
              title: "Address Book",
              subtitle: auth.isLoggedIn
                  ? "Edit & Add new addresses"
                  : "Login required",
              onTap: () {
                if (!auth.isLoggedIn) return _askLogin(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressPage()),
                );
              },
            ),

            if (auth.isLoggedIn)
              menuTile(
                icon: Icons.phone_android,
                title: "Contact Details",
                subtitle: auth.userEmail ?? auth.phoneNumber ?? "",
                onTap: () {},
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
              onTap: () {},
            ),

            if (auth.isLoggedIn)
              menuTile(
                icon: Icons.logout,
                title: "Logout",
                onTap: () => auth.logout(),
              ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _askLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login to access this feature")),
    );
  }
}
