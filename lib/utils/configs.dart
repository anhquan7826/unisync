import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unisync/constants/sp_key.dart';
import 'package:unisync/database/unisync_database.dart';
import 'package:unisync/utils/converters.dart';
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
      _publicKey = publicKeyFromPEM(_publicKeyString!);
      _privateKey = privateKeyFromPEM(_privateKeyString!);
      return;
    }
    final keyParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
    final keyGenerator = RSAKeyGenerator()..init(ParametersWithRandom(keyParams, _getSecureRandom()));
    final keyPair = keyGenerator.generateKeyPair();
    _privateKey = keyPair.privateKey as RSAPrivateKey;
    _privateKeyString = rsaKeyToPEM(privateKey: _privateKey);
    _publicKey = keyPair.publicKey as RSAPublicKey;
    _publicKeyString = rsaKeyToPEM(publicKey: _publicKey);
    sp
      ..setString(SPKey.publicKey, _publicKeyString!)
      ..setString(SPKey.privateKey, _privateKeyString!);
  }

  SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
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
