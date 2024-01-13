import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'routes/routes.dart';
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
        return windowBorder(child!);
      },
    );
  }

  Widget windowBorder(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: WindowBorder(
        color: Colors.black,
        child: Material(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: WindowTitleBarBox(
                      child: MoveWindow(
                        child: const Center(
                          child: Text(
                            'Unisync',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      MinimizeWindowButton(),
                      MaximizeWindowButton(),
                      CloseWindowButton(),
                    ],
                  ),
                ],
              ),
              const Divider(
                height: 1,
              ),
              Flexible(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
