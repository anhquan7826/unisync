// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dao/paired_devices.dao.dart';
import 'dao/stored_messages.dao.dart';

class UnisyncDatabase {
  UnisyncDatabase._();

  static const PAIRED_DEVICES = 'paired_devices';
  static const STORED_MESSAGES = 'stored_messages';

  static bool _initialized = false;
  static late final Database _database;

  static Future<void> initialize() async {
    if (!_initialized) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String dbPath = join(appDocumentsDir.path, 'databases', 'unisync_database.db');
      _database = await databaseFactory.openDatabase(dbPath);
      try {
        await _database.execute('CREATE TABLE $PAIRED_DEVICES(id VARCHAR(50) PRIMARY KEY, name VARCHAR(30), publicKey TEXT, deviceType VARCHAR(5))');
        // await _database.execute(
        //     'CREATE TABLE $STORED_MESSAGES(id INT PRIMARY KEY NOT NULL AUTO_INCREMENT, fromDeviceId VARCHAR(50), toDeviceId VARCHAR(50), plugin VARCHAR(20), function VARCHAR(20), extra TEXT)');
      } catch (_) {}
      _initialized = true;
    }
  }

  static final pairedDeviceDao = PairedDeviceDao(_database);

  static final storedMessageDao = StoredMessageDao(_database);
}
