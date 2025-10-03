import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/filter_chip_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.successGreen,
                            AppTheme.infoCyan,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Management 👥',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage users, roles, and permissions across all tenants',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppTheme.grey300 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle add user
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Stats Cards
                if (!isMobile)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Users',
                          '2,847',
                          '+12.5%',
                          Icons.people,
                          AppTheme.successGreen,
                          '👥',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Active Users',
                          '2,234',
                          '+8.2%',
                          Icons.person,
                          AppTheme.infoCyan,
                          '✅',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'New This Month',
                          '156',
                          '+23.1%',
                          Icons.person_add,
                          AppTheme.warningOrange,
                          '🆕',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Suspended',
                          '12',
                          '-2.1%',
                          Icons.person_off,
                          AppTheme.errorRed,
                          '🚫',
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildStatCard(
                        'Total Users',
                        '2,847',
                        '+12.5%',
                        Icons.people,
                        AppTheme.successGreen,
                        '👥',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'Active Users',
                        '2,234',
                        '+8.2%',
                        Icons.person,
                        AppTheme.infoCyan,
                        '✅',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'New This Month',
                        '156',
                        '+23.1%',
                        Icons.person_add,
                        AppTheme.warningOrange,
                        '🆕',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'Suspended',
                        '12',
                        '-2.1%',
                        Icons.person_off,
                        AppTheme.errorRed,
                        '🚫',
                      ),
                    ],
                  ),

                const SizedBox(height: AppConstants.largePadding),

                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                      Text(
                        'Search & Filter Users',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.grey900,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Search Bar
                      SearchBarWidget(
                        controller: _searchController,
                        hintText: 'Search users by name, email, or role...',
                        onChanged: (value) {
                          // Handle search
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Filter Chips
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: _selectedFilter == 'All',
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                            },
                          ),
                          FilterChipWidget(
                            label: 'Active',
                            isSelected: _selectedFilter == 'Active',
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = 'Active';
                              });
                            },
                          ),
                          FilterChipWidget(
                            label: 'Suspended',
                            isSelected: _selectedFilter == 'Suspended',
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = 'Suspended';
                              });
                            },
                          ),
                          FilterChipWidget(
                            label: 'Admins',
                            isSelected: _selectedFilter == 'Admins',
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = 'Admins';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Users Table
                Container(
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
                  child: isMobile
                      ? _buildMobileUsersList()
                      : _buildDesktopUsersTable(),
                ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () {
                // Handle add user
              },
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
            )
          : null,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    String emoji,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: change.startsWith('+')
                  ? AppTheme.successGreen
                  : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUsersList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.grey200,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  'U${index + 1}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.grey900,
                      ),
                    ),
                    Text(
                      'user${index + 1}@example.com',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Handle user actions
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopUsersTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      columns: [
        DataColumn2(
          label: Text(
            'User',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text(
            'Email',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text(
            'Role',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text(
            'Status',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text(
            'Last Login',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
          ),
          size: ColumnSize.M,
        ),
        const DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: List.generate(10, (index) {
        return DataRow2(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      'U${index + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'User ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppTheme.grey900,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                'user${index + 1}@example.com',
                style: GoogleFonts.poppins(
                  color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                ),
              ),
            ),
            DataCell(
              Text(
                index % 3 == 0 ? 'Admin' : 'User',
                style: GoogleFonts.poppins(
                  color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                ),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                '2 hours ago',
                style: GoogleFonts.poppins(
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                ),
              ),
            ),
            DataCell(
              IconButton(
                onPressed: () {
                  // Handle user actions
                },
                icon: const Icon(Icons.more_vert),
                iconSize: 18,
              ),
            ),
          ],
        );
      }),
    );
  }
}
