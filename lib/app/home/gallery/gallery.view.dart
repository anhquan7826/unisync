import 'package:flutter/material.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UImage.asset(
            R.icon.error,
            width: 64,
            height: 128,
          ),
          const Text('Feature is not available!'),
        ],
      ),
    );
  }
}
