import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/login/profile_setup_screen.dart';
import 'package:app/widget/notification/notification_setting_screen.dart';
import 'package:app/widget/screen/language_setting.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/widget/login.dart';
import 'package:easy_localization/easy_localization.dart'; // <--- add this!

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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr()} ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No user found'));
          }

          User user = snapshot.data!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    user.buildAvatar(radius: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                user.averageRating != null || user.averageRating != 0.0
                                    ? user.averageRating!.toStringAsFixed(1)
                                    : 'No reviews',
                                style: GoogleFonts.figtree(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              _buildDrawerItem(
                icon: Icons.edit,
                text: 'editProfile'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSetupScreen(user: user),
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.password_outlined,
                text: 'changePassword'.tr(),
                onTap: () {},
              ),
              _buildDrawerItem(
                icon: Icons.notifications_outlined,
                text: 'notificationSettings'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationSettingsScreen()),
                  );
                },
              ),
              const Divider(),

              _buildDrawerItem(icon: Icons.language_outlined, text: "languageSetting".tr(), onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSetting()));
              }),

              const Divider(),

              _buildDrawerItem(
                icon: Icons.logout,
                text: 'signOut'.tr(),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Sign out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await AuthService().logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => AuthScreen()),
                            );
                          },
                          child: const Text('YES'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: GoogleFonts.figtree(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }
}
