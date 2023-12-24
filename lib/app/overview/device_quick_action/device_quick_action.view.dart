import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unisync/app/overview/overview.cubit.dart';
import 'package:unisync/app/overview/overview.state.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/screen_size.ext.dart';

class DeviceAction extends StatefulWidget {
  const DeviceAction({super.key, this.drawer, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  @override
  State<DeviceAction> createState() => DeviceActionState();
}

class DeviceActionState extends State<DeviceAction> {
  late final OverviewCubit overviewCubit;

  @override
  void initState() {
    super.initState();
    overviewCubit = BlocProvider.of(context);
  }

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
      child: BlocBuilder<OverviewCubit, OverviewState>(
        builder: (context, state) {
          final device = (state as OverviewDeviceChangeState).device;
          return Scaffold(
            key: widget.scaffoldKey,
            appBar: buildAppBar(device),
            drawer: widget.drawer != null
                ? Drawer(
                    width: MediaQuery.of(context).size.width,
                    shape: const RoundedRectangleBorder(),
                    child: SafeArea(child: widget.drawer!),
                  )
                : null,
            body: buildBody(device),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(DeviceInfo? device) {
    return AppBar(
      title: device == null
          ? context.isLandscape
              ? null
              : Text(R.string.devicesStatus.title).tr()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name),
                Text(
                  device.deviceType,
                  style: Theme.of(context).textTheme.labelSmall,
                )
              ],
            ),
    );
  }

  Widget buildBody(DeviceInfo? device) {
    if (device == null) {
      return buildBodyEmpty();
      // ignore: literal_only_boolean_expressions
    } else if (true /* TODO: check if device is paired */) {
      return buildBodyPaired(device);
      // ignore: dead_code
    } else {
      return buildBodyUnpaired(device);
    }
  }

  Widget buildBodyEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            R.icon.unlink,
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
            child: Text(R.string.devicesStatus.noConnectedDevices).tr(),
          ),
          if (context.isPortrait)
            FilledButton.tonalIcon(
              onPressed: () {
                widget.scaffoldKey?.currentState?.openDrawer();
              },
              icon: const Icon(Icons.add),
              label: Text(R.string.devicesStatus.addDevice).tr(),
            ),
        ],
      ),
    );
  }

  Widget buildBodyUnpaired(DeviceInfo device) {
    return const Placeholder();
  }

  Widget buildBodyPaired(DeviceInfo device) {
    return const Placeholder();
  }
}
