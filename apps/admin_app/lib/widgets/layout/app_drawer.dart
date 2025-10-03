import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../services/theme_service.dart';

// Navigation state provider
final navigationProvider = StateProvider<int>((ref) => 0);

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

    return Drawer(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.secondaryBlue,
                  AppTheme.accentBlue,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.anchor,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maritime Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Professional Portal',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMobile)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System Online',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding,
              ),
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  subtitle: 'Overview & Analytics',
                  emoji: '📊',
                  index: 0,
                  isActive: currentIndex == 0,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Users',
                  subtitle: 'User Management',
                  emoji: '👥',
                  index: 1,
                  isActive: currentIndex == 1,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.business_outlined,
                  activeIcon: Icons.business,
                  label: 'Tenants',
                  subtitle: 'Multi-tenant Management',
                  emoji: '🏢',
                  index: 2,
                  isActive: currentIndex == 2,
                ),
                
                const Divider(
                  indent: AppConstants.defaultPadding,
                  endIndent: AppConstants.defaultPadding,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: 'Analytics',
                  subtitle: 'Reports & Insights',
                  emoji: '📈',
                  index: 3,
                  isActive: currentIndex == 3,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.security_outlined,
                  activeIcon: Icons.security,
                  label: 'Security',
                  subtitle: 'Access & Permissions',
                  emoji: '🔐',
                  index: 4,
                  isActive: currentIndex == 4,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.integrations_outlined,
                  activeIcon: Icons.integrations,
                  label: 'Integrations',
                  subtitle: 'API & Connections',
                  emoji: '🔌',
                  index: 5,
                  isActive: currentIndex == 5,
                ),
                
                const Divider(
                  indent: AppConstants.defaultPadding,
                  endIndent: AppConstants.defaultPadding,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  subtitle: 'System Configuration',
                  emoji: '⚙️',
                  index: 6,
                  isActive: currentIndex == 6,
                ),
                
                _buildNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.help_outline,
                  activeIcon: Icons.help,
                  label: 'Help & Support',
                  subtitle: 'Documentation',
                  emoji: '❓',
                  index: 7,
                  isActive: currentIndex == 7,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey100,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.grey200,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryBlue,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin User',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.grey900,
                            ),
                          ),
                          Text(
                            'admin@maritime.com',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                      onSelected: (value) {
                        HapticFeedback.lightImpact();
                        switch (value) {
                          case 'profile':
                            // Handle profile
                            break;
                          case 'settings':
                            ref.read(navigationProvider.notifier).state = 6;
                            break;
                          case 'logout':
                            _showLogoutDialog(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 8),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined),
                              SizedBox(width: 8),
                              Text('Settings'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text('Logout'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Maritime Admin Portal v${AppConstants.appVersion}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.grey500 : AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String subtitle,
    required String emoji,
    required int index,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(navigationProvider.notifier).state = index;
            HapticFeedback.lightImpact();
            if (MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: isActive
                  ? Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryBlue
                        : isDark
                            ? AppTheme.darkSurfaceVariant
                            : AppTheme.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 20,
                    color: isActive
                        ? Colors.white
                        : isDark
                            ? AppTheme.grey400
                            : AppTheme.grey600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppTheme.primaryBlue
                                  : isDark
                                      ? Colors.white
                                      : AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.grey600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
