import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/widget/screen/profile_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/widget/screen/map_screen.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String screen;
  final bool showBack;

  const TopBar({super.key, required this.screen, this.showBack = false});

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _TopBarState extends State<TopBar> {
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await AuthService().getCurrentUser();
    final profile = await AuthService().getUserProfile(currentUser!.id);
    if (!mounted) return;
    setState(() {
      user = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      centerTitle: true,
      elevation: 12,
      shadowColor: const Color.fromARGB(30, 0, 0, 0),
      automaticallyImplyLeading: false, // Disable default back button
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Back button if needed
          widget.showBack
              ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
              : Builder(
                builder:
                    (context) => IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              ),

          ///  Centered title
          Text(widget.screen, style: GoogleFonts.figtree(fontSize: 18)),

          ///  Search + profile
          Row(
            children: [
              widget.screen == 'Browse Task'
                  ? IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapScreen()),
                      );
                    },
                    icon: Icon(FluentIcons.search_12_regular, size: 20),
                    padding: EdgeInsets.all(10),
                  )
                  : const SizedBox(height: 49, width: 48),
              IconButton(
                onPressed:
                    user == null
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProfileScreen(
                                    user: user!,
                                    editable: true,
                                  ),
                            ),
                          );
                        },
                icon: const Icon(Icons.account_circle, size: 24),
                padding: const EdgeInsets.all(10),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
