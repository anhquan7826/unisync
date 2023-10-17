import 'package:flutter/material.dart';
import 'package:unisync/app/devices/devices.landscape.view.dart';
import 'package:unisync/app/devices/devices.portrait.view.dart';
import 'package:unisync/extensions/screen_size.ext.dart';

class DevicesView extends StatelessWidget {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      return const DevicesViewMobile();
    } else {
      return const DevicesViewMobile();
    }
  }
}
