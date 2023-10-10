import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/add_device/add_device.cubit.dart';
import 'package:unisync/app/add_device/add_device.view.dart';
import 'package:unisync/app/devices/devices.view.dart';

class AppRoute {
  AppRoute._();
  static const device = '/devices';
  static const addDevice = 'add';

  static final routerConfigs = GoRouter(
    initialLocation: device,
    routes: [
      GoRoute(
        path: device,
        builder: (context, state) {
          return const DevicesView();
        },
        routes: [
          GoRoute(
            path: addDevice,
            builder: (context, state) {
              return BlocProvider<AddDeviceCubit>(
                create: (context) => AddDeviceCubit(context),
                child: const AddDeviceView(),
              );
            },
          )
        ],
      ),
    ],
  );
}
