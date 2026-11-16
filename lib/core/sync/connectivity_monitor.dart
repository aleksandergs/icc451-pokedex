import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitor de conectividad del dispositivo: informa si hay alguna red activa
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// `true` si el sistema reporta Wi-Fi, data, etc.
  Future<bool> get isOnline async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  Stream<bool> get onChanged =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();

  bool _hasNetwork(List<ConnectivityResult> results) => results.any(
    (ConnectivityResult result) => result != ConnectivityResult.none,
  );
}
