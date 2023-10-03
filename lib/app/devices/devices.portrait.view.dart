import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unisync/resources/resources.dart';

class DevicesViewMobile extends StatefulWidget {
  const DevicesViewMobile({super.key});

  @override
  State<DevicesViewMobile> createState() => _DevicesViewMobileState();
}

class _DevicesViewMobileState extends State<DevicesViewMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(R.strings.devices.textTitle).tr(),
      ),
      body: const Placeholder(),
    );
  }
}
