import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/overview/devices_status/devices_status.cubit.dart';
import 'package:unisync/app/overview/overview.view.dart';

class AppRoute {
  AppRoute._();
  static const overview = '/';
  static const addDevice = 'add';

  static final routerConfigs = GoRouter(
    initialLocation: overview,
    routes: [
      GoRoute(
        path: overview,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<DevicesStatusCubit>(
                create: (context) => DevicesStatusCubit(),
              )
            ],
            child: const OverviewView(),
          );
        },
      ),
    ],
  );
}
