import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unisync/app/add_device/add_device.cubit.dart';
import 'package:unisync/app/add_device/add_device.state.dart';
import 'package:unisync/constants/device_types.dart';
import 'package:unisync/models/device_info/device_info.model.dart';
import 'package:unisync/resources/resources.dart';

class AddDeviceMobileView extends StatefulWidget {
  const AddDeviceMobileView({super.key});

  @override
  State<AddDeviceMobileView> createState() => _AddDeviceMobileViewState();
}

class _AddDeviceMobileViewState extends State<AddDeviceMobileView> {
  late final AddDeviceCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read();
    cubit.loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddDeviceCubit, AddDeviceState>(
      listener: (context, state) {
        if (state is AddDeviceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(R.strings.devices.addDevice).tr(),
          bottom: state is AddDeviceLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: cubit.loadDevices,
          child: ListView(
            children: cubit.devices.map(
              (device) {
                return buildDeviceTile(device, () {});
              },
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildDeviceTile(DeviceInfo device, void Function() onTap) {
    Widget getDeviceIcon(String deviceType) {
      switch (deviceType) {
        case DeviceTypes.android:
          return const Icon(
            Icons.android,
            size: 16,
          );
        case DeviceTypes.linux:
          return SvgPicture.asset(
            R.icons.linux,
            width: 16,
          );
        case DeviceTypes.windows:
          return SvgPicture.asset(
            R.icons.windows,
            width: 16,
          );
        default:
          return const Icon(Icons.desktop_windows_rounded);
      }
    }

    return ListTile(
      leading: getDeviceIcon(device.deviceType),
      title: Text(device.name),
      subtitle: Text(device.ip),
      onTap: onTap,
    );
  }
}
