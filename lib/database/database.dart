import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/paired_device.dao.dart';
import 'entity/paired_device.entity.dart';

part 'database.g.dart';

@Database(version: 1, entities: [PairedDeviceEntity])
abstract class UnisyncDatabase extends FloorDatabase {
  PairedDeviceDao get pairedDeviceDao;
}
