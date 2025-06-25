import 'dart:convert';
import 'package:app/common/textField.dart';
import 'package:app/common/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

class ExpenseEditScreen extends StatefulWidget {
  final dynamic expense; 
  const ExpenseEditScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<ExpenseEditScreen> createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends State<ExpenseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _titleController = TextEditingController(text: expense?['title'] ?? '');
    _amountController = TextEditingController(text: expense?['amount']?.toString() ?? '');
    _categoryController = TextEditingController(text: expense?['category'] ?? '');
    _dateController = TextEditingController(text: expense?['date'] ?? '');
    _descriptionController = TextEditingController(text: expense?['description'] ?? '');
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      setState(() {
        _error = 'Unauthorized. Please login again.';
        _isSaving = false;
      });
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'amount':_amountController.text.trim(),
      'category': _categoryController.text.trim(),
      'date': _dateController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    final isEdit = widget.expense != null;
    final url = isEdit
        ? 'http://192.168.84.18:8000/api/expenses/${widget.expense!['id']}/'
        : 'http://192.168.84.18:8000/api/expenses/';

    final response = await (isEdit
        ? http.put(Uri.parse(url),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data))
        : http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data)));

    setState(() {
      _isSaving = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = 'Failed to save expense (Status: ${response.statusCode})';
      });
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios)),
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                AppTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                ),
                AppTextField(
                  controller: _amountController,
                  labelText: 'Amount',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
                ),
                AppTextField(
                  controller: _categoryController,
                  labelText: 'Category',
                  validator: (v) => v == null || v.isEmpty ? 'Enter category' : null,
                ),
                AppTextField(
                  controller: _dateController,
                  labelText: 'Date (YYYY-MM-DD)',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter date';
                    final regExp = RegExp(r'\d{4}-\d{2}-\d{2}');
                    if (!regExp.hasMatch(v)) return 'Date must be YYYY-MM-DD';
                    return null;
                  },
                ),
                AppTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                ),
                const SizedBox(height: 40),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveExpense,
                        style: AppButtonStyles.commonButton,
                        child: Text(isEdit ? 'Update' : 'Add'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}