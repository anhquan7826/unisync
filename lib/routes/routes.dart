import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unisync/app/landing/landing.view.dart';

class AppRoute {
  AppRoute._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _mainNavigatorKey = GlobalKey<NavigatorState>();

  static const landing = '/';
  static const device = '/device/:deviceId';

  static final routerConfigs = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: landing,
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: landing,
        builder: (context, state) {
          return const LandingView();
        },
      ),
      ShellRoute(
        parentNavigatorKey: _rootNavigatorKey,
        navigatorKey: _mainNavigatorKey,
        builder: (context, state, child) {
          // TODO: Replace child.
          return child;
        },
        routes: [
          GoRoute(
            parentNavigatorKey: _mainNavigatorKey,
            path: device,
            builder: (context, state) {
              final deviceId = state.pathParameters['deviceId'];
              return const Placeholder();
            },
          ),
        ],
      ),
    ],
  );
}
