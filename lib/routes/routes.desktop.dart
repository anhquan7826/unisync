import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/desktop/home/home.cubit.dart';
import 'package:unisync/app/desktop/home/home.view.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync_backend/models/device_info/device_info.model.dart';

import '../app/desktop/connections/connection.cubit.dart';
import '../app/desktop/connections/connection.view.dart';
import '../app/desktop/landing/landing.cubit.dart';
import '../app/desktop/landing/landing.view.dart';

class DesktopRouter {
  DesktopRouter._();

  static const routes = (
    landing: 'landing',
    home: 'home',
    pair: 'pair',
  );

  static final routerConfigs = GoRouter(
    initialLocation: '/landing',
    routes: [
      GoRoute(
        name: routes.landing,
        path: '/landing',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => LandingCubit(),
            child: const LandingView(),
          );
        },
      ),
      GoRoute(
        name: routes.home,
        path: '/home',
        builder: (context, state) {
          final device = state.extra as DeviceInfo;
          return BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(device),
            child: HomeScreen(
              device: device,
            ),
          );
        },
      ),
      GoRoute(
        name: routes.pair,
        path: '/pair',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => ConnectionCubit(context.getRepo()),
            child: const ConnectionScreen(),
          );
        },
      )
    ],
  );
}
