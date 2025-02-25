import 'package:flutter/cupertino.dart';

import '../services/dio.dart';

class WalletProvider extends ChangeNotifier {
  final DioService _apiService = DioService();
  Map<String, dynamic>? _walletData;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingWallet = false;
  bool _isLoadingTransactions = false;
  bool _hasLoadedTransactions = false; // NEW FLAG

  Map<String, dynamic>? get walletData => _walletData;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoadingWallet => _isLoadingWallet;
  bool get isLoadingTransactions => _isLoadingTransactions;

  Future<void> loadWalletBalance(String userId) async {
    _isLoadingWallet = true;
    notifyListeners();

    try {
      final response = await _apiService.postRequest('wallet/balance', {
        "userId": userId,
      });

      if (response != null && response.data['success'] == true) {
        _walletData = response.data['wallet'];
      } else {
        _walletData = {};
      }
    } catch (e) {
      _walletData = {};
    }

    _isLoadingWallet = false;
    notifyListeners();
  }

  Future<void> loadTransactions(String userId, {bool forceReload = false}) async {
    if (_hasLoadedTransactions && !forceReload) return; // Skip if already loaded

    _isLoadingTransactions = true;
    notifyListeners();

    try {
      final response = await _apiService.postRequest('wallet/getTransactions', {
        "userId": userId,
      });

      if (response != null && response.data['success'] == true) {
        _transactions = List<Map<String, dynamic>>.from(response.data['transactions']);
        _hasLoadedTransactions = true; // Mark as loaded
      } else {
        _transactions = [];
      }
    } catch (e) {
      _transactions = [];
    }

    _isLoadingTransactions = false;
    notifyListeners();
  }
}
