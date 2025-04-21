import 'package:app/utils/firebase_service.dart';
import 'package:app/widget/login/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/splash_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final _fcmToken = getFcmToken();
  String _userType = 'user';
  bool _isLogin = true;

  Future<void> submit() async {
  final isValid = _form.currentState!.validate();
  final token = await getFcmToken(); // Await actual token string
  if (!isValid) return;

  try {
    
    print('Tokem FCM: $token');

    User user;
    if (_isLogin) {
      user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        token!, //  Correct token here
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else {
      user = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _userType,
        fcmToken: token, 
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: user)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
        child: Column(
          children: [
            Image.asset("lib/image/connectmytask_logo.png", width: 250, height: 40),
            SizedBox(height: 60),
            Form(
              key: _form,
              child: Column(
                children: [
                  if (!_isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a valid name'
                          : null,
                    ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (value) =>
                        value != null && value.length >= 6 ? null : 'Min 6 characters',
                  ),
                  SizedBox(height: 16),
                  if (!_isLogin)
                    Wrap(
                      spacing: 10,
                      children: ['user', 'provider'].map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _userType == type,
                          onSelected: (_) => setState(() => _userType = type),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submit,
                    child: Text(_isLogin ? 'Login' : 'Register'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'Create new account' : 'Already registered? Login'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
