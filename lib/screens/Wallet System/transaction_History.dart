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

  // Function to pick date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Map<String, dynamic>? user;

  Map<String, dynamic>? walletData;

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;

  final DioService _apiService = DioService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    if (user != null) {
      ;
      await loadTransactions();
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
    }
  }

  // Function to show filter modal
  void _showFilterModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.grey),
                        Text('Sort & Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: _buildDateField('Start Date', _startDate),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: _buildDateField('End Date', _endDate),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Payment', 'Send', 'Top Up', 'Request', 'Bill'].map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text('Sort', style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: ['Newest', 'Oldest'].map((order) {
                      return RadioListTile(
                        title: Text(order),
                        value: order,
                        groupValue: _sortOrder,
                        onChanged: (value) {
                          setState(() {
                            _sortOrder = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _selectedCategory = 'All';
                              _sortOrder = 'Newest';
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Reset'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Show'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField(String text, DateTime? date) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date != null ? DateFormat.yMd().format(date) : text),
          Icon(Icons.calendar_today, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transaction History'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterModal,
            ),
          ],
          bottom: TabBar(
            // labelColor: Colors.white,
            // unselectedLabelColor: Colors.black,
            // indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            inProgressTransactions(context),
            completedTransactions(context),
          ],
        ),
      ),
    );
  }

  Widget inProgressTransactions(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTransactionItem(Icons.check_circle, 'Payment Received', 'Transaction ID: 54321', '\$75.00', Colors.green),
        _buildTransactionItem(Icons.check_circle, 'Payment Sent', 'Transaction ID: 98765', '\$200.00', Colors.green),
      ],
    );
  }
  Widget _buildTransactionItem(IconData icon, String title, String subtitle, String amount, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget completedTransactions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          bool isCredit = tx['type'] == 'credit';

          return Card(
            child: ListTile(
              leading: Icon(
                isCredit ? LucideIcons.creditCard : LucideIcons.ticket,
                color: isCredit ? Colors.green : Colors.red,
              ),
              title: Text(tx['description'] ?? ''),
              subtitle: Text(
                DateFormat('EEEE, MMMM yyyy')
                    .format(DateTime.parse(tx['created_at'])),
              ),
              trailing: Text(
                '${isCredit ? "+" : "-"}${tx['amount'] ?? "0"}',
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentReceiptScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

}
