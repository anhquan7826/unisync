import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/routes/routes.desktop.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/utils/constants/device_types.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      context.goNamed(
        DesktopRouter.routes.home,
        extra: DeviceInfo(
          id: 'asdfawer2342dasd',
          ip: '192.168.1.1',
          name: 'Sample Device',
          deviceType: DeviceTypes.android,
        ),
      );
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
