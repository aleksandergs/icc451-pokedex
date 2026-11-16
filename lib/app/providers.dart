import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/database.dart';
import '../core/network/graphql_client.dart';
import '../core/sync/connectivity_monitor.dart';
import '../core/sync/sync_service.dart';
import '../core/sync/sync_state.dart';
import '../features/pokemon/data/pokemon_local_datasource.dart';
import '../features/pokemon/data/pokemon_remote_datasource.dart';
import '../features/pokemon/data/pokemon_repository_impl.dart';
import '../features/pokemon/domain/pokemon.dart';
import '../features/pokemon/domain/pokemon_repository.dart';

/// Dependencias de la app construidas en el arranque
class AppDependencies {
  AppDependencies({
    required this.database,
    required this.client,
    required this.monitor,
    required this.syncService,
    required this.pokemonRepository,
  });

  final AppDatabase database;
  final GraphQlClient client;
  final ConnectivityMonitor monitor;
  final SyncService syncService;
  final PokemonRepository pokemonRepository;

  static Future<AppDependencies> create() async {
    final AppDatabase database = await AppDatabase.open();

    final GraphQlClient client = GraphQlClient(
      endpoint: Uri.parse('https://graphql.pokeapi.co/v1beta2'),
    );

    final PokemonRepository pokemonRepository = PokemonRepositoryImpl(
      local: PokemonLocalDataSource(database),
      remote: PokemonRemoteDataSource(client),
      database: database,
    );

    final ConnectivityMonitor monitor = ConnectivityMonitor();
    final SyncService syncService = SyncService(
      repository: pokemonRepository,
      monitor: monitor,
    );

    return AppDependencies(
      database: database,
      client: client,
      monitor: monitor,
      syncService: syncService,
      pokemonRepository: pokemonRepository,
    );
  }
}

final Provider<AppDependencies> appDependenciesProvider =
    Provider<AppDependencies>(
      (Ref ref) => throw UnimplementedError('appDependenciesProvider'),
    );

final Provider<PokemonRepository> pokemonRepositoryProvider =
    Provider<PokemonRepository>(
      (Ref ref) => ref.watch(appDependenciesProvider).pokemonRepository,
    );

final Provider<SyncService> syncServiceProvider = Provider<SyncService>(
  (Ref ref) => ref.watch(appDependenciesProvider).syncService,
);

final StreamProvider<List<PokemonSummary>> catalogProvider =
    StreamProvider<List<PokemonSummary>>(
      isAutoDispose: true,
      (Ref ref) => ref.watch(pokemonRepositoryProvider).watchCatalog(),
    );

/// Estado global de conexion que alimenta el indicador
final StreamProvider<SyncState> syncStateProvider = StreamProvider<SyncState>(
  (Ref ref) => ref.watch(syncServiceProvider).stream,
);
