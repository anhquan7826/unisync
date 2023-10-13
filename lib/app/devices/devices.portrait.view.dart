import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/routes/routes.dart';

class DevicesViewMobile extends StatefulWidget {
  const DevicesViewMobile({super.key});

  @override
  State<DevicesViewMobile> createState() => _DevicesViewMobileState();
}

class _DevicesViewMobileState extends State<DevicesViewMobile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(R.strings.devices.title).tr(),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Padding(
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
                Text(
                  R.strings.devices.connectedDevice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ).tr(),
                Text(
                  R.strings.devices.disconnectedDevice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ).tr(),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.go('${AppRoute.device}/${AppRoute.addDevice}');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(R.strings.devices.addDevice).tr(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Placeholder(),
    );
  }
}
