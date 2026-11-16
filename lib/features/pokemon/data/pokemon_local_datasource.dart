import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../domain/pokemon.dart';
import 'pokemon_dto.dart';

/// Acceso a la base local del catalogo
class PokemonLocalDataSource {
  PokemonLocalDataSource(this._db);

  final AppDatabase _db;

  // ------------------------------- Lecturas -------------------------------

  /// Lista el catalogo ordenado por número de Pokedex
  Future<List<PokemonSummary>> queryCatalog({
    int offset = 0,
    int? limit,
  }) async {
    final List<QueryRow> rows = await _db
        .customSelect(
          'SELECT p.*, (f.pokemon_id IS NOT NULL) AS is_favorite '
          'FROM pokemon p '
          'LEFT JOIN favorite f ON f.pokemon_id = p.id '
          'ORDER BY p.pokemon_dex ASC '
          'LIMIT ? OFFSET ?',
          variables: <Variable<Object>>[
            Variable<int>(limit ?? -1),
            Variable<int>(offset),
          ],
          readsFrom: <ResultSetImplementation<HasResultSet, dynamic>>{
            _db.pokemon,
            _db.favorite,
          },
        )
        .get();
    if (rows.isEmpty) return <PokemonSummary>[];

    final List<int> ids = rows
        .map((QueryRow row) => row.read<int>('id'))
        .toList(growable: false);
    final List<PokemonTypeData> TypeDatas = await (_db.select(
      _db.pokemonType,
    )..where((PokemonType t) => t.pokemonId.isIn(ids))).get();

    final List<TypeData> typeNames = await _db.select(_db.typeTable).get();
    final Map<int, String> nameById = <int, String>{
      for (final TypeData t in typeNames) t.id: t.name,
    };

    final Map<int, List<PokeType>> typesByPokemon = <int, List<PokeType>>{};
    for (final PokemonTypeData row in TypeDatas) {
      (typesByPokemon[row.pokemonId] ??= <PokeType>[]).add(
        PokeType(id: row.typeId, name: nameById[row.typeId] ?? ''),
      );
    }

    return rows
        .map((QueryRow row) {
          final int id = row.read<int>('id');
          return PokemonSummary(
            id: id,
            name: row.read<String>('name'),
            speciesId: row.read<int>('pokemon_species_id'),
            pokedexNumber: row.read<int>('pokemon_dex'),
            generationId: row.readNullable<int>('generation_id') ?? 0,
            generationName: row.readNullable<String>('generation_name') ?? '',
            types: typesByPokemon[id] ?? const <PokeType>[],
          );
        })
        .toList(growable: false);
  }

  Future<int> countLocal() async {
    final QueryRow row = await _db
        .customSelect('SELECT COUNT(*) AS c FROM pokemon')
        .getSingle();
    return row.read<int>('c');
  }

  // ------------------------------ Escrituras ------------------------------

  /// Añade o actualiza una página del catálogo.
  Future<void> upsertSummaries(List<PokemonDto> items) async {
    if (items.isEmpty) return;

    await _db.batch((Batch batch) {
      for (final PokemonDto dto in items) {
        final PokemonCompanion summary = PokemonCompanion(
          id: Value<int>(dto.id),
          name: Value<String>(dto.name),
          speciesId: Value<int>(dto.speciesId),
          pokedexNumber: Value<int>(dto.pokedexNumber),
          generationId: Value<int?>(dto.generationId),
          generationName: Value<String?>(dto.generationName),
          updatedAt: Value<int>(DateTime.now().millisecondsSinceEpoch),
        );

        batch.insert(
          _db.pokemon,
          summary,
          onConflict: DoUpdate<$PokemonTable, PokemonData>(
            ($PokemonTable old) => summary,
          ),
        );

        for (final PokeType type in dto.types) {
          final TypeData data = TypeData(id: type.id, name: type.name);
          batch.insert(
            _db.typeTable,
            data,
            onConflict: DoUpdate<$TypeTableTable, TypeData>(
              ($TypeTableTable old) => data,
            ),
          );
        }

        batch.deleteWhere(
          _db.pokemonType,
          (PokemonType t) => t.pokemonId.equals(dto.id),
        );
        for (int i = 0; i < dto.types.length; i++) {
          batch.insert(
            _db.pokemonType,
            PokemonTypeData(
              pokemonId: dto.id,
              typeId: dto.types[i].id,
              slot: i + 1,
            ),
          );
        }
      }
    });
  }

  Future<void> saveSyncState({
    required String resource,
    required DateTime lastSyncedAt,
    required String status,
    String? nextPage,
    String? message,
  }) async {
    await _db
        .into(_db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion(
            resource: Value<String>(resource),
            lastSyncedAt: Value<int?>(lastSyncedAt.millisecondsSinceEpoch),
            status: Value<String?>(status),
            nextPage: Value<String?>(nextPage),
            message: Value<String?>(message),
          ),
        );
    _db.notifyChanged();
  }
}
