import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/utils/extensions/context.ext.dart';

class DeviceAction extends StatefulWidget {
  const DeviceAction({super.key, this.drawer, this.deviceInfo});

  final Widget? drawer;
  final DeviceInfo? deviceInfo;

  @override
  State<DeviceAction> createState() => DeviceActionState();
}

class DeviceActionState extends State<DeviceAction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.deviceInfo == null
            ? Text(R.strings.devices.title).tr()
            : Column(
                children: [
                  Text(widget.deviceInfo!.name),
                  Text(
                    widget.deviceInfo!.deviceType,
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
      ),
      drawer: Drawer(
        child: widget.drawer,
      ),
      body: widget.deviceInfo == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  R.icons.unlink,
                  width: 128,
                  colorFilter: ColorFilter.mode(
                    context.isDarkMode ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                Text(R.strings.devices.noConnectedDevices).tr(),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.go('${AppRoute.device}/${AppRoute.addDevice}');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(R.strings.devices.addDevice).tr(),
                ),
              ],
            )
          : const Placeholder(),
    );
  }
}
