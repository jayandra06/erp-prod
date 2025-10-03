import 'package:flutter/material.dart';
import '../layout/responsive.dart';
import '../theme/constants.dart';
import 'side_menu.dart';
import 'dashboard_header.dart';

class DashboardTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<MenuItem> menuItems;
  final String? selectedMenuItem;
  final Function(String)? onMenuItemSelected;
  final Widget child;
  final String? logoPath;
  final Widget? headerActions;

  const DashboardTemplate({
    Key? key,
    required this.title,
    this.subtitle,
    required this.menuItems,
    this.selectedMenuItem,
    this.onMenuItemSelected,
    required this.child,
    this.logoPath,
    this.headerActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: !Responsive.isDesktop(context)
          ? SideMenu(
              menuItems: menuItems,
              selectedItem: selectedMenuItem,
              onItemSelected: onMenuItemSelected,
              logoPath: logoPath,
              title: subtitle,
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side Menu for Desktop
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(
                  menuItems: menuItems,
                  selectedItem: selectedMenuItem,
                  onItemSelected: onMenuItemSelected,
                  logoPath: logoPath,
                  title: subtitle,
                ),
              ),
            
            // Main Content
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Header
                  DashboardHeader(
                    title: title,
                    subtitle: subtitle,
                    onMenuPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    actions: headerActions,
                  ),
                  
                  // Content
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
