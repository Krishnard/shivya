import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../pages/product_detail_page.dart';
import '../pages/cart_page.dart';
import '../pages/wishlist_page.dart';
import '../providers/wishlist_provider.dart';
import '../pages/search_page.dart';

// Shimmer widgets (used during loading)
import '../widgets/shimmer/topbar_shimmer.dart';
import '../widgets/shimmer/banner_shimmer.dart';
import '../widgets/shimmer/category_shimmer.dart';
import '../widgets/shimmer/product_horizontal_shimmer.dart';
import '../widgets/shimmer/simple_row_shimmer.dart';

import '../pages/healing_blogs_pages.dart';
import '../shopify/shopify_service.dart';
import '../pages/splash_page.dart';


const Color kPrimaryGreen = Color(0xFF99FF99); // light green
const Color kBgTint = Color(0xFFE8F7F3); // soft mint background
const Color kDarkGreen = Color(0xFF0F7A4A); // dark green

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Load Shopify products when Home opens ⤵️
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final bool loading = productProvider.isLoading;
    final String? error = productProvider.error;
    final List<Product> products = productProvider.products;

    // 4️⃣ Trending now = random subset of products (changes order)
    final List<Product> trending = () {
      final tmp = List<Product>.from(products);
      tmp.shuffle(Random());
      return tmp.take(10).toList();
    }();

    // 6️⃣ Combos = products whose name looks like combo/offer/pack/kit
    final List<Product> combosProducts = () {
      final candidates = products.where((p) {
        final n = p.name.toLowerCase();
        return n.contains('combo') ||
            n.contains('pack') ||
            n.contains('kit') ||
            n.contains('offer');
      }).toList();

      if (candidates.isNotEmpty) {
        final tmp = List<Product>.from(candidates);
        tmp.shuffle(Random());
        return tmp.take(8).toList();
      }

      // Fallback: random few products
      final tmp = List<Product>.from(products);
      tmp.shuffle(Random());
      return tmp.take(8).toList();
    }();

    return Container(
      color: kBgTint,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ Top bar
              if (loading) const TopBarShimmer() else const _HomeTopBar(),
              const SizedBox(height: 12),

              // 2️⃣ Hero banner carousel
              if (loading)
                const BannerShimmer()
              else
                const _PromoBannerCarousel(),
              const SizedBox(height: 12),

              // 3️⃣ Quick goals (collections focus)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'What are you focusing on today?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              const _GoalChipsRow(),
              const SizedBox(height: 16),

              // 5️⃣ Shop by Category (like screenshot, before products)
              const _SectionHeader(title: 'Shop by Category'),
              const SizedBox(height: 8),
              if (loading) const CategoryShimmer() else const _CategoryGrid(),
              const SizedBox(height: 20),

              // 4️⃣ Trending now (below category grid)
              const _SectionHeader(
                title: 'Trending now',
                subtitle: 'Freshly added wellness picks',
              ),
              const SizedBox(height: 8),
              if (loading && products.isEmpty)
                const ProductHorizontalShimmer()
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Could not load products:\n$error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (trending.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No products to show right now.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              else
                _TrendingGrid(products: trending),
              const SizedBox(height: 20),

              // 6️⃣ Combos (realish combos/offers)
              const _SectionHeader(
                title: 'Combos',
                subtitle: 'Save more with curated packs',
              ),
              const SizedBox(height: 8),
              if (loading && products.isEmpty)
                const ProductHorizontalShimmer()
              else if (combosProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No combos available right now.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              else
                _CombosRow(products: combosProducts),
              const SizedBox(height: 24),

              // 7️⃣ Blogs
              const _SectionHeader(
                title: 'Healing with Ayurveda',
                subtitle: 'Blogs curated for holistic wellness',
              ),
              const SizedBox(height: 8),
              if (loading)
                const SimpleRowShimmer(height: 150)
              else
                const _BlogRow(),
              const SizedBox(height: 24),

              // 8️⃣ Awards
              const _SectionHeader(title: 'Awards & Recognition'),
              const SizedBox(height: 8),
              if (loading)
                const SimpleRowShimmer(height: 80, radius: 40)
              else
                const _AwardsRow(),
              const SizedBox(height: 24),

              // 9️⃣ Featured On / News
              const _SectionHeader(
                title: 'Featured On',
                subtitle: 'News & media houses talking about us',
              ),
              const SizedBox(height: 8),
              if (loading)
                const SimpleRowShimmer(height: 50, width: 120, radius: 30)
              else
                const _NewsTicker(),
              const SizedBox(height: 24),

              // 🔟 Trust strip / footer info
              const _TrustStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Top Bar: Logo + Search + Wishlist + Cart
// ───────────────────────────────────────────────────────────────

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 🔍 Search box → SearchPage
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Search for products...',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ❤️ Wishlist
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistPage()),
                  );
                },
              ),
              if (wishlist.itemCount > 0) _badge(wishlist.itemCount),
            ],
          ),

          // 🛒 Cart
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              if (cart.itemCount > 0) _badge(cart.itemCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(int count) => Positioned(
    right: 4,
    top: 4,
    child: CircleAvatar(
      radius: 8,
      backgroundColor: Colors.red,
      child: Text(
        count.toString(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────
// Hero Promo Banner Carousel
// ───────────────────────────────────────────────────────────────

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel();

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;
  Timer? _timer;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: 'Buy Any 3 @ ₹999',
      subtitle: 'Use code BUY999 • Applicable on select products',
      tag: 'LIMITED TIME',
    ),
    _BannerData(
      title: 'Flat 20% OFF',
      subtitle: 'On all immunity boosters',
      tag: 'EXCLUSIVE',
    ),
    _BannerData(
      title: 'Glow From Within',
      subtitle: 'Handpicked skin care essentials',
      tag: 'RECOMMENDED',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [kPrimaryGreen, kBgTint],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kDarkGreen,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                b.tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              b.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.subtitle,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: navigate to offers / combos collection
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: kDarkGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('SHOP NOW  >>'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.spa,
                            size: 80,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _index == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _index == i ? kDarkGreen : kDarkGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String tag;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}

// ───────────────────────────────────────────────────────────────
// Goal Chips Row – 4–5 random collections/categories
// ───────────────────────────────────────────────────────────────

class _GoalChipsRow extends StatelessWidget {
  const _GoalChipsRow();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    var cats = provider.categories
        .where((c) => c.toLowerCase() != 'all')
        .toList();

    if (cats.isEmpty) {
      // Fallback goals if no categories yet
      cats = [
        'Weight loss',
        'Diabetes care',
        'Joint support',
        'Hair & skin',
        'General wellness',
      ];
    }

    cats.shuffle(Random());
    final display = cats.take(5).toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final label = display[index];
          return ChoiceChip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            selected: false,
            onSelected: (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalProductsPage(goal: label),
                ),
              );
            },
            backgroundColor: Colors.white,
            selectedColor: Colors.green.shade50,
            shape: StadiumBorder(
              side: BorderSide(color: Colors.green.shade600),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: display.length,
      ),
    );
  }
}

/// Shows products related to that goal/collection label
class GoalProductsPage extends StatelessWidget {
  final String goal;

  const GoalProductsPage({super.key, required this.goal});

  // 🔍 Decide how to filter based on the goal label
  // List<String> _keywordsForGoal() {
  //   final g = goal.toLowerCase();

  //   // For these, show ALL products (no filter)
  //   if (g.contains('all product') || g.contains('home page')) {
  //     return [];
  //   }

  //   final cleaned = g.replaceAll('&', ' ');
  //   final parts = cleaned.split(RegExp(r'\s+'));
  //   // ignore very short words like "for", "and"
  //   return parts.where((w) => w.length > 3).toList();
  // }

  List<String> _keywordsForGoal(String goal) {
    final g = goal.toLowerCase();

    // ✅ These should show everything
    if (g.contains('all product') || g.contains('home page')) {
      return []; // no filter = show all products
    }

    final cleaned = g.replaceAll('&', ' ');
    final parts = cleaned.split(RegExp(r'\s+'));
    final keywords = parts
        .where((w) => w.length > 3)
        .toList(); // ignore tiny words
    return keywords;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products;

    final keywords = _keywordsForGoal(goal);

    final filtered = products.where((p) {
      if (keywords.isEmpty) return true; // show ALL products
      final name = p.name.toLowerCase();
      return keywords.any((kw) => name.contains(kw));
    }).toList();

    final isWide = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isWide ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.4,
      ),
      body: Container(
        color: kBgTint,
        child: filtered.isEmpty
            ? const Center(
                child: Text(
                  'No products found for this focus.\nTry exploring other categories.',
                  textAlign: TextAlign.center,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (_, i) {
                    return _SpotlightProductCard(product: filtered[i]);
                  },
                ),
              ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Section Header
// ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Category Grid (4×N cards like screenshot, vertical scroll)
// ───────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  IconData _iconForCategory(String name) {
    final key = name.toLowerCase();
    if (key.contains('home')) return Icons.home_outlined;
    if (key.contains('all product')) return Icons.grid_view_rounded;
    if (key == 'all') return Icons.all_inclusive;
    if (key.contains('special')) return Icons.local_offer;
    if (key.contains('skin')) return Icons.spa;
    if (key.contains('hair')) return Icons.face_6;
    if (key.contains('women')) return Icons.female;
    if (key.contains('immunity')) return Icons.health_and_safety;
    if (key.contains('ortho')) return Icons.accessibility_new;
    if (key.contains('diabetic') || key.contains('sugar')) {
      return Icons.bloodtype;
    }
    if (key.contains('gut') || key.contains('liver')) {
      return Icons.medical_information;
    }
    return Icons.spa_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Base categories from provider, remove duplicates / generic ones
    final List<String> baseCats = productProvider.categories
        .map((c) => c.trim())
        .where((c) {
          final lc = c.toLowerCase();
          return lc != 'all' && lc != 'home page' && lc != 'all products';
        })
        .toList();

    if (productProvider.isLoading && baseCats.length <= 1) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔒 Pin these 2 at the beginning (only once)
    final List<String> categories = ['Home page', 'All products', ...baseCats];

    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Categories will appear here when products are loaded.',
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    const int perPage = 8; // 4 columns × 2 rows
    final int pageCount = (categories.length / perPage).ceil();
    final double pageWidth =
        MediaQuery.of(context).size.width - 32; // 16 + 16 padding

    return SizedBox(
      // enough height for 2 rows of cards => avoids RenderFlex overflow
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          final start = pageIndex * perPage;
          final end = (start + perPage) > categories.length
              ? categories.length
              : (start + perPage);
          final slice = categories.sublist(start, end);

          return SizedBox(
            width: pageWidth,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slice.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 columns
                mainAxisSpacing: 12, // equal vertical gap
                crossAxisSpacing: 12, // equal horizontal gap
                childAspectRatio: 0.6, // a bit taller -> no overflow
              ),
              itemBuilder: (context, i) {
                final label = slice[i];
                final icon = _iconForCategory(label);

                return GestureDetector(
                  onTap: () {
                    if (label == 'Home page' || label == 'All products') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const GoalProductsPage(goal: 'All products'),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GoalProductsPage(goal: label),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE3F7FF), Color(0xFFFFFFFF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Center icon
                          Align(
                            alignment: Alignment.center,
                            child: Icon(icon, size: 30, color: Colors.black26),
                          ),
                          // Bottom label + arrow
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical:
                                    3, // slightly smaller to avoid overflow
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.45),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Trending Grid (uses random subset)
// ───────────────────────────────────────────────────────────────

class _TrendingGrid extends StatelessWidget {
  final List<Product> products;
  const _TrendingGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No products to show right now.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isWide ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.65,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final p = products[i];
          return _SpotlightProductCard(product: p);
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Product Card (reused everywhere)
// ───────────────────────────────────────────────────────────────

class _SpotlightProductCard extends StatelessWidget {
  final Product product;
  const _SpotlightProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final cs = Theme.of(context).colorScheme;

    final bool hasCompare =
        product.compareAtPrice != null &&
        product.compareAtPrice! > product.price;
    final int discountPercent = _calculateDiscount(product);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),

                // ❤️ Wishlist
                Positioned(
                  right: 6,
                  top: 6,
                  child: GestureDetector(
                    onTap: () => wishlist.toggleWishlist(product),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(
                        wishlist.isInWishlist(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),

                // 🏷 Offer badge
                if (hasCompare && discountPercent > 0)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                if (hasCompare)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '₹${product.compareAtPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    cart.addToCart(product);
                    if (wishlist.isInWishlist(product)) {
                      wishlist.toggleWishlist(product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        duration: const Duration(milliseconds: 700),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: kDarkGreen,
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDiscount(Product p) {
    if (p.compareAtPrice == null || p.compareAtPrice! <= p.price) return 0;
    final d = ((p.compareAtPrice! - p.price) / p.compareAtPrice!) * 100;
    return d.round();
  }
}

// ───────────────────────────────────────────────────────────────
// Combos Row (uses combo/offer products)
// ───────────────────────────────────────────────────────────────

class _CombosRow extends StatelessWidget {
  final List<Product> products;

  const _CombosRow({required this.products});

  @override
  Widget build(BuildContext context) {
    final combos = products.take(8).toList();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final p = combos[i];
          return SizedBox(width: 170, child: _SpotlightProductCard(product: p));
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: combos.length,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Blog Row (Shopify Storefront articles)
// ───────────────────────────────────────────────────────────────

const List<String> _healingArticleHandles = [
  'tips-for-fast-weight-loss-in-winter-without-exercise',
  'padma-shri-romalo-ram-ji-praises-shivya-ayurveda-s-vision-for-natural-wellness',
  'beyond-medicine-how-ancient-ayurvedic-remedies-for-diabetes-offer-modern-blood-sugar-balance',
];

class _BlogRow extends StatelessWidget {
  const _BlogRow();

  @override
  Widget build(BuildContext context) {
    if (_healingArticleHandles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _healingArticleHandles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final handle = _healingArticleHandles[i];

          Widget page;
          if (i == 0) {
            page = const BlogWinterWeightLossPage();
          } else if (i == 1) {
            page = const BlogRomaloRamPage();
          } else {
            page = const BlogAyurvedaDiabetesPage();
          }

          return SizedBox(
            width: 280,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
              child: _HealingBlogCard(articleHandle: handle),
            ),
          );
        },
      ),
    );
  }
}

class _HealingBlogCard extends StatelessWidget {
  final String articleHandle;

  const _HealingBlogCard({required this.articleHandle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<ShopifyArticle>(
      future: ShopifyService().fetchArticleByHandle(
        blogHandle: 'healing-with-ayurveda',
        articleHandle: articleHandle,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildSkeletonCard(theme);
        }

        if (snap.hasError || !snap.hasData) {
          return _buildErrorCard(theme);
        }

        final article = snap.data!;

        final subtitle =
            (article.subtitle != null && article.subtitle!.trim().isNotEmpty)
            ? article.subtitle!.trim()
            : 'Healing with Ayurveda';

        final shortTextSource =
            (article.intro != null && article.intro!.trim().isNotEmpty)
            ? article.intro!
            : article.content;

        final shortText = shortTextSource.replaceAll('\n', ' ').trim();

        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.4),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child:
                        article.imageUrl != null && article.imageUrl!.isNotEmpty
                        ? Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kDarkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text(
                            'Read more',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kDarkGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: kDarkGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSkeletonCard(ThemeData theme) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey.shade100,
        ),
        child: Column(
          children: [
            Container(height: 170, color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 160,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 120,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Unable to load blog',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Awards Row
// ───────────────────────────────────────────────────────────────

class _AwardsRow extends StatelessWidget {
  const _AwardsRow();

  @override
  Widget build(BuildContext context) {
    final awards = [
      'Best Ayurvedic Brand 2024',
      'Customer Choice Award',
      'Trusted Wellness Partner',
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: kPrimaryGreen.withOpacity(0.7)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: kDarkGreen),
              const SizedBox(width: 8),
              Text(awards[i], style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: awards.length,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// News Ticker (Featured On)
// ───────────────────────────────────────────────────────────────

class _NewsTicker extends StatefulWidget {
  const _NewsTicker();

  @override
  State<_NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<_NewsTicker> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;

  final List<String> _channels = const [
    'NDTV',
    'ABP News',
    'Times Now',
    'India Today',
    'CNBC Awaaz',
    'Zee News',
  ];

  double _position = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_controller.hasClients) return;
      _position += 1.5;
      if (_position >= _controller.position.maxScrollExtent) {
        _position = 0;
      }
      _controller.jumpTo(_position);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final name = _channels[i % _channels.length];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  color: Colors.black.withOpacity(0.06),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.tv, size: 18, color: kDarkGreen),
                const SizedBox(width: 6),
                Text(name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _channels.length * 3,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Trust Strip / Footer info
// ───────────────────────────────────────────────────────────────

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final items = const [
      (icon: Icons.verified_outlined, text: 'Lab-tested Ayurvedic formulas'),
      (icon: Icons.local_shipping_outlined, text: 'Free shipping above ₹999'),
      (
        icon: Icons.currency_rupee_outlined,
        text: 'COD available on most pincodes',
      ),
      (icon: Icons.flag_outlined, text: 'Made in India'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why people trust Shivya',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(i.icon, size: 18, color: kDarkGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        i.text,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
