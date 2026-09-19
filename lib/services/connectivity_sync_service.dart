import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'local_data_service.dart';

/// Watches network connectivity and retries queued offline writes when the
/// device transitions from offline to online.
class ConnectivitySyncService {
  ConnectivitySyncService._();

  static final ConnectivitySyncService instance =
      ConnectivitySyncService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _hasConnection = false;
  bool _isSyncing = false;

  Future<void> start() async {
    if (_subscription != null) return;

    final initialState = await _connectivity.checkConnectivity();
    _hasConnection = _isConnected(initialState);

    if (_hasConnection) {
      await syncPending();
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        unawaited(_handleConnectivityChange(results));
      },
    );
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final connected = _isConnected(results);

    if (!_hasConnection && connected) {
      await syncPending();
    }

    _hasConnection = connected;
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      await LocalDataService.instance.syncPending();
    } finally {
      _isSyncing = false;
    }
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
