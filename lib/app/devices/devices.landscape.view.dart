import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unisync/app/devices/common/device_action.view.dart';
import 'package:unisync/app/devices/common/devices_sidebar.view.dart';
import 'package:unisync/resources/resources.dart';

class DevicesViewLandscape extends StatefulWidget {
  const DevicesViewLandscape({super.key});

  @override
  State<DevicesViewLandscape> createState() => _DevicesViewLandscapeState();
}

class _DevicesViewLandscapeState extends State<DevicesViewLandscape> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: DevicesSidebar(),
          ),
          Expanded(
            child: DeviceAction(),
          ),
        ],
      ),
    );
  }
}
