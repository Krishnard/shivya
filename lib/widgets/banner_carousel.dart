import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: 'Ayurvedic Wellness',
      subtitle: 'Natural care for your daily health',
      imageUrl: 'https://img.freepik.com/free-photo/herbal-medicine.jpg',
    ),
    _BannerData(
      title: 'Immunity Boosters',
      subtitle: 'Support your body’s natural defense',
      imageUrl: 'https://img.freepik.com/free-photo/immunity-concept.jpg',
    ),
    _BannerData(
      title: 'Skin & Hair Care',
      subtitle: 'Herbal care for glowing you',
      imageUrl: 'https://img.freepik.com/free-photo/skin-care.jpg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: primary.withOpacity(0.2)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              banner.subtitle,
                              style:
                                  const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
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
          children: List.generate(_banners.length, (index) {
            final selected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 6,
              width: selected ? 18 : 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: selected ? primary : primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        )
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}
