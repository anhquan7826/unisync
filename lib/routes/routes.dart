import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/overview/devices_status/devices_status.cubit.dart';
import 'package:unisync/app/overview/overview.cubit.dart';
import 'package:unisync/app/overview/overview.view.dart';

class AppRoute {
  AppRoute._();
  static const overview = '/';

  static final routerConfigs = GoRouter(
    initialLocation: overview,
    routes: [
      GoRoute(
        path: overview,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<OverviewCubit>(
                create: (context) => OverviewCubit(),
              ),
              BlocProvider<DevicesStatusCubit>(
                create: (context) => DevicesStatusCubit(context),
              )
            ],
            child: const OverviewView(),
          );
        },
      ),
    ],
  );
}
