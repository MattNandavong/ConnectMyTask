import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/model/user.dart';
import 'package:app/widget/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.user});
  final User user;

  Future<Map<String, dynamic>> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final url = 'http://localhost:3300/api/user/${user.id}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }
          Map<String, dynamic> data = snapshot.data!;
          return ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  children: [
                    Text(
                      "${data['firstName']} ${data['lastName']}",
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: const Color.fromARGB(255, 123, 193, 146),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color.fromARGB(255, 255, 183, 0),
                            size: 12,
                          ),
                          Text(
                            data['rating'] == 0
                                ? 'No reviews'
                                : data['rating'].toString(),
                            style: GoogleFonts.figtree(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {},
                title: Text('Edit profile'),
                leading: Icon(Icons.edit),
              ),
              ListTile(
                onTap: () {},
                title: Text('Change Password'),
                leading: Icon(Icons.password_outlined),
              ),
              ListTile(
                onTap: () {},
                title: Text('Notification setting'),
                leading: Icon(Icons.notifications),
              ),
              ListTile(
                iconColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sign out'),
                        content: const SingleChildScrollView(
                          child: ListBody(
                            children: [Text('Are you sure to sign out?')],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _signOut(context);
                            },
                            child: Text('YES'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: Text('Sign out'),
                leading: Icon(Icons.logout),
              ),
            ],
          );
        },
      ),
    );
  }
}
