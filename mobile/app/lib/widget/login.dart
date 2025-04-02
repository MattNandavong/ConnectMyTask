import 'dart:convert';

import 'package:app/widget/post_task.dart';
import 'package:app/widget/splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// import 'package:mobile/login/profile.dart';
// import 'package:mobile/screen/router.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/model/user.dart';

// final _firebase = FirebaseAuth.instance;

const List<String> userType = <String>['user', 'provider'];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = false;
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = 'user';

  @override
  Widget build(BuildContext context) {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    // final GoogleSignIn _googleSignIn = GoogleSignIn();

    Future<void> _loginWithApi(String email, String password) async {
      final url = 'http://localhost:3300/api/auth/login';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Handle successful login
        print('Login successful: ${responseData}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        // Handle login failure
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['msg'] ?? 'Login failed.')),
        );
      }
    }

    Future<void> _registerWithApi() async {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      _form.currentState!.save();

      try {
        Map<String, dynamic> responseData;
        if (_isLogin) {
          responseData = await _authService.login(
            "john@example.com",
            "John Doe",
          );
        } else {
          responseData = await _authService.register(
            //change name controller
            _nameController.text,
            _emailController.text,
            _passwordController.text,
            _userType,
          );
        }

        final user = User.fromJson(responseData['user']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PostTask()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image(
              //   image: AssetImage("lib/images/connectmytask_logo.png"),
              //   width: 250,
              //   height: 40,
              // ),
              SizedBox(height: 80),
              Form(
                key: _form,
                child: Column(
                  children: [
                    !_isLogin
                        ? TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'username'),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid username.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            // _enteredEmail = newValue!;
                          },
                        )
                        : SizedBox(),
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
                      onSaved: (newValue) {
                        // _enteredEmail = newValue!;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length < 8) {
                          return 'Password must be 8 letter long.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        // _enteredPassword = newValue!;
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      child: DropdownButton(
                        value: _userType,
                        items:
                            userType.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _userType = value;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print(
                          Text(
                            "${_emailController.text} ${_nameController.text} ${_passwordController.text} ${_userType.toString()}",
                          ),
                        );
                        _registerWithApi();
                      }, //use with api
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
                            : 'already have account? Login',
                      ),
                    ),
                    Divider(thickness: 1),
                    // ElevatedButton(
                    //   onPressed: _signInWithGoogle,
                    //   child: Text('Login with Google'),
                    // ),
                  ],
                ),
              ),

              // Column(
              //   children: [
              //     TextButton.icon(
              //       style: ButtonStyle(),
              //       onPressed: _signInWithGoogle,
              //       label: Text('Sign in with Google'),
              //     ),
              //     Icon(Icons.login),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
