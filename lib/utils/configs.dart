import 'dart:convert';

import 'package:pointycastle/pointycastle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisync/constants/sp_key.dart';
import 'package:unisync/database/unisync_database.dart';
import 'package:unisync/utils/cryptography/rsa.dart';
import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/preferences.dart';

import '../models/device_info/device_info.model.dart';

class ConfigUtil {
  ConfigUtil._();

  static const serviceType = '_unisync._tcp';
  static const serviceDomain = 'local';
  static const discoveryPort = 50810;

  static final device = _DeviceConfig._();
  static final authentication = _AuthenticationConfig._();
}

class _DeviceConfig {
  _DeviceConfig._();

  Future<bool> hasSetDeviceInfo() async {
    return await AppPreferences.getString(SPKey.deviceInfo) != null;
  }

  Future<DeviceInfo> getDeviceInfo() async {
    return DeviceInfo.fromJson(jsonDecode((await AppPreferences.getString(SPKey.deviceInfo))!));
  }

  Future<void> setDeviceInfo(DeviceInfo info) async {
    await AppPreferences.putString(SPKey.deviceInfo, info.toJson().toJsonString());
  }

  Future<List<DeviceInfo>> getPairedDevices() async {
    return UnisyncDatabase.pairedDeviceDao.getAll();
  }

  Future<void> addPairedDevice(DeviceInfo device) async {
    await UnisyncDatabase.pairedDeviceDao.add(device);
  }

  Future<void> removePairedDevice(DeviceInfo device) async {
    await UnisyncDatabase.pairedDeviceDao.remove(device);
  }
}

class _AuthenticationConfig {
  _AuthenticationConfig._();

  RSAPrivateKey? _privateKey;
  String? _privateKeyString;
  RSAPublicKey? _publicKey;
  String? _publicKeyString;

  Future<void> _generateKeypair() async {
    final sp = await SharedPreferences.getInstance();
    if (_publicKey != null) {
      return;
    }
    if (sp.getString(SPKey.publicKey)?.isNotEmpty == true) {
      _publicKeyString = sp.getString(SPKey.publicKey);
      _privateKeyString = sp.getString(SPKey.privateKey);
      _publicKey = RSAHelper.decodeRSAKey(_publicKeyString!) as RSAPublicKey;
      _privateKey = RSAHelper.decodeRSAKey(_privateKeyString!, isPrivate: true) as RSAPrivateKey;
      return;
    }
    final keyPair = RSAHelper.generateKeypair();
    _privateKey = keyPair.privateKey;
    _privateKeyString = RSAHelper.encodeRSAKey(_privateKey!, isPrivate: true);
    _publicKey = keyPair.publicKey;
    _publicKeyString = RSAHelper.encodeRSAKey(_publicKey!);
    sp
      ..setString(SPKey.publicKey, _publicKeyString!)
      ..setString(SPKey.privateKey, _privateKeyString!);
  }

  Future<RSAPublicKey> getPublicKey() async {
    await _generateKeypair();
    return _publicKey!;
  }

  Future<String> getPublicKeyString() async {
    await _generateKeypair();
    return _publicKeyString!;
  }

  Future<RSAPrivateKey> getPrivateKey() async {
    await _generateKeypair();
    return _privateKey!;
  }

  Future<String> getPrivateKeyString() async {
    await _generateKeypair();
    return _privateKeyString!;
  }
}
