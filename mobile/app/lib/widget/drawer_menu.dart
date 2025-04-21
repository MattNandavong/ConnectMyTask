import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/login/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/widget/login.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  Future<User> _fetchUserData() async {
    
    final user = await AuthService().getCurrentUser();

    return user!;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<User>(
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
          User user = snapshot.data!;
          return ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  children: [
                    Text(
                      "${user.name}",
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
                            user.averageRating == null
                                ? 'No reviews'
                                : user.averageRating.toString(),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSetupScreen(user: user),
                    ),
                  );
                },
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
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => AuthScreen(),
                                ),
                              );
                              AuthService().logout();
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
