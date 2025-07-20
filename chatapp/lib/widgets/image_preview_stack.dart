import 'package:flutter/material.dart';


class ImagePreviewStack extends StatelessWidget {
  final List<Image> imageUrls;

  const ImagePreviewStack({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120 + (imageUrls.length - 1) * 20,
      child: Stack(
        children: imageUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;

          return Positioned(
            left: index * 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image, // Already an Image widget
            ),
          );
        }).toList(),
      ),
    );
  }
}
