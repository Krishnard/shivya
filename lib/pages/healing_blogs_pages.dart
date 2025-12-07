import 'package:flutter/material.dart';
import '../shopify/shopify_service.dart'; // path may differ in your project

class BlogWinterWeightLossPage extends StatefulWidget {
  const BlogWinterWeightLossPage({super.key});

  @override
  State<BlogWinterWeightLossPage> createState() =>
      _BlogWinterWeightLossPageState();
}

class _BlogWinterWeightLossPageState extends State<BlogWinterWeightLossPage> {
  late Future<ShopifyArticle> _future;

  @override
  void initState() {
    super.initState();
    _future = ShopifyService().fetchArticleByHandle(
      blogHandle: 'healing-with-ayurveda',
      articleHandle: 'tips-for-fast-weight-loss-in-winter-without-exercise',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<ShopifyArticle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load article.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final article = snap.data!;
          return _ArticleLayout(
            article: article,
            fallbackImageAsset: 'assets/images/healing_weight_loss.png',
            chipText: 'Healing with Ayurveda · Weight Loss',
          );
        },
      ),
    );
  }
}

class BlogRomaloRamPage extends StatefulWidget {
  const BlogRomaloRamPage({super.key});

  @override
  State<BlogRomaloRamPage> createState() => _BlogRomaloRamPageState();
}

class _BlogRomaloRamPageState extends State<BlogRomaloRamPage> {
  late Future<ShopifyArticle> _future;

  @override
  void initState() {
    super.initState();
    _future = ShopifyService().fetchArticleByHandle(
      blogHandle: 'healing-with-ayurveda',
      articleHandle:
          'padma-shri-romalo-ram-ji-praises-shivya-ayurveda-s-vision-for-natural-wellness',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<ShopifyArticle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load article.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final article = snap.data!;
          return _ArticleLayout(
            article: article,
            fallbackImageAsset: 'assets/images/healing_romalo_ram.png',
            chipText: 'Healing with Ayurveda · Lifestyle',
          );
        },
      ),
    );
  }
}

class BlogAyurvedaDiabetesPage extends StatefulWidget {
  const BlogAyurvedaDiabetesPage({super.key});

  @override
  State<BlogAyurvedaDiabetesPage> createState() =>
      _BlogAyurvedaDiabetesPageState();
}

class _BlogAyurvedaDiabetesPageState extends State<BlogAyurvedaDiabetesPage> {
  late Future<ShopifyArticle> _future;

  @override
  void initState() {
    super.initState();
    _future = ShopifyService().fetchArticleByHandle(
      blogHandle: 'healing-with-ayurveda',
      articleHandle:
          'beyond-medicine-how-ancient-ayurvedic-remedies-for-diabetes-offer-modern-blood-sugar-balance',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<ShopifyArticle>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load article.\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final article = snap.data!;
          return _ArticleLayout(
            article: article,
            fallbackImageAsset: 'assets/images/healing_shivaram.png',
            chipText: 'Healing with Ayurveda · Diabetes Care',
          );
        },
      ),
    );
  }
}

// ───────────────── Shared layout ─────────────────

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: const Text(
      'Healing with Ayurveda',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0.4,
  );
}

class _ArticleLayout extends StatelessWidget {
  final ShopifyArticle article;
  final String fallbackImageAsset;
  final String chipText;

  const _ArticleLayout({
    required this.article,
    required this.fallbackImageAsset,
    required this.chipText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Split plain content into paragraphs for fallback / bottom content
    final paragraphs = article.content
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    // Prefer metafield intro, otherwise first paragraph from content
    final String intro =
        (article.intro != null && article.intro!.trim().isNotEmpty)
        ? article.intro!.trim()
        : (paragraphs.isNotEmpty ? paragraphs.first : '');

    // Prefer metafield side section text, otherwise some paras from content
    final String sideText =
        (article.sideSectionText != null &&
            article.sideSectionText!.trim().isNotEmpty)
        ? article.sideSectionText!.trim()
        : (paragraphs.length > 2
              ? paragraphs.sublist(1, 3).join('\n\n')
              : paragraphs.skip(1).join('\n\n'));

    // Subtitle: use metafield if set, else nothing (or you could fall back)
    final String? subtitle =
        (article.subtitle != null && article.subtitle!.trim().isNotEmpty)
        ? article.subtitle!.trim()
        : null;

    // Side section title: use metafield, else a default
    final String sideTitle =
        (article.sideSectionTitle != null &&
            article.sideSectionTitle!.trim().isNotEmpty)
        ? article.sideSectionTitle!.trim()
        : 'Highlights';

    // For bottom content, we simply show the remaining paragraphs.
    // There might be some overlap with intro/sideText depending on how
    // you write metafields, but it's safe and shows full article.
    final List<String> bottomParas = paragraphs;

    return Container(
      color: const Color(0xFFF4FFF7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: Text(
                chipText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // title from Shopify
            Text(
              article.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // subtitle from metafield (optional)
            if (subtitle != null)
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (subtitle != null) const SizedBox(height: 16),

            // intro
            if (intro.isNotEmpty)
              Text(
                intro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            const SizedBox(height: 20),

            // image + side text layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                final Widget imageWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child:
                      article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            fallbackImageAsset,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(fallbackImageAsset, fit: BoxFit.cover),
                );

                if (isWide) {
                  // tablet/web: image + side text
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: imageWidget),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sideTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sideText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // mobile: image on top, side text below
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageWidget,
                    const SizedBox(height: 14),
                    Text(
                      sideTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sideText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // remaining content (full article text)
            ...bottomParas.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  p,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),

            Text(
              'Disclaimer: This article is for general wellness education only and is not a substitute for professional medical advice, diagnosis or treatment.',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
