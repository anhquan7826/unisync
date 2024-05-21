import 'package:flutter/material.dart';

class NoPermissionView extends StatelessWidget {
  const NoPermissionView({
    super.key,
    required this.onReload,
  });

  final void Function() onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_rounded,
            size: 64,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Please grant permission in your phone to continue!',
            ),
          ),
          FilledButton(
            onPressed: onReload,
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}
