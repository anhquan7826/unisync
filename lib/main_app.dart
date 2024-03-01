import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'components/themes/app_theme.dart';
import 'routes/routes.desktop.dart';

class Unisync extends StatelessWidget {
  const Unisync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: unisyncThemes,
      routerConfig: routerConfigs,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
