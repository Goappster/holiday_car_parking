import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/dio.dart';
import '../Booking/PaymentReceiptScreen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'All';
  String _sortOrder = 'Newest';

  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> withdrawStatus = [];

  bool isLoading = true;
  bool isLoadingTransactions = false;
  bool isLoadingWithdrawStatus = false;

  final DioService _apiService = DioService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);
    await _loadUserData();
    if (user != null) {
      await loadTransactions();
      await loadWithdrawStatus();
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user');

    if (userData != null) {
      try {
        setState(() {
          user = json.decode(userData);
        });
      } catch (e) {
        user = null;
      }
    }
  }

  Future<void> loadTransactions() async {
    if (user == null || user?['id'] == null) return;
    setState(() => isLoadingTransactions = true);
    try {
      final response = await _apiService.postRequest('wallet/getTransactions', {
        "userId": user!['id'].toString(),
      });
      setState(() {
        if (response != null && response.data['success'] == true) {
          transactions = List<Map<String, dynamic>>.from(response.data['transactions']);
        } else {
          transactions = [];
        }
      });
    } catch (e) {
      setState(() => transactions = []);
    } finally {
      setState(() => isLoadingTransactions = false);
    }
  }

  Future<void> loadWithdrawStatus() async {
    if (user == null || user?['id'] == null) return;
    setState(() => isLoadingWithdrawStatus = true);
    try {
      final response = await _apiService.postRequest('wallet/withdrawRequestStatus', {
        "userId": user!['id'].toString(),
      });
      setState(() {
        if (response?.data['success'] == true) {
          withdrawStatus = List<Map<String, dynamic>>.from(response?.data['withdraw_request']['data']);
        } else {
          withdrawStatus = [];
        }
      });
    } catch (e) {
      setState(() => withdrawStatus = []);
    } finally {
      setState(() => isLoadingWithdrawStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transaction History'),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            inProgressTransactions(context),
            completedTransactions(context),
          ],
        ),
      ),
    );
  }


  Widget inProgressTransactions(BuildContext context) {
    if (isLoadingWithdrawStatus) {
      return Center(child: CircularProgressIndicator());
    }
    if (withdrawStatus.isEmpty) {
      return Center(child: Text('No transactions found'));
    }

    // Function to determine color based on status
    Color getStatusColor(String status) {
      switch (status) {
        case "Request Received":
          return Colors.orange; // Request Received
        case "Sent to Accounts Department":
          return Colors.blue; // Sent to Accounts Department
        case "Withdraw Approved":
          return Colors.orange; // Withdraw Approved
        case "Posted to Account":
          return Colors.green; // Posted to Account
        default:
          return Colors.black; // Default color
      }
    }

    // Function to get icon based on status
    IconData getStatusIcon(String status) {
      switch (status) {
        case "Request Received":
          return Icons.hourglass_empty; // Request Received (Pending)
        case "Sent to Accounts Department":
          return Icons.account_balance; // Sent to Accounts Department
        case "Withdraw Approved":
          return Icons.check_circle_outline; // Withdraw Approved
        case "Posted to Account":
          return Icons.account_balance_wallet; // Posted to Account
        default:
          return Icons.help_outline; // Default icon
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: withdrawStatus.length,
        itemBuilder: (context, index) {
          final tx = withdrawStatus[index];
          bool isCredit = tx['type'] == 'credit';
          String status = tx['status'] ?? 'N/A';
          Color statusColor = getStatusColor(status);
          IconData statusIcon = getStatusIcon(status);

          return Card(
            child: ListTile(
              leading: Icon(statusIcon, color: statusColor), // Add icon
              title: Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(tx['created_at'] ?? ''),
              trailing: Text(
                '\$${tx['amount'] ?? '0.00'}',
                style: TextStyle(color: isCredit ? Colors.green : Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget completedTransactions(BuildContext context) {
    if (isLoadingTransactions) {
      return Center(child: CircularProgressIndicator());
    }
    if (transactions.isEmpty) {
      return Center(child: Text('No transactions found'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          bool isCredit = tx['type'] == 'credit';
          return Card(
            child: ListTile(
              title: Text(tx['description'] ?? ''),
              subtitle: Text(DateFormat('EEEE MMMM yyyy hh:mm a').format(DateTime.parse(tx['created_at'])),),
              trailing: Text(
                '${isCredit ? "+" : "-"}${tx['amount'] ?? "0"}',
                style: TextStyle(color: isCredit ? Colors.green : Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
