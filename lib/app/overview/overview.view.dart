import 'package:flutter/material.dart';
import 'package:unisync/app/overview/overview.landscape.view.dart';
import 'package:unisync/app/overview/overview.portrait.view.dart';
import 'package:unisync/utils/extensions/screen_size.ext.dart';

class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  @override
  Widget build(BuildContext context) {
    if (context.isPortrait) {
      return const OverviewViewPortrait();
    } else {
      return const OverviewViewLandscape();
    }
  }
}
