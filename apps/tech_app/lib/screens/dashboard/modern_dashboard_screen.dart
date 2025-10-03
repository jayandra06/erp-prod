import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/layout/responsive_layout.dart';
import 'package:shared_ui/components/app_button.dart';
import 'package:shared_ui/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/dashboard/side_navigation.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_content.dart';
import '../../widgets/dashboard/theme_switcher.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({super.key});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isSidebarCollapsed = false;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

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

        return Scaffold(
          body: ResponsiveWidget(
            mobile: _buildMobileLayout(state),
            tablet: _buildTabletLayout(state),
            desktop: _buildDesktopLayout(state),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(AuthAuthenticated state) {
    return Scaffold(
      drawer: SideNavigation(
        user: state.user,
        tenant: state.tenant,
        selectedItem: _selectedMenuItem,
        onItemSelected: _onMenuItemSelected,
        onLogout: _handleLogout,
        isCollapsed: false,
      ),
      appBar: AppBar(
        title: Text(
          'Technical Portal',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          ThemeSwitcher(),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
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
    );
  }

  Widget _buildTabletLayout(AuthAuthenticated state) {
    return Row(
      children: [
        // Side Navigation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSidebarCollapsed ? 80 : 280,
          child: SideNavigation(
            user: state.user,
            tenant: state.tenant,
            selectedItem: _selectedMenuItem,
            onItemSelected: _onMenuItemSelected,
            onLogout: _handleLogout,
            isCollapsed: _isSidebarCollapsed,
          ),
        ),
        // Main Content
        Expanded(
          child: Column(
            children: [
              // Header
              DashboardHeader(
                user: state.user,
                tenant: state.tenant,
                onMenuToggle: _toggleSidebar,
                isSidebarCollapsed: _isSidebarCollapsed,
              ),
              // Content
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
    );
  }

  Widget _buildDesktopLayout(AuthAuthenticated state) {
    return Row(
      children: [
        // Side Navigation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSidebarCollapsed ? 80 : 320,
          child: SideNavigation(
            user: state.user,
            tenant: state.tenant,
            selectedItem: _selectedMenuItem,
            onItemSelected: _onMenuItemSelected,
            onLogout: _handleLogout,
            isCollapsed: _isSidebarCollapsed,
          ),
        ),
        // Main Content
        Expanded(
          child: Column(
            children: [
              // Header
              DashboardHeader(
                user: state.user,
                tenant: state.tenant,
                onMenuToggle: _toggleSidebar,
                isSidebarCollapsed: _isSidebarCollapsed,
              ),
              // Content
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
    );
  }
}

