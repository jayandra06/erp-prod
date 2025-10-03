import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_theme.dart';
import 'package:shared_ui/layout/responsive_layout.dart';
import 'theme_switcher.dart';

class DashboardHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> tenant;
  final VoidCallback onMenuToggle;
  final bool isSidebarCollapsed;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.tenant,
    required this.onMenuToggle,
    required this.isSidebarCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Menu Toggle Button
            IconButton(
              onPressed: onMenuToggle,
              icon: Icon(
                isSidebarCollapsed ? Icons.menu : Icons.menu_open,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
              tooltip: isSidebarCollapsed ? 'Expand Menu' : 'Collapse Menu',
            ),
            
            const SizedBox(width: 16),
            
            // Page Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Technical Portal Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Global Super Admin Access',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            if (!ResponsiveLayout.isMobile(context))
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(width: 16),
            
            // Notifications
            _buildNotificationButton(context, isDark),
            
            const SizedBox(width: 8),
            
            // Theme Switcher
            const ThemeSwitcher(),
            
            const SizedBox(width: 8),
            
            // User Menu
            _buildUserMenu(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isDark) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Show notifications
          },
          icon: Icon(
            Icons.notifications_outlined,
            color: isDark ? Colors.white : AppTheme.textPrimary,
          ),
          tooltip: 'Notifications',
        ),
        // Notification Badge
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.errorRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // TODO: Navigate to profile
            break;
          case 'settings':
            // TODO: Navigate to settings
            break;
          case 'logout':
            // TODO: Handle logout
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              const Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorRed),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue,
              child: Text(
                user['firstName']?[0] ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!ResponsiveLayout.isMobile(context)) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user['fullName'] ?? 'User',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Tech Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
