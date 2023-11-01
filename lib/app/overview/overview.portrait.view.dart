import 'package:flutter/material.dart';
import 'package:unisync/app/overview/devices_status/devices_status.view.dart';

import 'device_quick_action/device_quick_action.view.dart';

class OverviewViewPortrait extends StatefulWidget {
  const OverviewViewPortrait({super.key});

  @override
  State<OverviewViewPortrait> createState() => _OverviewViewPortraitState();
}

class _OverviewViewPortraitState extends State<OverviewViewPortrait> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeviceAction(
      scaffoldKey: scaffoldKey,
      drawer: DevicesStatusView(
        scaffoldKey: scaffoldKey,
      ),
    );
  }
}
