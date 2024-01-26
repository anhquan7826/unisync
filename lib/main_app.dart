import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/repository/repo_providers.dart';

import 'routes/routes.desktop.dart';
import 'routes/routes.mobile.dart';
import 'themes/app_theme.dart';

class Unisync extends StatelessWidget {
  const Unisync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: unisyncThemes,
      routerConfig: Platform.isAndroid ? MobileRouter.routerConfigs : DesktopRouter.routerConfigs,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: providers,
          child: child!,
        );
      },
    );
  }
}
