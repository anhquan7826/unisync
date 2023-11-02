import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unisync/app/overview/devices_status/devices_status.cubit.dart';
import 'package:unisync/app/overview/devices_status/devices_status.state.dart';
import 'package:unisync/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/conveniences.ext.dart';

import '../../../resources/resources.dart';

class DevicesStatusView extends StatefulWidget {
  const DevicesStatusView({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<DevicesStatusView> createState() => _DevicesStatusViewState();
}

class _DevicesStatusViewState extends State<DevicesStatusView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesStatusCubit, DevicesStatusState>(
      builder: (context, state) {
        if (state is DevicesStatusInitializing) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildPairedDevices(
                        connectedDevices: BlocProvider.of<DevicesStatusCubit>(context).connectedDevices,
                        disconnectedDevices: BlocProvider.of<DevicesStatusCubit>(context).disconnectedDevices,
                      ),
                      buildUnpairedDevices(
                        BlocProvider.of<DevicesStatusCubit>(context).unpairedDevices,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 32,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(
              Platform.isLinux
                  ? R.icons.linux
                  : Platform.isWindows
                      ? R.icons.windows
                      : R.icons.android,
              colorFilter: ColorFilter.mode(
                context.isDarkMode ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
              width: 64,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.strings.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(BlocProvider.of<DevicesStatusCubit>(context).info.name)
              ],
            ),
          ),
          if (widget.scaffoldKey != null)
            IconButton(
              onPressed: () {
                widget.scaffoldKey?.currentState?.isDrawerOpen.let((it) {
                  if (it) {
                    widget.scaffoldKey?.currentState?.closeDrawer();
                  } else {
                    widget.scaffoldKey?.currentState?.openDrawer();
                  }
                });
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }

  Widget buildPairedDevices({
    required List<DeviceInfo> connectedDevices,
    required List<DeviceInfo> disconnectedDevices,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          R.strings.devicesStatus.availableDevices,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ).tr(),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            bottom: 16,
          ),
          child: Text(
            R.strings.devicesStatus.connectedDevice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ).tr(),
        ),
        ...connectedDevices.map((device) {
          return buildDeviceTile(device);
        }),
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            bottom: 16,
          ),
          child: Text(
            R.strings.devicesStatus.disconnectedDevice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ).tr(),
        ),
        ...disconnectedDevices.map((device) {
          return buildDeviceTile(device);
        }),
      ],
    );
  }

  Widget buildUnpairedDevices(List<DeviceInfo> disconnectedDevices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  R.strings.devicesStatus.availableDevices,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ).tr(),
              ),
              TextButton.icon(
                onPressed: () {
                  BlocProvider.of<DevicesStatusCubit>(context).loadDevices();
                },
                icon: const Icon(Icons.replay_rounded),
                label: Text(R.strings.devicesStatus.rescan).tr(),
              ),
            ],
          ),
        ),
        ...disconnectedDevices.map((device) {
          return buildDeviceTile(device);
        })
      ],
    );
  }

  Widget buildDeviceTile(DeviceInfo device) {
    return ListTile(
      leading: SvgPicture.asset(
        device.deviceType == DeviceTypes.android
            ? R.icons.android
            : device.deviceType == DeviceTypes.linux
                ? R.icons.linux
                : R.icons.windows,
        colorFilter: ColorFilter.mode(
          context.isDarkMode ? Colors.white : Colors.black,
          BlendMode.srcIn,
        ),
        width: 24,
      ),
      title: Text(device.name),
      subtitle: Text(device.ip),
      onTap: () {},
    );
  }
}
