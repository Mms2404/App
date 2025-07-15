import 'dart:convert';
import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'expense_edit_screen.dart';

final storage = FlutterSecureStorage();

class ExpenseListScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ExpenseListScreen({
    Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<dynamic> _expenses = [];
  bool _isLoading = true;
  String? _error;

  // yearly anf monthly expenses 
  String _expenseViewType = 'Total';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;



  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _logout() {
    widget.onLogout();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        _error = 'Unauthorized. Please login again.';
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.36.193.18:8000/api/expenses/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _expenses = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Failed to load expenses';
        _isLoading = false;
      });
    }
  }

  void _navigateToAdd() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ExpenseEditScreen()));
    _fetchExpenses(); 
  }

  void _navigateToEdit(dynamic expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseEditScreen(expense: expense),
      ),
    );
    _fetchExpenses(); 
  }

  double _calculateTotalExpenses() {
  return _expenses.fold(
    0.0,
    (total, expense) => total + (double.tryParse(expense['amount'].toString()) ?? 0.0),
  );
}


  double _calculateMonthlyExpenses(int month, int year) {
  return _expenses
      .where((expense) {
        final date = DateTime.tryParse(expense['date'] ?? '');
        return date != null && date.month == month && date.year == year;
      })
      .fold(0.0, (total, expense) => total + double.parse(expense['amount'].toString()));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios)),
        title: const Text('Your Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExpenses,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: AppColors.palegreen,
        foregroundColor: AppColors.black,
        tooltip: 'Add Expenses',
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _expenses.isEmpty
                    ? const Center(child: Text('No expenses found.'))
                    : Column(
                        children: [

                          Divider(thickness: 1, color: AppColors.palegreen,),

                          // by default total expenses shown 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // dropdown for Total/Monthly
                                  DropdownButton<String>(
                                    value: _expenseViewType,
                                    items: ['Total', 'Monthly'].map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text('$type Expenses'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _expenseViewType = val!;
                                      });
                                    },
                                  ),

                                  // if Monthly, show month/year picker
                                  if (_expenseViewType == 'Monthly') ...[
                                    DropdownButton<int>(
                                      value: _selectedMonth,
                                      items: List.generate(12, (i) => i + 1).map((month) {
                                        return DropdownMenuItem<int>(
                                          value: month,
                                          child: Text(
                                            '${DateTime(0, month).toLocal().toString().split('-')[1]}', 
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedMonth = val!;
                                        });
                                      },
                                    ),
                                    DropdownButton<int>(
                                      value: _selectedYear,
                                      items: List.generate(5, (i) => DateTime.now().year - i).map((year) {
                                        return DropdownMenuItem<int>(
                                          value: year,
                                          child: Text('$year'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedYear = val!;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              // displaying the total/monthly value
                              Text(
                                    _expenseViewType == 'Total'
                                        ? 'Rs. ${_calculateTotalExpenses().toStringAsFixed(2)}'
                                        : 'Rs. ${_calculateMonthlyExpenses(_selectedMonth, _selectedYear).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                            ],
                          ),

                          Divider(thickness: 1, color: AppColors.palegreen,),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _expenses.length,
                              itemBuilder: (context, index) {
                                final expense = _expenses[index];
                                return ListTile(
                                  title: Text(
                                    expense['title'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Rs. ${expense['amount']} - [${expense['category']}] - ${expense['date']}',
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => _navigateToEdit(expense),
                                    icon: Icon(Icons.edit),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}