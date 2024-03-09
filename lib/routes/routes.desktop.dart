import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/connections/connection.cubit.dart';
import 'package:unisync/app/connections/connection.view.dart';
import 'package:unisync/app/home/home.view.dart';
import 'package:unisync/app/landing/landing.cubit.dart';
import 'package:unisync/app/landing/landing.view.dart';
import 'package:unisync/core/device.dart';

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
      path: '/home/:id',
      builder: (context, state) {
        final deviceId = state.pathParameters['id'].toString();
        return HomeScreen(
          deviceId: deviceId,
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
