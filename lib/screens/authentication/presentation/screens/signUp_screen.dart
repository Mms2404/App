import 'package:app/common/buttons.dart';
import 'package:app/common/textField.dart';
import 'package:app/screens/authentication/presentation/screens/verification_screen.dart';
import 'package:app/utils/enum.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordView() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Proceed to verification screen with email or phone passed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            contactInfo: _emailController.text.trim(),
            contactType: ContactType.email,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Text(
              "SIGN UP",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50,),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Name
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email
                  AppTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                   },
                 ),
                  SizedBox(height: 16),

                  // Phone Number
                  AppTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.trim().length < 7) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: _togglePasswordView,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Confirm Password
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: _toggleConfirmPasswordView,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  SizedBox(height: 80),

                  ElevatedButton(
                    onPressed: _submit,
                    style: AppButtonStyles.commonButton,
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
