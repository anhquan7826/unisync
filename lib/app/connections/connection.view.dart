import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/core/device_provider.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/widgets/image.dart';

import '../../routes/routes.desktop.dart';
import '../../utils/constants/device_types.dart';
import 'connection.cubit.dart';
import 'connection.state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final Set<DeviceInfo> devices = {};
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.string.devicePair.connectToDevice).tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final device = DeviceProvider.connectedDevices.firstOrNull;
              context.goNamed(
                routes.home,
                extra: device,
              );
            }
          },
        ),
      ),
      body: BlocListener<ConnectionCubit, DeviceConnectionState>(
        listener: (BuildContext context, DeviceConnectionState state) {
          if (state is GetAllDeviceState) {
            devices.addAll(state.devices);
            loaded = true;
          }
          if (state is OnDeviceAddState) {
            devices.add(state.device);
          }
          if (state is OnDeviceRemoveState) {
            devices.remove(state.device);
          }
          setState(() {});
        },
        child: !loaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: devices.map((device) {
                  return buildDeviceTile(device);
                }).toList(),
              ),
      ),
    );
  }

  Widget buildDeviceTile(DeviceInfo device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: UImage.asset(
        imageResource: device.deviceType == DeviceTypes.android
            ? R.icon.android
            : device.deviceType == DeviceTypes.linux
                ? R.icon.linux
                : R.icon.windows,
        width: 24,
      ),
      title: Text(device.name),
      subtitle: Text(device.ip),
      onTap: () {
        showPairDialog(device);
      },
    );
  }

  void showPairDialog(DeviceInfo device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(device.name),
          content: Table(
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Text(R.string.devicePair.id).tr(),
                  ),
                  TableCell(child: Text(device.id)),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Text(R.string.devicePair.ipAddress).tr(),
                  ),
                  TableCell(child: Text(device.ip)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                R.string.devicePair.cancel,
              ).tr(),
            ),
            TextButton(
              onPressed: () {
                // TODO: Send pair request
                Navigator.of(context).pop();
              },
              child: Text(
                R.string.devicePair.requestPair,
              ).tr(),
            ),
          ],
        );
      },
    );
  }
}

bool validate(String ip) {
  final RegExp ipv4Pattern = RegExp(
    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    caseSensitive: false,
  );
  return ipv4Pattern.hasMatch(ip);
}
