import 'package:flutter/material.dart';
import 'package:unisync/app/add_device/add_device.landscape.view.dart';
import 'package:unisync/app/add_device/add_device.portrait.view.dart';
import 'package:unisync/utils/extensions/screen_size.ext.dart';

class AddDeviceView extends StatelessWidget {
  const AddDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      return const AddDeviceMobileView();
    } else {
      return const AddDeviceDesktopView();
    }
  }
}
