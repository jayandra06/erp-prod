import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedMenuItem = 'dashboard';

  // Admin Portal Menu Items
  final List<MenuItem> _menuItems = [
    const MenuItem(
      id: 'dashboard',
      title: 'Dashboard',
      iconPath: 'assets/icons/menu_dashboard.svg',
    ),
    const MenuItem(
      id: 'tenants',
      title: 'Tenant Management',
      iconPath: 'assets/icons/menu_store.svg',
    ),
    const MenuItem(
      id: 'users',
      title: 'User Management',
      iconPath: 'assets/icons/menu_profile.svg',
    ),
    const MenuItem(
      id: 'roles',
      title: 'Role Management',
      iconPath: 'assets/icons/menu_setting.svg',
    ),
    const MenuItem(
      id: 'permissions',
      title: 'Permissions',
      iconPath: 'assets/icons/menu_notification.svg',
    ),
    const MenuItem(
      id: 'reports',
      title: 'Reports & Analytics',
      iconPath: 'assets/icons/menu_task.svg',
    ),
    const MenuItem(
      id: 'audit',
      title: 'Audit Logs',
      iconPath: 'assets/icons/menu_doc.svg',
    ),
    const MenuItem(
      id: 'settings',
      title: 'System Settings',
      iconPath: 'assets/icons/menu_tran.svg',
    ),
  ];

  void _onMenuItemSelected(String menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
    });
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

        return DashboardTemplate(
          title: 'Admin Portal',
          subtitle: 'Maritime Procurement ERP',
          menuItems: _menuItems,
          selectedMenuItem: _selectedMenuItem,
          onMenuItemSelected: _onMenuItemSelected,
          logoPath: 'assets/images/logo.png',
          headerActions: Row(
            children: [
              // Theme Switcher
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return IconButton(
                    onPressed: () {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    },
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    tooltip: Theme.of(context).brightness == Brightness.dark
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                  );
                },
              ),
              
              // User Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor,
                        child: Text(
                          state.user['firstName']?[0] ?? 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.user['fullName'] ?? 'Admin User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: _buildDashboardContent(context, state),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, AuthAuthenticated state) {
    switch (_selectedMenuItem) {
      case 'dashboard':
        return _buildOverviewDashboard(context, state);
      case 'tenants':
        return _buildTenantsView(context);
      case 'users':
        return _buildUsersView(context);
      case 'roles':
        return _buildRolesView(context);
      case 'permissions':
        return _buildPermissionsView(context);
      case 'reports':
        return _buildReportsView(context);
      case 'audit':
        return _buildAuditView(context);
      case 'settings':
        return _buildSettingsView(context);
      default:
        return _buildOverviewDashboard(context, state);
    }
  }

  Widget _buildOverviewDashboard(BuildContext context, AuthAuthenticated state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Admin Portal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'System Administration - Maritime Procurement ERP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'System Administrator',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Stats Cards
          if (Responsive.isDesktop(context))
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Tenants',
                    '12',
                    Icons.business,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Users',
                    '2,456',
                    Icons.people,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'System Status',
                    'Online',
                    Icons.cloud_done,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Sessions',
                    '89',
                    Icons.visibility,
                    Colors.purple,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tenants',
                        '12',
                        Icons.business,
                        primaryColor,
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Users',
                        '2,456',
                        Icons.people,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'System Status',
                        'Online',
                        Icons.cloud_done,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Sessions',
                        '89',
                        Icons.visibility,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantsView(BuildContext context) {
    return const Center(
      child: Text(
        'Tenant Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildUsersView(BuildContext context) {
    return const Center(
      child: Text(
        'User Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildRolesView(BuildContext context) {
    return const Center(
      child: Text(
        'Role Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildPermissionsView(BuildContext context) {
    return const Center(
      child: Text(
        'Permissions Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildReportsView(BuildContext context) {
    return const Center(
      child: Text(
        'Reports & Analytics',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildAuditView(BuildContext context) {
    return const Center(
      child: Text(
        'Audit Logs',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildSettingsView(BuildContext context) {
    return const Center(
      child: Text(
        'System Settings',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
