import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisync/utils/channels.dart';

class AppPreferences {
  AppPreferences._();

  static SharedPreferences? _fsp;
  static final _asp = UnisyncChannels.preferences;

  static Future<String?> getString(String key) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      return (await _asp.invokeMethod(PreferencesChannel.GET_STRING, arguments: {'key': key})).result as String?;
    } else {
      return _fsp!.getString(key);
    }
  }

  static Future<int?> getInt(String key) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      return (await _asp.invokeMethod(PreferencesChannel.GET_INT, arguments: {'key': key})).result as int?;
    } else {
      return _fsp!.getInt(key);
    }
  }

  static Future<bool?> getBool(String key) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      return (await _asp.invokeMethod(PreferencesChannel.GET_BOOL, arguments: {'key': key})).result as bool?;
    } else {
      return _fsp!.getBool(key);
    }
  }

  static Future<void> putString(String key, String value) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      await _asp.invokeMethod(PreferencesChannel.PUT_STRING, arguments: {'key': key, 'value': value});
    } else {
      _fsp!.setString(key, value);
    }
  }

  static Future<void> putInt(String key, int value) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      await _asp.invokeMethod(PreferencesChannel.PUT_INT, arguments: {'key': key, 'value': value});
    } else {
      _fsp!.setInt(key, value);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<void> putBool(String key, bool value) async {
    _fsp ??= await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      await _asp.invokeMethod(PreferencesChannel.PUT_BOOL, arguments: {'key': key, 'value': value});
    } else {
      _fsp!.setBool(key, value);
    }
  }
}
