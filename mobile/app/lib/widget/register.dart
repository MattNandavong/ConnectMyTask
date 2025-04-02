import 'package:app/model/user.dart';
import 'package:app/widget/login.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final AuthService _authService = AuthService();

  var _isLogin = false;

  Future<void> _registerWithApi() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    try {
      final responseData;
      if (_isLogin) {
        responseData = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        responseData = await _authService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _roleController.text,
        );
      }

      final user = User.fromJson(responseData);
      print(user.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = await _authService.register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _roleController.text,
                      );
                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
                    }
                  }

                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
