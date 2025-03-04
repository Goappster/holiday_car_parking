import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    checkConnectivity(); // ✅ Now it's public
    _listenToConnectivityChanges();
  }

  /// Check initial connectivity (Now public)
  void checkConnectivity() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    if (results.isNotEmpty) {
      _updateConnectionStatus(results.first);
    } else {
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  /// Listen for real-time connectivity changes
  void _listenToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      } else {
        _updateConnectionStatus(ConnectivityResult.none);
      }
    });
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(ConnectivityResult result) {
    bool newStatus = result == ConnectivityResult.wifi || result == ConnectivityResult.mobile;
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      notifyListeners();
    }
  }
}
