import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
                            AppTheme.infoCyan,
                            AppTheme.primaryBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business,
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
                            'Tenant Management 🏢',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage multi-tenant organizations and their configurations',
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
                          // Handle add tenant
                        },
                        icon: const Icon(Icons.business),
                        label: const Text('Add Tenant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoCyan,
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
                          'Total Tenants',
                          '156',
                          '+8.2%',
                          Icons.business,
                          AppTheme.infoCyan,
                          '🏢',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Active Tenants',
                          '142',
                          '+5.1%',
                          Icons.business_center,
                          AppTheme.successGreen,
                          '✅',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'New This Month',
                          '12',
                          '+15.3%',
                          Icons.business_outlined,
                          AppTheme.warningOrange,
                          '🆕',
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildStatCard(
                          'Suspended',
                          '2',
                          '-1.2%',
                          Icons.business_off,
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
                        'Total Tenants',
                        '156',
                        '+8.2%',
                        Icons.business,
                        AppTheme.infoCyan,
                        '🏢',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'Active Tenants',
                        '142',
                        '+5.1%',
                        Icons.business_center,
                        AppTheme.successGreen,
                        '✅',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'New This Month',
                        '12',
                        '+15.3%',
                        Icons.business_outlined,
                        AppTheme.warningOrange,
                        '🆕',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildStatCard(
                        'Suspended',
                        '2',
                        '-1.2%',
                        Icons.business_off,
                        AppTheme.errorRed,
                        '🚫',
                      ),
                    ],
                  ),

                const SizedBox(height: AppConstants.largePadding),

                // Tenants Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 2,
                    crossAxisSpacing: AppConstants.defaultPadding,
                    mainAxisSpacing: AppConstants.defaultPadding,
                    childAspectRatio: isMobile ? 2.5 : 2.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildTenantCard(
                      'Maritime Corp ${index + 1}',
                      'maritime${index + 1}@example.com',
                      'Active',
                      '${(index + 1) * 45} Users',
                      '\$${(index + 1) * 1250}/month',
                      AppTheme.successGreen,
                    );
                  },
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
                // Handle add tenant
              },
              backgroundColor: AppTheme.infoCyan,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.business),
              label: const Text('Add Tenant'),
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

  Widget _buildTenantCard(
    String name,
    String email,
    String status,
    String users,
    String revenue,
    Color statusColor,
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
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),
                    Text(
                      users,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.grey900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                      ),
                    ),
                    Text(
                      revenue,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle view details
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle manage
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Manage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
