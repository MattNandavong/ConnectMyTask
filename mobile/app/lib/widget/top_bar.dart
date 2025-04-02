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
              SizedBox(height: 48, width: 48,),
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
      //  bottom: PreferredSize(
      //   preferredSize: const Size.fromHeight(40),
      //    child: AppBar(
      //     title: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         SizedBox(
      //           // height: 15,
      //           child: TextButton.icon(
      //             onPressed: () {},
      //             icon: Icon(FluentIcons.filter_12_filled, size: 15),
      //             label: Text(
      //               'Filter',
      //               style: GoogleFonts.figtree(fontSize: 15),
      //             ),
      //           ),
      //         ),
      //         SizedBox(
      //           // height: 15,
      //           child: TextButton.icon(
      //             onPressed: () {},
      //             style: ButtonStyle(
      //               foregroundColor: WidgetStateProperty.all<Color>(
      //                 const Color.fromARGB(255, 42, 44, 43),
      //               ),
      //             ),
      //             icon: Icon(
      //               FluentIcons.arrow_curve_down_left_16_filled,
      //               size: 15,
      //             ),
      //             label: Text('Sort', style: GoogleFonts.figtree(fontSize: 15)),
      //           ),
      //         ),
      //       ],
      //     ),
      //            ),
      //  ),
    );
  }
}
