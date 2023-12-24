import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UImage extends StatelessWidget {
  factory UImage.asset({
    Key? key,
    required String imageResource,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return UImage._(
      key: key,
      imageResource: imageResource,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  factory UImage.network({
    Key? key,
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    Widget Function(BuildContext context)? placeholder,
  }) {
    return UImage._(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
    );
  }

  const UImage._({
    super.key,
    this.imageResource,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  final String? imageResource;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext context)? placeholder;

  @override
  Widget build(BuildContext context) {
    if (imageResource != null) {
      if (imageResource!.contains(RegExp(r'.*\.svg'))) {
        return SvgPicture.asset(
          imageResource!,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          placeholderBuilder: placeholder,
        );
      } else {
        return Image.asset(
          imageResource!,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
        );
      }
    } else {
      if (imageUrl!.contains(RegExp(r'.*\.svg'))) {
        return SvgPicture.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          placeholderBuilder: placeholder,
        );
      } else {
        return Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
        );
      }
    }
  }
}
