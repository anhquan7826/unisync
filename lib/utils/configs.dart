import 'dart:convert';

import 'package:pointycastle/pointycastle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisync/utils/extensions/map.ext.dart';
import 'package:unisync/utils/extensions/scope.ext.dart';
import 'package:unisync/utils/extensions/string.ext.dart';

import '../database/unisync_database.dart';
import '../models/device_info/device_info.model.dart';
import 'constants/sp_key.dart';
import 'cryptography/cert.dart';
import 'cryptography/rsa.dart';
import 'preferences.dart';

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

  Future<DeviceInfo?> getLastUsedDevice() async {
    return (await AppPreferences.getString(SPKey.lastUsedDevice)).let((it) {
      if (it == null) {
        return null;
      }
      return DeviceInfo.fromJson(it.toMap());
    });
  }

  Future<void> setLastUsedDevice(DeviceInfo device) async {
    await AppPreferences.putString(SPKey.lastUsedDevice, device.toJson().toJsonString());
  }
}

class _AuthenticationConfig {
  _AuthenticationConfig._();

  String? _certificate;
  RSAPrivateKey? _privateKey;
  String? _privateKeyString;
  RSAPublicKey? _publicKey;
  String? _publicKeyString;

  Future<void> prepareCryptography() async {
    final sp = await SharedPreferences.getInstance();
    if (_publicKey != null) {
      return;
    }
    if (sp.getString(SPKey.publicKey)?.isNotEmpty == true) {
      _publicKeyString = sp.getString(SPKey.publicKey);
      _privateKeyString = sp.getString(SPKey.privateKey);
      _publicKey = RSAHelper.decodeRSAKey(_publicKeyString!) as RSAPublicKey;
      _privateKey = RSAHelper.decodeRSAKey(_privateKeyString!, isPrivate: true) as RSAPrivateKey;
      _certificate = sp.getString(SPKey.certificate);
      return;
    }
    final keyPair = RSAHelper.generateKeypair();
    _privateKey = keyPair.privateKey;
    _privateKeyString = RSAHelper.encodeRSAKey(_privateKey!, isPrivate: true);
    _publicKey = keyPair.publicKey;
    _publicKeyString = RSAHelper.encodeRSAKey(_publicKey!);
    _certificate = generateSelfSignedCertificate();
    sp
      ..setString(SPKey.publicKey, _publicKeyString!)
      ..setString(SPKey.privateKey, _privateKeyString!)
      ..setString(SPKey.certificate, _certificate!);
  }

  RSAPublicKey getPublicKey() {
    return _publicKey!;
  }

  String getPublicKeyString() {
    return _publicKeyString!;
  }

  RSAPrivateKey getPrivateKey() {
    return _privateKey!;
  }

  String getPrivateKeyString() {
    return _privateKeyString!;
  }

  String getCertificate() {
    return _certificate!;
  }
}
