  import 'dart:convert';

  import 'package:app/widget/post_task.dart';
  import 'package:app/widget/splash_screen.dart';
  import 'package:flutter/material.dart';

  import 'package:app/utils/auth_service.dart';
  import 'package:app/model/user.dart';

  const List<String> userType = <String>['user', 'provider'];

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final _form = GlobalKey<FormState>();
    var _isLogin = true;
    final AuthService _authService = AuthService();

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    String _userType = 'user'; // Default user type
    final List<String> userType = ['user', 'provider'];

    Future<void> submit() async {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      _form.currentState!.save();

      try {
        User user;
        if (_isLogin) {
          user = await _authService.login(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          user = await _authService.register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
            _userType,
          );
        }

        print('Authenticated user: ${user.name} (${user.email})');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("lib/image/connectmytask_logo.png"),
                  width: 250,
                  height: 40,
                ),
                SizedBox(height: 80),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      if (!_isLogin)
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Username'),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid username.';
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email Address'),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 8) {
                            return 'Password must be at least 8 characters long.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      if (!_isLogin)
                        Wrap(
                          spacing: 8.0,
                          children: userType.map((String value) {
                            return ChoiceChip(
                              label: Text(value),
                              selected: _userType == value,
                              onSelected: (bool selected) {
                                setState(() {
                                  _userType = selected ? value : _userType;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submit,
                        child: Text(_isLogin ? 'Login with Email' : 'Sign Up'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Sign up to new account'
                              : 'Already have account? Login',
                        ),
                      ),
                      Divider(thickness: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
