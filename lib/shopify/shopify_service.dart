import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'shopify_config.dart';

/// Central service to talk to Shopify Storefront API.
/// - Uses GraphQL endpoint defined in [ShopifyConfig].
/// - Returns simple Maps that are converted to [Product] by Product.fromMap.
class ShopifyService {
  ShopifyService();

  final String endpoint =
      "https://${ShopifyConfig.storeUrl}/api/${ShopifyConfig.apiVersion}/graphql.json";

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "X-Shopify-Storefront-Access-Token": ShopifyConfig.storefrontAccessToken,
  };

  Future<Map<String, dynamic>> _post(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final res = await http.post(
      Uri.parse(endpoint),
      headers: _headers,
      body: jsonEncode({
        'query': query,
        if (variables != null) 'variables': variables,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Shopify HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    if (body['errors'] != null) {
      throw Exception('Shopify GraphQL error: ${body['errors']}');
    }
    return body;
  }

  // Low-level helper to call Shopify Storefront GraphQL
  

  // ShopifyService.dart  (inside class ShopifyService)

  Future<String> loginCustomer(String email, String password) async {
    const String mutation = r'''
    mutation customerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) {
      customerAccessTokenCreate(input: $input) {
        customerAccessToken {
          accessToken
          expiresAt
        }
        userErrors {
          field
          message
        }
      }
    }
  ''';

    final variables = {
      'input': {'email': email.trim(), 'password': password},
    };

    // ⬇️ Replace `_postGraphQL` with your actual helper name if different
    final data = await _post(mutation, variables: variables);

    final create = data['customerAccessTokenCreate'];
    if (create == null) {
      throw Exception('Unexpected response from Shopify');
    }

    final errors = (create['userErrors'] as List?) ?? [];
    if (errors.isNotEmpty) {
      // grab first error message
      final msg = errors.first['message']?.toString() ?? 'Login failed';
      throw Exception(msg);
    }

    final token = create['customerAccessToken']?['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Login failed – no token returned');
    }

    return token;
  }

  // ─────────────────────────────────────────────────────────────
  // Products
  // ─────────────────────────────────────────────────────────────

  /// Fetch a flat list of products from Shopify.
  /// Returns a List<Map> that matches Product.fromMap().
  Future<List<Map<String, dynamic>>> fetchProducts({int first = 30}) async {
    const String query = r'''
    query GetProducts($first: Int!) {
      products(first: $first) {
        edges {
          node {
            id
            title
            description
            productType
            images(first: 10) {
              edges {
                node {
                  url
                }
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
      }
    }
    ''';

    final data = await _post(query, variables: {'first': first});
    final edges = (data['data']?['products']?['edges'] as List<dynamic>? ?? []);

    return edges
        .map<Map<String, dynamic>>(
          (e) => _mapProductNode(e['node'] as Map<String, dynamic>),
        )
        .toList();
  }

  /// Fetch products that belong to a Shopify Collection
  /// whose title matches [collectionTitle] loosely.
  ///
  /// This is used by ProductProvider.filterByCategory when the
  /// selected category is one of the collection names.
  Future<List<Map<String, dynamic>>> fetchProductsByCollection(
    String collectionTitle, {
    int first = 30,
  }) async {
    const String query = r'''
    query ProductsByCollection($title: String!, $first: Int!) {
      collections(first: 1, query: $title) {
        edges {
          node {
            id
            title
            handle
            products(first: $first) {
              edges {
                node {
                  id
                  title
                  description
                  productType
                  images(first: 10) {
                    edges {
                      node {
                        url
                      }
                    }
                  }
                  variants(first: 10) {
                    edges {
                      node {
                        id
                        title
                        price {
                          amount
                          currencyCode
                        }
                        compareAtPrice {
                          amount
                          currencyCode
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    ''';

    final data = await _post(
      query,
      variables: {'title': collectionTitle, 'first': first},
    );

    final collections =
        (data['data']?['collections']?['edges'] as List<dynamic>? ?? []);
    if (collections.isEmpty) return [];

    final productsEdges =
        (collections.first['node']?['products']?['edges'] as List<dynamic>? ??
        []);

    return productsEdges
        .map<Map<String, dynamic>>(
          (e) => _mapProductNode(e['node'] as Map<String, dynamic>),
        )
        .toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Collections (for Categories tab)
  // ─────────────────────────────────────────────────────────────

  /// Fetch visible collection titles from Shopify.
  ///
  /// We only return the `title` as a simple List<String> because
  /// ProductProvider only needs the names to show in the UI and to
  /// call [fetchProductsByCollection] when a category is selected.
  Future<List<String>> fetchCollections({int first = 20}) async {
    const String query = r'''
    query GetCollections($first: Int!) {
      collections(first: $first) {
        edges {
          node {
            id
            title
            handle
          }
        }
      }
    }
    ''';

    final data = await _post(query, variables: {'first': first});
    final edges =
        (data['data']?['collections']?['edges'] as List<dynamic>? ?? []);

    return edges
        .map<String>((e) => (e['node']?['title'] as String?) ?? '')
        .where((title) => title.trim().isNotEmpty)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  /// Convert a Shopify GraphQL Product node into a flat Map that
  /// can be consumed by Product.fromMap().
  Map<String, dynamic> _mapProductNode(Map<String, dynamic> node) {
    final imagesEdges = (node['images']?['edges'] as List<dynamic>? ?? []);
    final imageUrls = imagesEdges
        .map<String>((e) => (e['node']?['url'] as String?) ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final variantEdges = (node['variants']?['edges'] as List<dynamic>? ?? []);

    final List<Map<String, dynamic>> variants = [];
    double price = 0.0;
    double? compareAtPrice;

    for (final edge in variantEdges) {
      final v = edge['node'] as Map<String, dynamic>? ?? {};
      final priceAmount = (v['price']?['amount'])?.toString();
      final compareAmount = (v['compareAtPrice']?['amount'])?.toString();

      final double variantPrice = double.tryParse(priceAmount ?? '') ?? 0.0;
      final double? variantCompareAtPrice = compareAmount != null
          ? double.tryParse(compareAmount)
          : null;

      variants.add({
        'id': v['id'] ?? '',
        'title': v['title'] ?? '',
        'price': variantPrice,
        'compareAtPrice': variantCompareAtPrice,
      });

      if (price == 0.0) {
        price = variantPrice;
      }
      compareAtPrice ??= variantCompareAtPrice;
    }

    return {
      'id': node['id'] ?? '',
      'name': node['title'] ?? '',
      'description': node['description'] ?? '',
      'category': node['productType'] ?? 'General',
      'images': imageUrls,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'variants': variants,
    };
  }

  // ─────────────────────────────────────────────────────────────
  // ARTICLES
  // ─────────────────────────────────────────────────────────────

  Future<ShopifyArticle> fetchArticleByHandle({
    required String blogHandle,
    required String articleHandle,
  }) async {
    const String query = r'''
  query ArticleByHandle($blogHandle: String!, $articleHandle: String!) {
    blog(handle: $blogHandle) {
      articleByHandle(handle: $articleHandle) {
        title
        content
        image {
          url
        }
        subtitleMf: metafield(namespace: "app", key: "subtitle") {
          value
        }
        introMf: metafield(namespace: "app", key: "intro") {
          value
        }
        sideTitleMf: metafield(namespace: "app", key: "side_section_title") {
          value
        }
        sideTextMf: metafield(namespace: "app", key: "side_section_text") {
          value
        }
      }
    }
  }
  ''';

    // use the same _post() you already use for products/collections
    final data = await _post(
      query,
      variables: {'blogHandle': blogHandle, 'articleHandle': articleHandle},
    );

    final blog = data['data']?['blog'];
    if (blog == null || blog['articleByHandle'] == null) {
      throw Exception('Article not found for handle: $articleHandle');
    }

    final articleJson = blog['articleByHandle'] as Map<String, dynamic>;
    return ShopifyArticle.fromJson(articleJson);
  }
}

class ShopifyArticle {
  final String title;
  final String content; // plain text from Shopify
  final String? imageUrl;

  // Metafields from namespace "app"
  final String? subtitle; // app.subtitle
  final String? intro; // app.intro
  final String? sideSectionTitle; // app.side_section_title
  final String? sideSectionText; // app.side_section_text

  ShopifyArticle({
    required this.title,
    required this.content,
    this.imageUrl,
    this.subtitle,
    this.intro,
    this.sideSectionTitle,
    this.sideSectionText,
  });

  factory ShopifyArticle.fromJson(Map<String, dynamic> json) {
    String? _meta(Map<String, dynamic> j, String key) {
      final field = j[key];
      if (field == null) return null;
      return field['value'] as String?;
    }

    return ShopifyArticle(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image'] != null ? json['image']['url'] as String? : null,
      subtitle: _meta(json, 'subtitleMf'),
      intro: _meta(json, 'introMf'),
      sideSectionTitle: _meta(json, 'sideTitleMf'),
      sideSectionText: _meta(json, 'sideTextMf'),
    );
  }
}
