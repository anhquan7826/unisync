import 'package:flutter/material.dart';

final darkAppTheme = ThemeData.localize(
  ThemeData.dark(
    useMaterial3: true,
  ),
  ThemeData(fontFamily: 'OpenSans').textTheme,
);
