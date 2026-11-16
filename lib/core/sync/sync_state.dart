import '../errors/failure.dart';

enum ConnectionStatus { online, offline }

class SyncState {
  const SyncState({
    this.connection = ConnectionStatus.offline,
    this.syncing = false,
    this.error,
  });

  final ConnectionStatus connection;

  final bool syncing;

  final AppFailure? error;

  bool get isOnline => connection == ConnectionStatus.online;

  SyncState copyWith({
    ConnectionStatus? connection,
    bool? syncing,
    AppFailure? error,
    bool clearError = false,
  }) => SyncState(
    connection: connection ?? this.connection,
    syncing: syncing ?? this.syncing,
    error: clearError ? null : (error ?? this.error),
  );
}
