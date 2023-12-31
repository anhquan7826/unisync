import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unisync/app/overview/devices_status/devices_status.cubit.dart';
import 'package:unisync/app/overview/devices_status/devices_status.state.dart';
import 'package:unisync/app/overview/overview.cubit.dart';
import 'package:unisync/utils/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';

import '../../../resources/resources.dart';

class DevicesStatusView extends StatefulWidget {
  const DevicesStatusView({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<DevicesStatusView> createState() => _DevicesStatusViewState();
}

class _DevicesStatusViewState extends State<DevicesStatusView> {
  late final DevicesStatusCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<DevicesStatusCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DevicesStatusCubit, DevicesStatusState>(
      buildWhen: (_, state) => state is DevicesStatusInitializing || state is DevicesStatusInitialized,
      listenWhen: (_, state) => state is! DevicesStatusInitializing && state is! DevicesStatusInitialized,
      listener: (context, state) {
        if (state is OnDeviceDisconnectedState) {
          if (BlocProvider.of<OverviewCubit>(context).currentDevice?.id == state.device.id) {
            BlocProvider.of<OverviewCubit>(context).changeDevice(null);
          }
        }
        setState(() {});
      },
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
                      if (cubit.connectedDevices.isNotEmpty || cubit.disconnectedDevices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildPairedDevices(
                            connectedDevices: cubit.connectedDevices,
                            disconnectedDevices: cubit.disconnectedDevices,
                          ),
                        ),
                      buildUnpairedDevices(
                        cubit.unpairedDevices,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (Platform.isAndroid)
              buildFooter()
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
                  ? R.icon.linux
                  : Platform.isWindows
                      ? R.icon.windows
                      : R.icon.android,
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
                  R.string.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(cubit.info.name)
              ],
            ),
          ),
          if (widget.scaffoldKey != null)
            IconButton(
              onPressed: () {
                closeDrawer();
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }

  Widget buildFooter() {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Add a device'),
              content: TextField(
                decoration: const InputDecoration(
                  label: Text('Device IP'),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  cubit.addDevice(value.trim());
                },
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add a device'),
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
          R.string.devicesStatus.pairedDevices,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ).tr(),
        if (connectedDevices.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              bottom: 16,
            ),
            child: Text(
              R.string.devicesStatus.connectedDevice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ).tr(),
          ),
          ...connectedDevices.map((device) {
            return buildDeviceTile(device);
          }),
        ],
        if (disconnectedDevices.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              bottom: 16,
            ),
            child: Text(
              R.string.devicesStatus.disconnectedDevice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ).tr(),
          ),
          ...disconnectedDevices.map((device) {
            return buildDeviceTile(device);
          }),
        ],
      ],
    );
  }

  Widget buildUnpairedDevices(List<DeviceInfo> disconnectedDevices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                R.string.devicesStatus.availableDevices,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ).tr(),
            ),
            TextButton.icon(
              onPressed: () {
                cubit.loadDevices();
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(R.string.devicesStatus.rescan).tr(),
            ),
          ],
        ),
        ...disconnectedDevices.map((device) {
          return buildDeviceTile(device);
        })
      ],
    );
  }

  Widget buildDeviceTile(DeviceInfo device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: SvgPicture.asset(
        device.deviceType == DeviceTypes.android
            ? R.icon.android
            : device.deviceType == DeviceTypes.linux
                ? R.icon.linux
                : R.icon.windows,
        colorFilter: ColorFilter.mode(
          context.isDarkMode ? Colors.white : Colors.black,
          BlendMode.srcIn,
        ),
        width: 24,
      ),
      title: Text(device.name),
      subtitle: Text(device.ip),
      onTap: () {
        BlocProvider.of<OverviewCubit>(context).changeDevice(device);
        closeDrawer();
      },
    );
  }

  void closeDrawer() {
    widget.scaffoldKey?.currentState?.isDrawerOpen.let((it) {
      if (it) {
        widget.scaffoldKey?.currentState?.closeDrawer();
      }
    });
  }
}
