import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/routes/routes.dart';

import '../../../resources/resources.dart';

class DevicesSidebar extends StatefulWidget {
  const DevicesSidebar({super.key});

  @override
  State<DevicesSidebar> createState() => _DevicesSidebarState();
}

class _DevicesSidebarState extends State<DevicesSidebar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              R.strings.appName,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {
              context.go('${AppRoute.device}/${AppRoute.addDevice}');
            },
            icon: const Icon(Icons.add),
            label: Text(R.strings.devices.addDevice).tr(),
          ),
          Text(
            R.strings.devices.connectedDevice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ).tr(),
          Text(
            R.strings.devices.disconnectedDevice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ).tr(),
        ],
      ),
    );
  }
}
