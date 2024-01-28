import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'main_app.dart';
import 'main_process.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (!Platform.isAndroid) {
    final process = MainProcess();
    await process.initialize();
    process.start();
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
