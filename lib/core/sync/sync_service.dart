import 'dart:async';

import '../../features/pokemon/domain/pokemon_repository.dart';
import '../errors/failure.dart';
import 'connectivity_monitor.dart';
import 'sync_state.dart';

/// Coordina la sincronizacion remoto a local.
class SyncService {
  SyncService({required this.repository, required this.monitor});

  final PokemonRepository repository;
  final ConnectivityMonitor monitor;

  final StreamController<SyncState> _controller =
      StreamController<SyncState>.broadcast();
  StreamSubscription<bool>? _networkSubscription;
  SyncState _state = const SyncState();
  bool _disposed = false;

  SyncState get state => _state;

  /// stream del estado global observable.
  Stream<SyncState> get stream async* {
    /// iniciamos con _state para que los nuevos suscriptores obtengan el estado actual sin esperar un cambio
    yield _state;
    yield* _controller.stream;
  }

  void _emit(SyncState next) {
    _state = next;
    if (!_disposed && !_controller.isClosed) _controller.add(next);
  }

  Future<void> start() async {
    final bool online = await monitor.isOnline;
    _emit(
      _state.copyWith(
        connection: online ? ConnectionStatus.online : ConnectionStatus.offline,
      ),
    );

    _networkSubscription = monitor.onChanged.listen((bool online) {
      final ConnectionStatus next = online
          ? ConnectionStatus.online
          : ConnectionStatus.offline;
      if (next == _state.connection) return;
      _emit(_state.copyWith(connection: next));
      if (online) unawaited(syncCatalog());
    });

    if (online) await syncCatalog();
  }

  /// descarga el catalogo completo. Si ya hay una sincronizacion en curso la llamada se ignora.
  Future<void> syncCatalog() async {
    if (_state.syncing) return;

    if (!_state.isOnline) {
      _emit(_state.copyWith(error: const AppFailure(FailureType.noConnection)));
      return;
    }

    _emit(_state.copyWith(syncing: true, clearError: true));
    try {
      await repository.syncCatalog();
      _emit(_state.copyWith(syncing: false, clearError: true));
    } on AppFailure catch (failure) {
      _emit(_state.copyWith(syncing: false, error: failure));
    } on Object catch (error) {
      _emit(
        _state.copyWith(
          syncing: false,
          error: AppFailure(FailureType.unknown, message: '$error'),
        ),
      );
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _networkSubscription?.cancel();
    await _controller.close();
  }
}