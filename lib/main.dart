import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/database/unisync_database.dart';
import 'package:unisync/main_process.dart';
import 'package:unisync/repository/pairing.repository.dart';
import 'package:unisync/routes/routes.dart';
import 'package:unisync/themes/app_theme.dart';
import 'package:unisync/utils/configs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ConfigUtil.authentication.prepareCryptography();
  if (!Platform.isAndroid) {
    await UnisyncDatabase.initialize();
    final process = MainProcess();
    await process.initialize();
    await process.start();
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
      ],
      startLocale: const Locale('en', 'US'),
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const Unisync(),
    ),
  );
}

class Unisync extends StatelessWidget {
  const Unisync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.dark,
      routerConfig: AppRoute.routerConfigs,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        // return child!;
        return Placeholder();
      },
    );
  }
}
