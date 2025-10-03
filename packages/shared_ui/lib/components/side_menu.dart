import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/constants.dart';

class SideMenu extends StatelessWidget {
  final List<MenuItem> menuItems;
  final String? selectedItem;
  final Function(String)? onItemSelected;
  final String? logoPath;
  final String? title;

  const SideMenu({
    Key? key,
    required this.menuItems,
    this.selectedItem,
    this.onItemSelected,
    this.logoPath,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: secondaryColor,
      child: ListView(
        children: [
          // Header with Logo
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logoPath != null)
                  Image.asset(
                    logoPath!,
                    height: 40,
                  ),
                if (title != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Menu Items
          ...menuItems.map((item) => DrawerListTile(
            title: item.title,
            svgSrc: item.iconPath,
            press: () => onItemSelected?.call(item.id),
            isSelected: selectedItem == item.id,
          )),
        ],
      ),
    );
  }
}

class MenuItem {
  final String id;
  final String title;
  final String iconPath;

  const MenuItem({
    required this.id,
    required this.title,
    required this.iconPath,
  });
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    this.isSelected = false,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      selected: isSelected,
      selectedTileColor: primaryColor.withOpacity(0.1),
      leading: SvgPicture.asset(
        svgSrc,
        color: isSelected ? primaryColor : Colors.white70,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
