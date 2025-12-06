import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SimpleRowShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const SimpleRowShimmer({
    super.key,
    this.height = 100,
    this.width = 200,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ),
    );
  }
}
