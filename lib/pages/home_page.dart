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

const Color kPrimaryGreen = Color(0xFF99FF99); // your light green
const Color kBgTint = Color(0xFFE8F7F3); // soft mint background
const Color kDarkGreen = Color(0xFF0F7A4A); // supportive dark green

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final bool loading = productProvider.isLoading;
    final String? error = productProvider.error;
    List<Product> products = productProvider.products;

    // Fallback if no Shopify products yet
    if (products.isEmpty) {
      products = demoProducts;
    }

    // 🔥 SPECIAL OFFERS spotlight (collection-based)
    // We treat product.category as coming from Shopify productType / collection tag
    final specialOffers = products.where((p) {
      final c = p.category.toLowerCase().trim();
      return c == 'special offers' || c == 'special offer';
    }).toList();

    // Spotlight = Special Offers first, otherwise fallback
    final spotlight = specialOffers.isNotEmpty
        ? specialOffers
        : products.take(5).toList();

    // New Arrivals = everything else (or next few)
    final newArrivals = products
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
              const _HomeTopBar(),
              const SizedBox(height: 12),
              const _PromoBannerCarousel(),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Shop by Category'),
              const SizedBox(height: 10),
              const _CategoryRow(),
              const SizedBox(height: 20),

              const _SectionHeader(
                title: 'In the Spotlight',
                subtitle: 'Unmissable favorites you’ll adore',
              ),
              const SizedBox(height: 8),

              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Could not load products:\n$error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else
                // ⭐ Spotlight Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "In the Spotlight",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                ),
              const SizedBox(height: 10),

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

              const SizedBox(height: 20),
              const _MidPromoBanner(),
              const SizedBox(height: 20),

              const _SectionHeader(
                title: 'New Arrivals',
                subtitle: 'Freshly added wellness picks',
              ),
              const SizedBox(height: 8),
              _NewArrivalsGrid(products: newArrivals),
              const SizedBox(height: 24),

              const _SectionHeader(
                title: 'Healing with Ayurveda',
                subtitle: 'Blogs curated for holistic wellness',
              ),
              const SizedBox(height: 8),
              const _BlogRow(),
              const SizedBox(height: 24),

              const _SectionHeader(title: 'Awards & Recognition'),
              const SizedBox(height: 8),
              const _AwardsRow(),
              const SizedBox(height: 24),

              const _SectionHeader(
                title: 'Featured On',
                subtitle: 'News & media houses talking about us',
              ),
              const SizedBox(height: 8),
              const _NewsTicker(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  Widget searchBarWidget() {
    return Container(
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
              'Search for "face wash"',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(child: searchBarWidget()),

          const SizedBox(width: 10),

          // ❤️ Wishlist with badge
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
              if (wishlist.itemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.pink,
                    child: Text(
                      wishlist.itemCount.toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          // 🛒 Cart with badge
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
              if (cart.itemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-width, auto-scrolling promo banner
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selected = cartProvider.selectedCategory;

    // Business-priority order (Option A) + "All"
    final categories = [
      {'label': 'All', 'icon': Icons.all_inclusive},
      {'label': 'Special Offers', 'icon': Icons.local_offer},
      {'label': 'All Products', 'icon': Icons.grid_view},
      // Future: {'label': 'Best Sellers', 'icon': Icons.trending_up},
      {'label': 'Skin Care', 'icon': Icons.spa},
      {'label': 'Hair Care', 'icon': Icons.face_6},
      {'label': 'Women Health', 'icon': Icons.female},
      {'label': 'Immunity Boosters', 'icon': Icons.health_and_safety},
      {'label': 'Ortho Care', 'icon': Icons.accessibility_new},
      {'label': 'Diabetic Care', 'icon': Icons.bloodtype},
      {'label': 'Gut & Liver', 'icon': Icons.medical_information},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final item = categories[i];
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;

          final bool isSelected =
              selected == label || (selected == 'All' && label == 'All');

          return GestureDetector(
            onTap: () {
              cartProvider.selectCategory(label);
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
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : kDarkGreen,
                    size: 30,
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

class _SpotlightProductCard extends StatelessWidget {
  final Product product;
  const _SpotlightProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),

                /// ❤️ Wishlist button
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        wishlistProvider.isInWishlist(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        wishlistProvider.toggleWishlist(product);
                      },
                    ),
                  ),
                ),

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
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      'FLAT 20% OFF',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            Row(
              children: [
                Text(
                  '₹${product.price}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).addToCart(product);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

/// Grid for "New Arrivals"
class _NewArrivalsGrid extends StatelessWidget {
  final List<Product> products;

  const _NewArrivalsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
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

/// Auto-scrolling small media logos row
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
