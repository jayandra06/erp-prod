import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../layout/responsive.dart';
import '../theme/constants.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMenuPressed;
  final Widget? actions;
  final bool showSearch;

  const DashboardHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.onMenuPressed,
    this.actions,
    this.showSearch = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -10),
            blurRadius: 35,
            color: primaryColor.withOpacity(0.38),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Button (for mobile)
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            ),
          
          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          
          // Search Bar
          if (showSearch && Responsive.isDesktop(context))
            Expanded(
              flex: 2,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: SvgPicture.asset(
                      "assets/icons/Search.svg",
                      color: Colors.white70,
                      height: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding,
                    ),
                  ),
                ),
              ),
            ),
          
          // Actions
          if (actions != null) ...[
            const SizedBox(width: defaultPadding),
            actions!,
          ],
        ],
      ),
    );
  }
}
