import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/resources/resources.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';
import 'package:unisync/widgets/image.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';
import 'package:unisync_backend/utils/constants/device_types.dart';

import 'connection.cubit.dart';
import 'connection.state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final List<DeviceInfo> devices = [];
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.string.devicePair.connectToDevice).tr(),
        actions: Platform.isAndroid
            ? [
                IconButton(
                  onPressed: () {
                    showAddIpDialog();
                  },
                  icon: UImage.asset(
                    imageResource: R.icon.add,
                    width: 32,
                  ),
                )
              ]
            : null,
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
            devices.removeWhere((element) => element.id == state.device.id);
          }
          setState(() {});
        },
        child: !loaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: getCubit<ConnectionCubit>().load,
                child: ListView(
                  children: devices.map((device) {
                    return buildDeviceTile(device);
                  }).toList(),
                ),
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

  void showAddIpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const _AddByIPDialog();
      },
    ).then((ip) {
      if (ip != null) {
        context.getCubit<ConnectionCubit>().connectToIp(ip);
      }
    });
  }
}

class _AddByIPDialog extends StatefulWidget {
  const _AddByIPDialog();

  @override
  State<_AddByIPDialog> createState() => _AddByIPDialogState();
}

class _AddByIPDialogState extends State<_AddByIPDialog> {
  bool isValid = false;

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(R.string.devicePair.addManually).tr(),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(R.string.devicePair.ipAddress).tr(),
        ),
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          setState(() {
            validate(value);
          });
        },
        onSubmitted: (value) {
          if (isValid) {
            Navigator.of(context).pop(value);
          }
        },
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
          onPressed: isValid
              ? () {
                  Navigator.of(context).pop(controller.text);
                }
              : null,
          child: Text(
            R.string.devicePair.connect,
          ).tr(),
        ),
      ],
    );
  }

  void validate(String ip) {
    final RegExp ipv4Pattern = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
      caseSensitive: false,
    );
    isValid = ipv4Pattern.hasMatch(ip);
  }
}
