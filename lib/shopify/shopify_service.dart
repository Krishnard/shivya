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
        "X-Shopify-Storefront-Access-Token":
            ShopifyConfig.storefrontAccessToken,
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
      throw Exception(
          'Shopify HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    if (body['errors'] != null) {
      throw Exception('Shopify GraphQL error: ${body['errors']}');
    }
    return body;
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
    final edges =
        (data['data']?['products']?['edges'] as List<dynamic>? ?? []);

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
      variables: {
        'title': collectionTitle,
        'first': first,
      },
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
        .map<String>(
          (e) => (e['node']?['title'] as String?) ?? '',
        )
        .where((title) => title.trim().isNotEmpty)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  /// Convert a Shopify GraphQL Product node into a flat Map that
  /// can be consumed by Product.fromMap().
  Map<String, dynamic> _mapProductNode(Map<String, dynamic> node) {
    final imagesEdges =
        (node['images']?['edges'] as List<dynamic>? ?? []);
    final imageUrls = imagesEdges
        .map<String>(
          (e) => (e['node']?['url'] as String?) ?? '',
        )
        .where((url) => url.isNotEmpty)
        .toList();

    final variantEdges =
        (node['variants']?['edges'] as List<dynamic>? ?? []);

    final List<Map<String, dynamic>> variants = [];
    double price = 0.0;
    double? compareAtPrice;

    for (final edge in variantEdges) {
      final v = edge['node'] as Map<String, dynamic>? ?? {};
      final priceAmount = (v['price']?['amount'])?.toString();
      final compareAmount = (v['compareAtPrice']?['amount'])?.toString();

      final double variantPrice =
          double.tryParse(priceAmount ?? '') ?? 0.0;
      final double? variantCompareAtPrice =
          compareAmount != null ? double.tryParse(compareAmount) : null;

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
}
