// Network info
// lib/core/network/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) => results.first);
  }
}
