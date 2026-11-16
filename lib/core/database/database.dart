import 'dart:async';

import 'package:drift/drift.dart';

import 'tables.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Database local usando drift
@DriftDatabase(
  tables: <Type>[Pokemon, TypeTable, PokemonType, Favorite, SyncState],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  final StreamController<int> _changes = StreamController<int>.broadcast();
  int _revision = 0;

  /// Broadcast cada vez que se realiza una escritura.
  Stream<int> get changes => _changes.stream;

  int get revision => _revision;

  void notifyChanged() {
    if (_changes.isClosed) return;
    _revision++;
    _changes.add(_revision);
  }

  static Future<AppDatabase> open({String? databaseName}) async {
    final Directory folder = await getApplicationSupportDirectory();
    return openAt(p.join(folder.path, databaseName ?? 'pokedex.db'));
  }

  static Future<AppDatabase> openAt(String dbPath) async {
    return AppDatabase(await NativeDatabase.createInBackground(File((dbPath))));
  }

  Future<T> writeTransaction<T>(Future<T> Function() action) async {
    final T result = await transaction<T>(action);
    notifyChanged();
    return result;
  }

  @override
  int get schemaVersion => 1;

  /// Sin el pragma sqlite no borra en cascada
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => m.createAll(),
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  @override
  Future<void> close() async {
    await _changes.close();
    return super.close();
  }
}
