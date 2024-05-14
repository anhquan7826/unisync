import 'package:floor/floor.dart';

import '../tables.dart';

@Entity(tableName: DBTables.PAIRED_DEVICES)
class PairedDeviceEntity {
  PairedDeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    this.unpaired = 0,
  }) {
    lastAccessed = DateTime.now().millisecondsSinceEpoch;
  }

  @primaryKey
  final String id;
  final String name;
  final String type;
  late final int lastAccessed;
  final int unpaired;
}
