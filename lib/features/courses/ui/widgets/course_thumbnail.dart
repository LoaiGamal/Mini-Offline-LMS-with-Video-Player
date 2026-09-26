import 'package:flutter/material.dart';

class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.path,
    required this.height,
    this.width,
    this.radius = 12,
  });

  final String path;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double logicalWidth = width ?? MediaQuery.sizeOf(context).width;
    final int cacheWidth = (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        excludeFromSemantics: true,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colors.surfaceContainerHighest,
            child: Icon(Icons.image_not_supported_outlined, color: colors.outline),
          );
        },
      ),
    );
  }
}
