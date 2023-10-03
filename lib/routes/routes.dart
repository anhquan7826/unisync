import 'package:go_router/go_router.dart';
import 'package:unisync/app/devices/devices.view.dart';

class AppRoute {
  AppRoute._();
  static const device = '/devices';

  static final routerConfigs = GoRouter(
    initialLocation: device,
    routes: [
      GoRoute(
        path: device,
        builder: (context, state) {
          return const DevicesView();
        },
      ),
    ],
  );
}
