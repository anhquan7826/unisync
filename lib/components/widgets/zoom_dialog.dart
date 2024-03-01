import 'package:flutter/material.dart';

Future<void> showZoomDialog({required BuildContext context, required Widget child}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          child: child,
        ),
      );
    },
  );
}