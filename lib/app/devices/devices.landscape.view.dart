import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unisync/resources/resources.dart';

class DevicesViewDesktop extends StatefulWidget {
  const DevicesViewDesktop({super.key});

  @override
  State<DevicesViewDesktop> createState() => _DevicesViewDesktopState();
}

class _DevicesViewDesktopState extends State<DevicesViewDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(R.strings.devices.textTitle).tr(),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [],
            ),
          ),
          Expanded(
            child: Placeholder(),
          ),
        ],
      ),
    );
  }
}
