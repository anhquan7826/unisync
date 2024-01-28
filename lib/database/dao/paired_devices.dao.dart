import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/device_info/device_info.model.dart';
import '../unisync_database.dart';

class PairedDeviceDao {
  PairedDeviceDao(this._database);

  final Database _database;

  Future<List<DeviceInfo>> getAll() async {
    return (await _database.query(UnisyncDatabase.PAIRED_DEVICES)).map((e) {
      return DeviceInfo.fromJson(e);
    }).toList();
  }

  Future<void> add(DeviceInfo device) async {
    await _database.insert(
      UnisyncDatabase.PAIRED_DEVICES,
      device.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String deviceId) async {
    await _database.delete(
      UnisyncDatabase.PAIRED_DEVICES,
      where: 'id = $deviceId',
    );
  }

  Future<bool> exist(String deviceId) async {
    return (await _database.query(UnisyncDatabase.PAIRED_DEVICES, where: 'id = $deviceId')).isNotEmpty;
  }
}
