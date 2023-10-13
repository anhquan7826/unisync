import 'dart:io';

import 'package:flutter/widgets.dart';

extension ScreenSize on BuildContext {
  bool get isPortrait {
    if (Platform.isAndroid || Platform.isIOS) {
      return MediaQuery.of(this).orientation == Orientation.portrait;
    } else {
      return MediaQuery.of(this).size.width <= 500;
    }
  }

  bool get isLandscape => !isPortrait;
}
