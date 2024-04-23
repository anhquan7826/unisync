import 'package:floor/floor.dart';
import 'package:unisync/database/entity/paired_device.entity.dart';
import 'package:unisync/database/tables.dart';

@dao
abstract class PairedDeviceDao {
  @Query('SELECT * FROM paired_devices')
  Future<List<PairedDeviceEntity>> getAll();

  @Query('SELECT * FROM paired_devices WHERE id = :id')
  Future<PairedDeviceEntity?> get(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> add(PairedDeviceEntity device);

  @Query('UPDATE ${DBTables.PAIRED_DEVICES} SET unpaired = true WHERE id = :id')
  Future<void> markUnpaired(String id);

  @Query('DELETE FROM ${DBTables.PAIRED_DEVICES} WHERE id = :id')
  Future<void> remove(String id);

  @Query('SELECT COUNT(id) FROM ${DBTables.PAIRED_DEVICES} WHERE id = :id')
  Future<int?> exist(String id);

  @Query('SELECT * FROM ${DBTables.PAIRED_DEVICES} ORDER BY lastAccessed DESC LIMIT 1')
  Future<PairedDeviceEntity?> getLastUsed();

  @Query('UPDATE ${DBTables.PAIRED_DEVICES} SET lastAccessed = :lastAccessed WHERE id = :id')
  Future<void> setLastUsed(String id, int lastAccessed);
}
