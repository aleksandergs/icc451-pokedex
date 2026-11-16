import 'package:drift/drift.dart';

@DataClassName('PokemonData')
@TableIndex(name: 'idx_pokemon_name', columns: {#name})
@TableIndex(name: 'idx_pokemon_dex', columns: {#pokedexNumber})
@TableIndex(name: 'idx_pokemon_species', columns: {#speciesId})
@TableIndex(name: 'idx_pokemon_generation', columns: {#generationId})
class Pokemon extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get speciesId => integer()();
  IntColumn get pokedexNumber => integer()();
  IntColumn get generationId => integer().nullable()();
  TextColumn get generationName => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TypeData')
class TypeTable extends Table {
  @override
  String get tableName => 'type';
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('PokemonTypeData')
@TableIndex(name: 'idx_pokemon_type_type', columns: {#typeId})
class PokemonType extends Table {
  IntColumn get pokemonId =>
      integer().references(Pokemon, #id, onDelete: KeyAction.cascade)();
  IntColumn get typeId =>
      integer().references(TypeTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get slot => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{pokemonId, typeId};
}

@DataClassName('FavoriteData')
class Favorite extends Table {
  IntColumn get pokemonId =>
      integer().references(Pokemon, #id, onDelete: KeyAction.cascade)();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{pokemonId};
}

@DataClassName('SyncStateData')
class SyncState extends Table {
  TextColumn get resource => text()();
  IntColumn get lastSyncedAt => integer().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get nextPage => text().nullable()();
  TextColumn get message => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{resource};
}
