import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/utils/configs.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future<void> redirect() async {
    final recentDevice = await ConfigUtil.device.getLastUsedDevice();
    if (!mounted) {
      return;
    }
    if (recentDevice != null) {
      context.goNamed(
        routes.home,
        extra: Device(recentDevice),
      );
    } else {
      context.goNamed(routes.pair);
    }
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
