import 'package:flutter/material.dart';
import 'package:unisync/app/overview/device_quick_action/device_quick_action.view.dart';
import 'package:unisync/app/overview/devices_status/devices_status.view.dart';

class OverviewViewLandscape extends StatefulWidget {
  const OverviewViewLandscape({super.key});

  @override
  State<OverviewViewLandscape> createState() => _OverviewViewLandscapeState();
}

class _OverviewViewLandscapeState extends State<OverviewViewLandscape> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: DevicesStatusView(),
          ),
          VerticalDivider(
            thickness: 1,
          ),
          Expanded(
            child: DeviceAction(),
          ),
        ],
      ),
    );
  }
}
