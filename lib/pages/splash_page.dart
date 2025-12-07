import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../main.dart'; // ⬅️ add this at the top with your other imports

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Rotating Ayurveda quotes
  final List<String> _quotes = const [
    'Ancient Ayurveda, crafted for modern life.',
    'Balance your doshas, balance your day.',
    'Herbs, science and care in every drop.',
    'From nature’s wisdom to your daily wellness.',
    'Shivya – Modern Ayurveda you can trust.',
  ];

  int _quoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _startQuotes();
    _startLoading();
  }

  void _startQuotes() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _quotes.length;
      });
    });
  }

  Future<void> _startLoading() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Minimum splash time
    final waitMin = Future.delayed(const Duration(seconds: 2));

    // Preload products (catch errors silently for splash)
    final loadProducts = productProvider.loadProducts().catchError((_) {});

    await Future.wait([waitMin, loadProducts]);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F7F3), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Image.asset(
                  'lib/assets/logo/shivya-Health-care-logo.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Shivya Modern Ayurveda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Rotating quote
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _quotes[_quoteIndex],
                      key: ValueKey(_quotes[_quoteIndex]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Loader + small text
                const CircularProgressIndicator(
                  strokeWidth: 2.3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F7A4A)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Preparing your wellness experience…',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
