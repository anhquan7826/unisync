import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisync/constants/sp_keys.dart';
import 'package:unisync/extensions/map.ext.dart';

import '../models/device_info/device_info.model.dart';

class AppConfig {
  AppConfig._();

  static const serviceType = '_unisync._tcp';
  static const serviceDomain = 'local';

  static const discoveryPort = 50810;

  static Future<bool> hasSetDeviceInfo() async {
    return (await SharedPreferences.getInstance()).getString(SPKeys.deviceInfo) != null;
  }

  static Future<DeviceInfo> getDeviceInfo() async {
    return DeviceInfo.fromJson(jsonDecode((await SharedPreferences.getInstance()).getString(SPKeys.deviceInfo)!));
  }

  static Future<void> setDeviceInfo(DeviceInfo info) async {
    (await SharedPreferences.getInstance()).setString(SPKeys.deviceInfo, info.toJson().toJsonString());
  }
}
