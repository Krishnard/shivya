import 'dart:async';
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

// Optional shimmer widgets (used during loading)
import '../widgets/shimmer/topbar_shimmer.dart';
import '../widgets/shimmer/banner_shimmer.dart';
import '../widgets/shimmer/category_shimmer.dart';
import '../widgets/shimmer/product_horizontal_shimmer.dart';
import '../widgets/shimmer/simple_row_shimmer.dart';

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

    // 🔥 Spotlight = products where metafield custom.spotlight == true
    // Spotlight section - simple version: just take first few products
    final List<Product> spotlight = products.take(5).toList();

    // New arrivals = everything not in spotlight (limit 10)
    final List<Product> newArrivals = products
        .where((p) => !spotlight.contains(p))
        .take(10)
        .toList();

    return Container(
      color: kBgTint,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────── Top Bar (Search + Wishlist + Cart)
              if (loading) const TopBarShimmer() else const _HomeTopBar(),
              const SizedBox(height: 12),

              // ───────────────── Banner
              if (loading)
                const BannerShimmer()
              else
                const _PromoBannerCarousel(),
              const SizedBox(height: 16),

              // ───────────────── Categories
              const _SectionHeader(title: 'Shop by Category'),
              const SizedBox(height: 10),
              if (loading) const CategoryShimmer() else const _CategoryRow(),
              const SizedBox(height: 20),

              // ───────────────── Spotlight Section
              const _SectionHeader(
                title: 'In the Spotlight',
                subtitle: 'Unmissable favorites you’ll adore',
              ),
              const SizedBox(height: 8),

              if (loading)
                const ProductHorizontalShimmer()
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Could not load products:\n$error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (spotlight.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No spotlight products available right now.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              else
                SizedBox(
                  height: 265,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) =>
                        _SpotlightProductCard(product: spotlight[i]),
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemCount: spotlight.length,
                  ),
                ),

              const SizedBox(height: 20),

              // ───────────────── Mid Promo Banner
              const _MidPromoBanner(),
              const SizedBox(height: 20),

              // ───────────────── New Arrivals
              const _SectionHeader(
                title: 'New Arrivals',
                subtitle: 'Freshly added wellness picks',
              ),
              const SizedBox(height: 8),

              if (loading && products.isEmpty)
                const ProductHorizontalShimmer()
              else if (!loading && newArrivals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No new arrivals available at the moment.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              else
                _NewArrivalsGrid(products: newArrivals),

              const SizedBox(height: 24),

              // ───────────────── Blogs
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

              // ───────────────── Awards
              const _SectionHeader(title: 'Awards & Recognition'),
              const SizedBox(height: 8),
              if (loading)
                const SimpleRowShimmer(height: 80, radius: 40)
              else
                const _AwardsRow(),
              const SizedBox(height: 24),

              // ───────────────── News / Featured On
              const _SectionHeader(
                title: 'Featured On',
                subtitle: 'News & media houses talking about us',
              ),
              const SizedBox(height: 8),
              if (loading)
                const SimpleRowShimmer(height: 50, width: 120, radius: 30)
              else
                const _NewsTicker(),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Top Bar: Search + Wishlist + Cart
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
                height: 44,
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
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search for products...',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
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
// Promo Banner Carousel
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
                              onPressed: () {},
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
          if (title == 'In the Spotlight')
            TextButton(onPressed: () {}, child: const Text('See All')),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Category Row
// ───────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  IconData _iconForCategory(String name) {
    final key = name.toLowerCase();
    if (key == 'all') return Icons.all_inclusive;
    if (key.contains('special')) return Icons.local_offer;
    if (key.contains('skin')) return Icons.spa;
    if (key.contains('hair')) return Icons.face_6;
    if (key.contains('women')) return Icons.female;
    if (key.contains('immunity')) return Icons.health_and_safety;
    if (key.contains('ortho')) return Icons.accessibility_new;
    if (key.contains('diabetic')) return Icons.bloodtype;
    if (key.contains('gut') || key.contains('liver')) {
      return Icons.medical_information;
    }
    return Icons.spa_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final selected = productProvider.selectedCategory;
    final categories = productProvider.categories;

    if (productProvider.isLoading && categories.length <= 1) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final label = categories[i];
          final icon = _iconForCategory(label);
          final bool isSelected = selected == label;

          return GestureDetector(
            onTap: () {
              productProvider.filterByCategory(label);
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? kDarkGreen : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : kDarkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 80,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? kDarkGreen : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: categories.length,
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Spotlight Product Card
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
        width: 170,
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
// Mid Promo Banner
// ───────────────────────────────────────────────────────────────

class _MidPromoBanner extends StatelessWidget {
  const _MidPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPrimaryGreen.withOpacity(0.7)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: const [
            Icon(Icons.local_offer, color: kDarkGreen),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'FLAT 30% OFF on combos • Auto-applied at checkout',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// New Arrivals Grid (reuses same card style as spotlight)
// ───────────────────────────────────────────────────────────────

class _NewArrivalsGrid extends StatelessWidget {
  final List<Product> products;
  const _NewArrivalsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No new arrivals to show right now.',
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
// Blog Row
// ───────────────────────────────────────────────────────────────

class _BlogRow extends StatelessWidget {
  const _BlogRow();

  @override
  Widget build(BuildContext context) {
    final blogs = [
      'Healing with Ayurveda: Daily Rituals',
      'Balancing Doshas with Food',
      'Detox the Natural Way',
    ];

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          return Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kPrimaryGreen.withOpacity(0.4),
                  ),
                  child: const Center(child: Icon(Icons.menu_book_outlined)),
                ),
                const SizedBox(height: 8),
                Text(
                  blogs[i],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Read more ›',
                  style: TextStyle(fontSize: 11, color: kDarkGreen),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: blogs.length,
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
// News Ticker
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
