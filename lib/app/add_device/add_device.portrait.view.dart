import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/add_device/add_device.cubit.dart';
import 'package:unisync/app/add_device/add_device.state.dart';
import 'package:unisync/resources/resources.dart';

class AddDeviceMobileView extends StatefulWidget {
  const AddDeviceMobileView({super.key});

  @override
  State<AddDeviceMobileView> createState() => _AddDeviceMobileViewState();
}

class _AddDeviceMobileViewState extends State<AddDeviceMobileView> {
  late final AddDeviceCubit cubit;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // cubit = context.read();
    // cubit.init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddDeviceCubit, AddDeviceState>(
      listener: (context, state) {
        switch (state.runtimeType) {
          case StartingDiscoveryService:
            {
              isLoading = true;
              break;
            }
          case StartedDiscoveryService:
            {
              isLoading = false;
              break;
            }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(R.strings.devices.addDevice).tr(),
          bottom: isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
      ),
    );
  }
}
