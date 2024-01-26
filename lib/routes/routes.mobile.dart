import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/mobile/connections/connection.view.dart';
import 'package:unisync/utils/extensions/context.ext.dart';

import '../app/mobile/connections/connection.cubit.dart';

class MobileRouter {
  MobileRouter._();

  static const routes = (
    landing: 'landing',
    pair: 'pair',
    home: 'home',
  );

  static final routerConfigs = GoRouter(
    initialLocation: '/pair',
    routes: [
      GoRoute(
          name: routes.pair,
          path: '/pair',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => ConnectionCubit(context.getRepo()),
              child: const ConnectionScreen(),
            );
          }),
    ],
  );
}
