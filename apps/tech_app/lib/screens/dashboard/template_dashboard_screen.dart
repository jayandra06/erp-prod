import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';

class TemplateDashboardScreen extends StatefulWidget {
  const TemplateDashboardScreen({super.key});

  @override
  State<TemplateDashboardScreen> createState() => _TemplateDashboardScreenState();
}

class _TemplateDashboardScreenState extends State<TemplateDashboardScreen> {
  String _selectedMenuItem = 'dashboard';

  // Tech Portal Menu Items
  final List<MenuItem> _menuItems = [
    const MenuItem(
      id: 'dashboard',
      title: 'Dashboard',
      iconPath: 'assets/icons/menu_dashboard.svg',
    ),
    const MenuItem(
      id: 'organizations',
      title: 'Organizations',
      iconPath: 'assets/icons/menu_store.svg',
    ),
    const MenuItem(
      id: 'users',
      title: 'Users',
      iconPath: 'assets/icons/menu_profile.svg',
    ),
    const MenuItem(
      id: 'roles',
      title: 'Roles & Permissions',
      iconPath: 'assets/icons/menu_setting.svg',
    ),
    const MenuItem(
      id: 'system',
      title: 'System Health',
      iconPath: 'assets/icons/menu_notification.svg',
    ),
    const MenuItem(
      id: 'analytics',
      title: 'Analytics',
      iconPath: 'assets/icons/menu_task.svg',
    ),
    const MenuItem(
      id: 'documents',
      title: 'Documents',
      iconPath: 'assets/icons/menu_doc.svg',
    ),
    const MenuItem(
      id: 'transactions',
      title: 'Transactions',
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
          title: 'Technical Portal',
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
                          state.user['firstName']?[0] ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.user['fullName'] ?? 'Tech Admin',
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
      case 'organizations':
        return _buildOrganizationsView(context);
      case 'users':
        return _buildUsersView(context);
      case 'roles':
        return _buildRolesView(context);
      case 'system':
        return _buildSystemView(context);
      case 'analytics':
        return _buildAnalyticsView(context);
      case 'documents':
        return _buildDocumentsView(context);
      case 'transactions':
        return _buildTransactionsView(context);
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
                  'Welcome to Technical Portal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Global Super Admin Access - Maritime Procurement ERP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.engineering, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tech Super Admin',
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
                    'Total Organizations',
                    '24',
                    Icons.business,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Users',
                    '1,234',
                    Icons.people,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'System Health',
                    '98%',
                    Icons.monitor_heart,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Transactions',
                    '5,678',
                    Icons.receipt,
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
                        'Organizations',
                        '24',
                        Icons.business,
                        primaryColor,
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Users',
                        '1,234',
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
                        'System Health',
                        '98%',
                        Icons.monitor_heart,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Transactions',
                        '5,678',
                        Icons.receipt,
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

  Widget _buildOrganizationsView(BuildContext context) {
    return const Center(
      child: Text(
        'Organizations Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildUsersView(BuildContext context) {
    return const Center(
      child: Text(
        'Users Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildRolesView(BuildContext context) {
    return const Center(
      child: Text(
        'Roles & Permissions',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildSystemView(BuildContext context) {
    return const Center(
      child: Text(
        'System Health Monitoring',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildAnalyticsView(BuildContext context) {
    return const Center(
      child: Text(
        'Analytics Dashboard',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildDocumentsView(BuildContext context) {
    return const Center(
      child: Text(
        'Documents Management',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildTransactionsView(BuildContext context) {
    return const Center(
      child: Text(
        'Transactions Overview',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
