import 'package:flutter/material.dart';
import 'package:unisync/app/devices/common/devices_sidebar.view.dart';

import 'common/device_action.view.dart';

class DevicesViewPortrait extends StatefulWidget {
  const DevicesViewPortrait({super.key});

  @override
  State<DevicesViewPortrait> createState() => _DevicesViewPortraitState();
}

class _DevicesViewPortraitState extends State<DevicesViewPortrait> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DeviceAction(
      drawer: DevicesSidebar(),
    );
  }
}
