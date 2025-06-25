import 'dart:convert';
import 'package:app/common/buttons.dart';
import 'package:app/common/textField.dart';
import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

class ExpenseLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const ExpenseLoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<ExpenseLoginScreen> createState() => _ExpenseLoginScreenState();
}

class _ExpenseLoginScreenState extends State<ExpenseLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    var response = await http.post(
      Uri.parse('http://192.168.84.18:8000/api-token-auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['token'] != null) {
        await storage.write(key: 'auth_token', value: data['token']);
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorText = 'Invalid response: token missing';
        });
      }
    } else {
      setState(() {
        _errorText = 'Login failed: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              height: 500,
              width: 400,
              child: Column(
                children: [
                Text("EXPENSE TRACKER" , style: TextStyle(fontSize: 30 ,fontWeight: FontWeight.bold),),
                Text("Login and continue managing your expenses" , style: TextStyle(fontSize: 20 ,color: AppColors.palegreen),textAlign: TextAlign.center),

                SizedBox(height: 30,),

                AppTextField(
                  controller: _usernameController,
                  labelText: "Username",
                ),

                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 50),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: AppButtonStyles.commonButton,
                        child: const Text('LOGIN'),
                      ),

                if (_errorText != null) ...[
                  SizedBox(height: 12),
                  Text(_errorText!, style: const TextStyle(color: Colors.red)),
                ],

               SizedBox(height: 12),
               GestureDetector(
                onTap: (){},
                child: Text("New to Expense Tracker ? Sign up ." ,))
              ]
            ),
            ),
          ),
        ));
  }
}