import 'package:unisync_backend/utils/extensions/map.ext.dart';
import 'package:unisync_backend/utils/extensions/scope.ext.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/device_message/device_message.model.dart';
import '../unisync_database.dart';

class StoredMessageDao {
  StoredMessageDao(this._database);

  final Database _database;

  Future<bool> push(DeviceMessage message) async {
    final result = await _database.insert(
      UnisyncDatabase.STORED_MESSAGES,
      message.toJson().let((it) {
        it['extra'] = (it['extra'] as Map).toJsonString();
        return it;
      }),
    );
    return result > 0;
  }

  Future<DeviceMessage?> pop() async {
    final result = await _database.query('SELECT * FROM ${UnisyncDatabase.STORED_MESSAGES} ORDER BY your_column DESC LIMIT 1;');
    if (result.isEmpty) {
      return null;
    }
    await _database.delete(UnisyncDatabase.STORED_MESSAGES, where: 'id = ${result.first['id']}');
    return DeviceMessage.fromJson(result.first);
  }
}
