import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  bool get isDarkMode {
    return MediaQuery.of(this).platformBrightness == Brightness.dark;
  }
}