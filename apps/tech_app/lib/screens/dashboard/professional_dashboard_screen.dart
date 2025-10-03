import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:shared_ui/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../widgets/dashboard/dashboard_content.dart';
import '../../widgets/dashboard/theme_switcher.dart';

class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  State<ProfessionalDashboardScreen> createState() => _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 0, extended: true);
  String _selectedMenuItem = 'overview';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Listen to sidebar selection changes
    _sidebarXController.addListener(() {
      setState(() {
        _selectedMenuItem = _getMenuItemId(_sidebarXController.selectedIndex);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sidebarXController.dispose();
    super.dispose();
  }

  String _getMenuItemId(int index) {
    const menuItems = [
      'overview',
      'organizations', 
      'users',
      'roles',
      'system',
      'analytics',
      'settings'
    ];
    return menuItems[index % menuItems.length];
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              // Professional Sidebar using SidebarX
              SidebarX(
                controller: _sidebarXController,
                theme: SidebarXTheme(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF1E1E1E) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(4, 0),
                      ),
                    ],
                  ),
                  hoverColor: AppTheme.primaryBlue.withOpacity(0.1),
                  textStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : AppTheme.textPrimary,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  itemTextPadding: const EdgeInsets.only(left: 16),
                  selectedIconTheme: const IconThemeData(
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                extendedTheme: SidebarXTheme(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF1E1E1E) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                footerDivider: Divider(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.grey[300],
                  height: 1,
                ),
                headerBuilder: (context, extended) {
                  return _buildSidebarHeader(context, extended);
                },
                footerItems: [
                  SidebarXItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: _handleLogout,
                  ),
                ],
                items: [
                  SidebarXItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Overview',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.business_outlined,
                    label: 'Organizations',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.people_outline,
                    label: 'Users',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.security_outlined,
                    label: 'Roles & Permissions',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.monitor_heart_outlined,
                    label: 'System Health',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    onTap: () {},
                  ),
                  SidebarXItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {},
                  ),
                ],
              ),
              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Professional Header
                    _buildHeader(context, state),
                    // Dashboard Content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: DashboardContent(
                            user: state.user,
                            tenant: state.tenant,
                            selectedMenuItem: _selectedMenuItem,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader(BuildContext context, bool extended) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo Section
          Row(
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
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maritime ERP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Technical Portal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (extended) ...[
            const SizedBox(height: 20),
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryBlue,
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tech Super Admin',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'System Access',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildHeader(BuildContext context, AuthAuthenticated state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      child: Row(
        children: [
          // Page Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Technical Portal Dashboard',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Global Super Admin Access',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
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
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
                tooltip: 'Notifications',
              ),
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
          ),
          
          const SizedBox(width: 8),
          
          // Theme Switcher
          const ThemeSwitcher(),
          
          const SizedBox(width: 8),
          
          // User Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  break;
                case 'settings':
                  break;
                case 'logout':
                  _handleLogout();
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
                      state.user['firstName']?[0] ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.user['fullName'] ?? 'User',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Tech Admin',
                        style: theme.textTheme.bodySmall?.copyWith(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
