import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/device_pair/device_pair.cubit.dart';
import 'package:unisync/app/device_pair/device_pair.view.dart';
import 'package:unisync/app/landing/landing.cubit.dart';
import 'package:unisync/app/landing/landing.view.dart';
import 'package:unisync/utils/extensions/context.ext.dart';

const routes = (landing: '/', pair: '/pair');

final routerConfigs = GoRouter(
  initialLocation: routes.landing,
  routes: [
    GoRoute(
      path: routes.landing,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => LandingCubit(context.getRepo()),
          child: const LandingView(),
        );
      },
    ),
    GoRoute(
      path: routes.pair,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => DevicePairCubit(
            connectionRepo: context.getRepo(),
            pairingRepo: context.getRepo(),
          ),
          child: const DevicePairView(),
        );
      },
    )
  ],
);
