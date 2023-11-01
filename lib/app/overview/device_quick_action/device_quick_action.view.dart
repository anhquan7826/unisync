import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/conveniences.ext.dart';
import 'package:unisync/utils/extensions/screen_size.ext.dart';

class DeviceAction extends StatefulWidget {
  const DeviceAction({super.key, this.drawer, this.deviceInfo, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;
  final DeviceInfo? deviceInfo;

  @override
  State<DeviceAction> createState() => DeviceActionState();
}

class DeviceActionState extends State<DeviceAction> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.scaffoldKey == null) {
          return true;
        } else {
          if (widget.scaffoldKey!.currentState?.isDrawerOpen == true) {
            widget.scaffoldKey!.currentState?.closeDrawer();
            return false;
          } else {
            return true;
          }
        }
      },
      child: Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
          title: widget.deviceInfo == null
              ? context.isLandscape
                  ? null
                  : Text(R.strings.devicesStatus.title).tr()
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
        drawer: widget.drawer != null
            ? Drawer(
                width: MediaQuery.of(context).size.width,
                shape: const RoundedRectangleBorder(),
                child: SafeArea(child: widget.drawer!),
              )
            : null,
        body: widget.deviceInfo == null
            ? Center(
                child: Column(
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
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 32,
                      ),
                      child: Text(R.strings.devicesStatus.noConnectedDevices).tr(),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        context.go('${AppRoute.overview}/${AppRoute.addDevice}');
                      },
                      icon: const Icon(Icons.add),
                      label: Text(R.strings.devicesStatus.addDevice).tr(),
                    ),
                  ],
                ),
              )
            : const Placeholder(),
      ),
    );
  }
}
