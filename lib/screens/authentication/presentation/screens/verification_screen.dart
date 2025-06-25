import 'package:app/common/buttons.dart';
import 'package:app/constants/colors.dart';
import 'package:app/screens/home.dart';
import 'package:app/utils/enum.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  final String contactInfo;
  final ContactType contactType;

  VerificationScreen({required this.contactInfo, required this.contactType});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeSent = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification successful!')),
      );
      Navigator.push(context,
      MaterialPageRoute(builder: (context)=>Home()));
    }
  }

  void _resendCode() {
    setState(() {
      _isCodeSent = false;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isCodeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code resent')),
      );
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String get _verificationMessage {
    return widget.contactType == ContactType.email
        ? 'Enter the verification code sent to your email:'
        : 'Enter the verification code sent to your phone:';
  }

  @override
  Widget build(BuildContext context) {
    String contactDisplay = widget.contactInfo;
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _verificationMessage,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              contactDisplay,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.palegreen,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  prefixIcon: Icon(Icons.confirmation_num),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.trim().length < 4) {
                    return 'Code is too short';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              style:AppButtonStyles.topButton ,
              onPressed: _submit,
              child: Text('Verify'),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isCodeSent ? _resendCode : null,
                style: AppButtonStyles.bottomButton,
                child: Text(_isCodeSent ? 'Resend Code' : 'Sending...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}