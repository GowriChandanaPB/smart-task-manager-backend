import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider =
    StreamProvider<ConnectivityResult>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) {
        // Take the first connectivity result
        // (list is never empty)
        return results.first;
      });
});