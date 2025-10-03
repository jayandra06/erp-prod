import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../services/theme_service.dart';
import '../../widgets/layout/app_drawer.dart';
import '../../widgets/layout/app_header.dart';
import 'dashboard/dashboard_screen.dart';
import 'users/users_screen.dart';
import 'tenants/tenants_screen.dart';
import 'settings/settings_screen.dart';

// Navigation state provider
final navigationProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Navigation screens
  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersScreen(),
    const TenantsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style for main layout
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onNavigationTap(int index) {
    ref.read(navigationProvider.notifier).state = index;
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.grey50,
      
      // App Bar
      appBar: AppHeader(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        isMobile: isMobile,
      ),
      
      // Drawer
      drawer: isMobile ? const AppDrawer() : null,
      
      // Body
      body: Row(
        children: [
          // Desktop Sidebar
          if (!isMobile) ...[
            const AppDrawer(),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark ? AppTheme.darkBorder : AppTheme.grey200,
            ),
          ],
          
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.darkBackground,
                          AppTheme.darkSurface.withOpacity(0.5),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.grey50,
                          AppTheme.lightBlue.withOpacity(0.3),
                        ],
                      ),
              ),
              child: IndexedStack(
                index: currentIndex,
                children: _screens,
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation for Mobile
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Dashboard',
                        index: 0,
                        isActive: currentIndex == 0,
                      ),
                      _buildNavItem(
                        icon: Icons.people_outline,
                        activeIcon: Icons.people,
                        label: 'Users',
                        index: 1,
                        isActive: currentIndex == 1,
                      ),
                      _buildNavItem(
                        icon: Icons.business_outlined,
                        activeIcon: Icons.business,
                        label: 'Tenants',
                        index: 2,
                        isActive: currentIndex == 2,
                      ),
                      _buildNavItem(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        label: 'Settings',
                        index: 3,
                        isActive: currentIndex == 3,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive
                  ? AppTheme.primaryBlue
                  : isDark
                      ? AppTheme.grey500
                      : AppTheme.grey600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppTheme.primaryBlue
                    : isDark
                        ? AppTheme.grey500
                        : AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
