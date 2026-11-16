import 'package:flutter/foundation.dart';

import '../../../core/database/database.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_repository.dart';
import 'pokemon_local_datasource.dart';
import 'pokemon_remote_datasource.dart';
import 'pokemon_dto.dart';

/// Implementacion del repositorio offline-first: repositorio local es la fuente de verdad y el servicio remoto la alimenta.
class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    required this.local,
    required this.remote,
    required this.database,
  });

  final PokemonLocalDataSource local;
  final PokemonRemoteDataSource remote;
  final AppDatabase database;

  static const String catalogResource = 'pokedex';

  static const int pageSize = 100;

  @override
  Stream<List<PokemonSummary>> watchCatalog() async* {
    yield await local.queryCatalog();
    await for (final int _ in database.changes) {
      yield await local.queryCatalog();
    }
  }

  @override
  Future<void> syncCatalog() async {
    final int total = await remote.catalogTotal();

    int offset = 0;
    while (offset < total) {
      final List<PokemonDto> page = await remote.fetchCatalogPage(
        limit: pageSize,
        offset: offset,
      );
      if (page.isEmpty) break;

      await database.writeTransaction(() => local.upsertSummaries(page));

      offset += page.length;
      await local.saveSyncState(
        resource: catalogResource,
        lastSyncedAt: DateTime.now(),
        status: 'syncing',
        nextPage: '$total',
        message: '$offset/$total',
      );
    }

    await local.saveSyncState(
      resource: catalogResource,
      lastSyncedAt: DateTime.now(),
      status: 'completed',
      nextPage: '$total',
      message: 'pagina syncronizada ($offset)',
    );
    debugPrint('[Pokedex] catalogo sincronizado: $offset/$total');
  }
}
