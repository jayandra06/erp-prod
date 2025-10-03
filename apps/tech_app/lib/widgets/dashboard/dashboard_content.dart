import 'package:flutter/material.dart';
import 'package:shared_ui/layout/responsive_layout.dart';
import 'package:shared_ui/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardContent extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> tenant;
  final String selectedMenuItem;

  const DashboardContent({
    super.key,
    required this.user,
    required this.tenant,
    required this.selectedMenuItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212) 
          : AppTheme.lightGray,
      child: ResponsiveContainer(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (selectedMenuItem) {
      case 'overview':
        return _buildOverviewContent(context);
      case 'organizations':
        return _buildOrganizationsContent(context);
      case 'users':
        return _buildUsersContent(context);
      case 'roles':
        return _buildRolesContent(context);
      case 'system':
        return _buildSystemContent(context);
      case 'analytics':
        return _buildAnalyticsContent(context);
      case 'settings':
        return _buildSettingsContent(context);
      default:
        return _buildOverviewContent(context);
    }
  }

  Widget _buildOverviewContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Welcome Section
          _buildWelcomeSection(context),
          
          const SizedBox(height: 32),
          
          // Stats Cards
          _buildStatsCards(context),
          
          const SizedBox(height: 32),
          
          // Charts Row
          ResponsiveWidget(
            mobile: Column(
              children: [
                _buildSystemHealthChart(context),
                const SizedBox(height: 24),
                _buildActivityChart(context),
              ],
            ),
            tablet: Column(
              children: [
                _buildSystemHealthChart(context),
                const SizedBox(height: 24),
                _buildActivityChart(context),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSystemHealthChart(context)),
                const SizedBox(width: 24),
                Expanded(child: _buildActivityChart(context)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          _buildRecentActivity(context),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.secondaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user['firstName'] ?? 'Admin'}!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have full access to manage all organizations, users, and system settings.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusChip('Global Admin', Colors.green),
                    const SizedBox(width: 8),
                    _buildStatusChip('System Online', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.engineering,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final stats = [
      {
        'title': 'Total Organizations',
        'value': '12',
        'icon': Icons.business,
        'color': AppTheme.primaryBlue,
        'change': '+2 this month',
      },
      {
        'title': 'Active Users',
        'value': '1,247',
        'icon': Icons.people,
        'color': AppTheme.oceanGreen,
        'change': '+15% this week',
      },
      {
        'title': 'System Health',
        'value': '99.9%',
        'icon': Icons.monitor_heart,
        'color': AppTheme.oceanGreen,
        'change': 'All systems operational',
      },
      {
        'title': 'Storage Used',
        'value': '2.4 GB',
        'icon': Icons.storage,
        'color': AppTheme.warningOrange,
        'change': '45% of 5.4 GB',
      },
    ];

    return ResponsiveGrid(
      children: stats.map((stat) => _buildStatCard(context, stat)).toList(),
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
      spacing: 16,
    );
  }

  Widget _buildStatCard(BuildContext context, Map<String, dynamic> stat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 24,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: AppTheme.oceanGreen,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['change'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.oceanGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Mon', style: style);
                            break;
                          case 1:
                            text = const Text('Tue', style: style);
                            break;
                          case 2:
                            text = const Text('Wed', style: style);
                            break;
                          case 3:
                            text = const Text('Thu', style: style);
                            break;
                          case 4:
                            text = const Text('Fri', style: style);
                            break;
                          case 5:
                            text = const Text('Sat', style: style);
                            break;
                          case 6:
                            text = const Text('Sun', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        return Text('${value.toInt()}%', style: style);
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 95),
                      FlSpot(1, 98),
                      FlSpot(2, 97),
                      FlSpot(3, 99),
                      FlSpot(4, 99.5),
                      FlSpot(5, 99.8),
                      FlSpot(6, 99.9),
                    ],
                    isCurved: true,
                    color: AppTheme.oceanGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.oceanGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: AppTheme.primaryBlue,
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppTheme.oceanGreen,
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppTheme.warningOrange,
                    value: 20,
                    title: '20%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppTheme.errorRed,
                    value: 10,
                    title: '10%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final legendItems = [
      {'label': 'Active Users', 'color': AppTheme.primaryBlue},
      {'label': 'Online Users', 'color': AppTheme.oceanGreen},
      {'label': 'Idle Users', 'color': AppTheme.warningOrange},
      {'label': 'Offline Users', 'color': AppTheme.errorRed},
    ];

    return ResponsiveGrid(
      children: legendItems.map((item) => _buildLegendItem(context, item)).toList(),
      mobileColumns: 2,
      tabletColumns: 2,
      desktopColumns: 4,
      spacing: 8,
    );
  }

  Widget _buildLegendItem(BuildContext context, Map<String, dynamic> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item['color'],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item['label'],
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final activities = [
      {
        'title': 'New organization created',
        'description': 'Maritime Solutions Ltd. was added to the system',
        'time': '2 minutes ago',
        'icon': Icons.business,
        'color': AppTheme.oceanGreen,
      },
      {
        'title': 'User role updated',
        'description': 'John Doe was promoted to Fleet Manager',
        'time': '15 minutes ago',
        'icon': Icons.person,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': 'System backup completed',
        'description': 'Daily backup completed successfully',
        'time': '1 hour ago',
        'icon': Icons.backup,
        'color': AppTheme.warningOrange,
      },
      {
        'title': 'Security alert',
        'description': 'Multiple failed login attempts detected',
        'time': '2 hours ago',
        'icon': Icons.security,
        'color': AppTheme.errorRed,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full activity log
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(context, activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder content for other menu items
  Widget _buildOrganizationsContent(BuildContext context) {
    return const Center(
      child: Text('Organizations Management - Coming Soon'),
    );
  }

  Widget _buildUsersContent(BuildContext context) {
    return const Center(
      child: Text('Users Management - Coming Soon'),
    );
  }

  Widget _buildRolesContent(BuildContext context) {
    return const Center(
      child: Text('Roles & Permissions - Coming Soon'),
    );
  }

  Widget _buildSystemContent(BuildContext context) {
    return const Center(
      child: Text('System Health - Coming Soon'),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context) {
    return const Center(
      child: Text('Analytics - Coming Soon'),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return const Center(
      child: Text('Settings - Coming Soon'),
    );
  }
}

