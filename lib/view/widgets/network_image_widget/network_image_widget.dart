import 'package:flutter/material.dart';
import 'package:guru_kripa/view_model/api/api_url_config/api_url_config.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    super.key,
    required this.image,
    this.height = 150,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.fromThirdParty = false,
  });

  final bool fromThirdParty;
  final String image;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // If no valid image found
    if (image.isEmpty) {
      return _placeholder();
    }

    final String imageUrl = fromThirdParty
        ? image
        : "${ApiUrlConfig.baseurl}$image";

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
