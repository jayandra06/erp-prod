import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/chart_card.dart';
import '../../widgets/dashboard/recent_activity_card.dart';
import '../../widgets/dashboard/quick_actions_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
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
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back, Admin! 👋',
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 24 : 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Here\'s what\'s happening with your maritime procurement system today.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.anchor,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Stats Cards Grid
                Text(
                  'System Overview 📊',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Responsive Grid for Stats Cards
                isMobile
                    ? Column(
                        children: [
                          const StatsCard(
                            title: 'Total Users',
                            value: '2,847',
                            change: '+12.5%',
                            changeType: ChangeType.increase,
                            icon: Icons.people,
                            emoji: '👥',
                            color: AppTheme.successGreen,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const StatsCard(
                            title: 'Active Tenants',
                            value: '156',
                            change: '+8.2%',
                            changeType: ChangeType.increase,
                            icon: Icons.business,
                            emoji: '🏢',
                            color: AppTheme.infoCyan,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const StatsCard(
                            title: 'Total Orders',
                            value: '12,543',
                            change: '+23.1%',
                            changeType: ChangeType.increase,
                            icon: Icons.shopping_cart,
                            emoji: '📦',
                            color: AppTheme.warningOrange,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const StatsCard(
                            title: 'Revenue',
                            value: '\$2.4M',
                            change: '+15.7%',
                            changeType: ChangeType.increase,
                            icon: Icons.attach_money,
                            emoji: '💰',
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      )
                    : StaggeredGrid.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: AppConstants.defaultPadding,
                        crossAxisSpacing: AppConstants.defaultPadding,
                        children: const [
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: StatsCard(
                              title: 'Total Users',
                              value: '2,847',
                              change: '+12.5%',
                              changeType: ChangeType.increase,
                              icon: Icons.people,
                              emoji: '👥',
                              color: AppTheme.successGreen,
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: StatsCard(
                              title: 'Active Tenants',
                              value: '156',
                              change: '+8.2%',
                              changeType: ChangeType.increase,
                              icon: Icons.business,
                              emoji: '🏢',
                              color: AppTheme.infoCyan,
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: StatsCard(
                              title: 'Total Orders',
                              value: '12,543',
                              change: '+23.1%',
                              changeType: ChangeType.increase,
                              icon: Icons.shopping_cart,
                              emoji: '📦',
                              color: AppTheme.warningOrange,
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: StatsCard(
                              title: 'Revenue',
                              value: '\$2.4M',
                              change: '+15.7%',
                              changeType: ChangeType.increase,
                              icon: Icons.attach_money,
                              emoji: '💰',
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: AppConstants.largePadding),

                // Charts and Activity Section
                isMobile
                    ? Column(
                        children: [
                          const ChartCard(
                            title: 'Revenue Analytics',
                            emoji: '📈',
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const ChartCard(
                            title: 'User Growth',
                            emoji: '👥',
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const RecentActivityCard(),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const QuickActionsCard(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Charts
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                const ChartCard(
                                  title: 'Revenue Analytics',
                                  emoji: '📈',
                                ),
                                const SizedBox(height: AppConstants.defaultPadding),
                                const ChartCard(
                                  title: 'User Growth',
                                  emoji: '👥',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppConstants.defaultPadding),
                          
                          // Right Column - Activity and Actions
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const RecentActivityCard(),
                                const SizedBox(height: AppConstants.defaultPadding),
                                const QuickActionsCard(),
                              ],
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: AppConstants.largePadding),

                // System Status
                Container(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.monitor_heart,
                            color: AppTheme.successGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'System Status 🟢',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.grey900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatusItem(
                            'API Server',
                            'Online',
                            AppTheme.successGreen,
                            '🟢',
                          ),
                          const SizedBox(width: 20),
                          _buildStatusItem(
                            'Database',
                            'Healthy',
                            AppTheme.successGreen,
                            '🟢',
                          ),
                          const SizedBox(width: 20),
                          _buildStatusItem(
                            'Cache',
                            'Active',
                            AppTheme.successGreen,
                            '🟢',
                          ),
                          const SizedBox(width: 20),
                          _buildStatusItem(
                            'Storage',
                            '98% Free',
                            AppTheme.warningOrange,
                            '🟡',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String status, Color color, String emoji) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
