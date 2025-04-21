import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:mobile/widgets/browsetask/browsetask_list.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.screen});

  final String screen;

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
      centerTitle: true,
      elevation: 12,
      shadowColor: const Color.fromARGB(30, 0, 0, 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(FluentIcons.map_20_regular, size: 20),
              ),
              // SizedBox(height: 48, width: 48,),
            ],
          ),
          
          Text(widget.screen, style: GoogleFonts.figtree(fontSize: 18)),
          Row(
            children: [
              widget.screen == 'Browse Task'? IconButton(
                onPressed: () {},
                icon: Icon(FluentIcons.search_12_regular, size: 20),
                padding: EdgeInsets.all(10),
              ): SizedBox(height: 49  , width: 48,),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.account_circle, size: 24),
                padding: EdgeInsets.all(10),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),

    );
  }
}
