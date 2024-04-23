import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/core/device.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

import 'connection.cubit.dart';
import 'connection.state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: BlocBuilder<ConnectionCubit, DeviceConnectionState>(
        builder: (context, state) {
          return buildBody(state);
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(R.strings.device_connection.manage_devices).tr(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            getCubit<ConnectionCubit>().getLastConnected().then((value) {
              value?.apply((it) {
                context.goNamed(
                  routes.home,
                  extra: Device(it),
                );
              });
            });
          }
        },
      ),
    );
  }

  Widget buildBody(DeviceConnectionState state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              R.strings.device_connection.pair_hint.tr(),
              style: context.labelS.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (state.pairedDevices.isNotEmpty) ...[
          SliverAppBar(
            title: Text(R.strings.device_connection.paired_devices).tr(),
            automaticallyImplyLeading: false,
            primary: false,
            floating: true,
            pinned: true,
          ),
          SliverList.list(
            children: state.pairedDevices.map((e) {
              return buildDeviceTile(e);
            }).toList(),
          ),
        ],
        if (state.requestedDevices.isNotEmpty) ...[
          SliverAppBar(
            title: Text(R.strings.device_connection.requested_devices).tr(),
            automaticallyImplyLeading: false,
            primary: false,
            floating: true,
            pinned: true,
          ),
          SliverList.list(
            children: state.requestedDevices.map((e) {
              return buildRequestedDeviceTile(e);
            }).toList(),
          ),
        ],
        // if (state.availableDevices.isNotEmpty) ...[
        //   SliverAppBar(
        //     title: Text(R.strings.device_connection.available_devices).tr(),
        //     automaticallyImplyLeading: false,
        //     primary: false,
        //     floating: true,
        //     pinned: true,
        //   ),
        //   SliverList.list(
        //     children: state.availableDevices.map((e) {
        //       return buildDeviceTile(e);
        //     }).toList(),
        //   ),
        // ],
      ],
    );
  }

  Widget buildRequestedDeviceTile(Device device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: UImage.asset(
        R.vectors.android,
        width: 24,
      ),
      title: Text(device.info.name),
      subtitle: Text(device.ipAddress!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              getCubit<ConnectionCubit>().rejectPair(device);
            },
            icon: const Icon(Icons.close_rounded),
          ),
          IconButton(
            onPressed: () {
              getCubit<ConnectionCubit>().acceptPair(device);
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
    );
  }

  Widget buildDeviceTile(Device device) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: UImage.asset(
        R.vectors.android,
        width: 24,
      ),
      title: Text(device.info.name),
      subtitle: Text(device.ipAddress ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        color: Colors.red,
        onPressed: () {
          showDialog<bool?>(
            context: context,
            builder: (context) {
              return const _DeleteConfirmationDialog();
            },
          ).then((value) {
            if (value == true) {
              // TODO: Delete device,
              getCubit<ConnectionCubit>().unpair(device);
            }
          });
        },
      ),
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(R.strings.device_connection.warning.tr()),
      content: Text(R.strings.device_connection.delete_device_confirmation.tr()),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(R.strings.device_connection.cancel.tr()),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: Text(
            R.strings.device_connection.unpair.tr(),
            style: context.bodyM.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ],
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
