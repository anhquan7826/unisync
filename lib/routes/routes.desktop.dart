import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/connections/connection.cubit.dart';
import 'package:unisync/app/connections/connection.view.dart';
import 'package:unisync/app/home/home.cubit.dart';
import 'package:unisync/app/home/home.view.dart';
import 'package:unisync/app/landing/landing.cubit.dart';
import 'package:unisync/app/landing/landing.view.dart';

import '../models/device_info/device_info.model.dart';

const routes = (
  landing: 'landing',
  home: 'home',
  pair: 'pair',
);

final routerConfigs = GoRouter(
  initialLocation: '/landing',
  routes: [
    GoRoute(
      name: routes.landing,
      path: '/landing',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => LandingCubit(),
          child: const LandingScreen(),
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
          create: (context) => ConnectionCubit(),
          child: const ConnectionScreen(),
        );
      },
    )
  ],
);
