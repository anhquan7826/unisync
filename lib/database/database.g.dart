// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorUnisyncDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$UnisyncDatabaseBuilder databaseBuilder(String name) =>
      _$UnisyncDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$UnisyncDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$UnisyncDatabaseBuilder(null);
}

class _$UnisyncDatabaseBuilder {
  _$UnisyncDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$UnisyncDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$UnisyncDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<UnisyncDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$UnisyncDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$UnisyncDatabase extends UnisyncDatabase {
  _$UnisyncDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PairedDeviceDao? _pairedDeviceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `paired_devices` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `lastAccessed` INTEGER NOT NULL, `unpaired` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PairedDeviceDao get pairedDeviceDao {
    return _pairedDeviceDaoInstance ??=
        _$PairedDeviceDao(database, changeListener);
  }
}

class _$PairedDeviceDao extends PairedDeviceDao {
  _$PairedDeviceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _pairedDeviceEntityInsertionAdapter = InsertionAdapter(
            database,
            'paired_devices',
            (PairedDeviceEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'lastAccessed': item.lastAccessed,
                  'unpaired': item.unpaired ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PairedDeviceEntity>
      _pairedDeviceEntityInsertionAdapter;

  @override
  Future<List<PairedDeviceEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM paired_devices',
        mapper: (Map<String, Object?> row) => PairedDeviceEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            unpaired: (row['unpaired'] as int) != 0));
  }

  @override
  Future<PairedDeviceEntity?> get(String id) async {
    return _queryAdapter.query('SELECT * FROM paired_devices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PairedDeviceEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            unpaired: (row['unpaired'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<void> markUnpaired(String id) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE paired_devices SET unpaired = true WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> remove(String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM paired_devices WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int?> exist(String id) async {
    return _queryAdapter.query(
        'SELECT COUNT(id) FROM paired_devices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [id]);
  }

  @override
  Future<PairedDeviceEntity?> getLastUsed() async {
    return _queryAdapter.query(
        'SELECT * FROM paired_devices ORDER BY lastAccessed DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => PairedDeviceEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            type: row['type'] as String,
            unpaired: (row['unpaired'] as int) != 0));
  }

  @override
  Future<void> setLastUsed(
    String id,
    int lastAccessed,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE paired_devices SET lastAccessed = ?2 WHERE id = ?1',
        arguments: [id, lastAccessed]);
  }

  @override
  Future<void> add(PairedDeviceEntity device) async {
    await _pairedDeviceEntityInsertionAdapter.insert(
        device, OnConflictStrategy.replace);
  }
}
