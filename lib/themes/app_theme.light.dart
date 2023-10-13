import 'package:flutter/material.dart';

final lightAppTheme = ThemeData.localize(
  ThemeData.light(
    useMaterial3: true,
  ),
  ThemeData(fontFamily: 'OpenSans').textTheme,
);
