import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unisync/database/unisync_database.dart';
import 'package:unisync/models/device_info/device_info.model.dart';

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

  Future<void> remove(DeviceInfo device) async {
    await _database.delete(
      UnisyncDatabase.PAIRED_DEVICES,
      where: 'id = ${device.id}',
    );
  }
}
