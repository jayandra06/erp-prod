import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_theme.dart';

class SideNavigation extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> tenant;
  final String selectedItem;
  final Function(String) onItemSelected;
  final VoidCallback onLogout;
  final bool isCollapsed;

  const SideNavigation({
    super.key,
    required this.user,
    required this.tenant,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onLogout,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          _buildBrandSection(context, isDark),
          
          // User Profile Section
          _buildUserProfileSection(context, isDark),
          
          // Navigation Menu
          Expanded(
            child: _buildNavigationMenu(context, isDark),
          ),
          
          // Logout Section
          _buildLogoutSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.engineering,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maritime ERP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Technical Portal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: isCollapsed ? 20 : 24,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              user['firstName']?[0] ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['fullName'] ?? 'User',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Tech Super Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tenant['name'] ?? 'System',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(BuildContext context, bool isDark) {
    final menuItems = [
      {
        'id': 'overview',
        'title': 'Overview',
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
      },
      {
        'id': 'organizations',
        'title': 'Organizations',
        'icon': Icons.business_outlined,
        'activeIcon': Icons.business,
      },
      {
        'id': 'users',
        'title': 'Users',
        'icon': Icons.people_outline,
        'activeIcon': Icons.people,
      },
      {
        'id': 'roles',
        'title': 'Roles & Permissions',
        'icon': Icons.security_outlined,
        'activeIcon': Icons.security,
      },
      {
        'id': 'system',
        'title': 'System Health',
        'icon': Icons.monitor_heart_outlined,
        'activeIcon': Icons.monitor_heart,
      },
      {
        'id': 'analytics',
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'activeIcon': Icons.analytics,
      },
      {
        'id': 'settings',
        'title': 'Settings',
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (!isCollapsed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'MAIN MENU',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ...menuItems.map((item) => _buildMenuItem(context, item, isDark)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final isSelected = selectedItem == item['id'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onItemSelected(item['id']),
          splashColor: AppTheme.primaryBlue.withOpacity(0.1),
          hoverColor: AppTheme.primaryBlue.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                ? AppTheme.primaryBlue.withOpacity(0.15)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                ? Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    width: 1.5,
                  )
                : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppTheme.primaryBlue.withOpacity(0.2)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? item['activeIcon'] : item['icon'],
                    color: isSelected 
                      ? AppTheme.primaryBlue
                      : (isDark ? Colors.grey[400] : AppTheme.textSecondary),
                    size: 20,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.white : AppTheme.textPrimary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          
          // Logout Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onLogout,
              splashColor: AppTheme.errorRed.withOpacity(0.1),
              hoverColor: AppTheme.errorRed.withOpacity(0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 12 : 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Logout',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

