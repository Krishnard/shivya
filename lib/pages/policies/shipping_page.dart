import 'package:flutter/material.dart';

class ShippingPage extends StatelessWidget {
  const ShippingPage({super.key});

  final List<String> points = const [
    "Cash on delivery is available on select Indian pin-codes.",
    "Shipping charges of ₹50 for COD orders.",
    "Purchases are shipped from our headquarters by courier.",
    "Once order is confirmed your products will be delivered in 5 to 6 business days.",
    "Goods will need to be signed for upon delivery. If you cannot be there to sign for your delivery, please suggest an alternative (family member, colleague, neighbour, etc). Shivya Healthcare takes no responsibility for goods signed by an alternative person.",
    "Shivya Healthcare is not responsible for damage after delivery.",
    "All claims for shortages or damages must be reported to customer service on the day of delivery.",
    "Shipping and handling rates may vary based on product, packaging, size, volume, type and other considerations. Charges will be shown at checkout before making payment.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Policy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: points.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "• ",
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    points[index],
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
