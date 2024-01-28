import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/routes/routes.desktop.dart';

import '../../core/device_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      final device = DeviceProvider.connectedDevices.firstOrNull;
      if (device != null) {
        context.goNamed(
          routes.home,
          extra: device,
        );
      } else {
        context.goNamed(routes.pair);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
