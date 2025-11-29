import 'dart:convert';
import 'package:http/http.dart' as http;
import 'shopify_config.dart';
import '../models/product_variant.dart';

class ShopifyService {
  final String endpoint =
      "https://${ShopifyConfig.storeUrl}/api/${ShopifyConfig.apiVersion}/graphql.json";

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "X-Shopify-Storefront-Access-Token": ShopifyConfig.storefrontAccessToken,
  };

  Future<Map<String, dynamic>> _post(String query) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode({"query": query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "GraphQL Error: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // 🚀 Fetch Products with Basic Fields
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    const query = r'''
    {
      products(first: 30) {
        nodes {
          id
          title
          productType
          featuredImage {
            url
          }
          variants(first: 10) {
            nodes {
              id
              title
              price {
                amount
              }
              compareAtPrice {
                amount
              }
            }
          }
        }
      }
    }
    ''';

    final result = await _post(query);
    final List nodes = result["data"]["products"]["nodes"] as List;

    return nodes.map((p) {
      final List vNodes = p["variants"]["nodes"] as List;

      final variants = vNodes.map((v) {
        final priceStr = v["price"]?["amount"] ?? "0";
        final compareStr = v["compareAtPrice"]?["amount"];

        return ProductVariant(
          id: v["id"],
          title: (v["title"] ?? "").toString(),
          price: double.tryParse(priceStr) ?? 0.0,
          compareAtPrice: compareStr != null
              ? double.tryParse(compareStr)
              : null,
        );
      }).toList();

      // Fallback price = first variant or 0
      final double basePrice = variants.isNotEmpty ? variants.first.price : 0.0;

      return {
        "id": p["id"],
        "name": p["title"],
        "category": p["productType"] ?? "Other",
        "imageUrl":
            p["featuredImage"]?["url"] ??
            "https://via.placeholder.com/400x400.png?text=No+Image",
        "price": basePrice,
        "variants": variants,
      };
    }).toList();
  }

  // 🚀 Fetch Collections (Categories)
  Future<List<String>> fetchCollections() async {
    const query = r'''
    {
      collections(first: 20) {
        nodes {
          title
        }
      }
    }
    ''';

    final result = await _post(query);

    return (result["data"]["collections"]["nodes"] as List)
        .map((c) => c["title"] as String)
        .toList();
  }
}
