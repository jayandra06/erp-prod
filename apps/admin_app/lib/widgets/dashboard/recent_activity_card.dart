import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    final activities = [
      ActivityItem(
        icon: Symbols.person_add,
        title: 'New User Registered',
        subtitle: 'John Smith joined Maritime Corp',
        time: '2 minutes ago',
        color: AppTheme.successGreen,
        emoji: '👤',
      ),
      ActivityItem(
        icon: Symbols.shopping_cart,
        title: 'Order Completed',
        subtitle: 'Order #12345 has been fulfilled',
        time: '15 minutes ago',
        color: AppTheme.infoCyan,
        emoji: '📦',
      ),
      ActivityItem(
        icon: Symbols.business,
        title: 'New Tenant Created',
        subtitle: 'Ocean Shipping Ltd registered',
        time: '1 hour ago',
        color: AppTheme.warningOrange,
        emoji: '🏢',
      ),
      ActivityItem(
        icon: Symbols.security,
        title: 'Security Alert',
        subtitle: 'Unusual login activity detected',
        time: '2 hours ago',
        color: AppTheme.errorRed,
        emoji: '🔒',
      ),
      ActivityItem(
        icon: Symbols.payments,
        title: 'Payment Received',
        subtitle: '\$5,000 payment from Blue Ocean',
        time: '3 hours ago',
        color: AppTheme.successGreen,
        emoji: '💳',
      ),
    ];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.infoCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Symbols.history,
                        color: AppTheme.infoCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.grey900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '🕒',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Activity List
                ...activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: activity.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    activity.icon,
                                    color: activity.color,
                                    size: 16,
                                  ),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            activity.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : AppTheme.grey900,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            activity.emoji,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        activity.subtitle,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activity.time,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppTheme.grey500 : AppTheme.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Status indicator
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: activity.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),

                const SizedBox(height: 8),

                // View All Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Handle view all
                    },
                    icon: Icon(
                      Symbols.arrow_forward,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    label: Text(
                      'View All Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final String emoji;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.emoji,
  });
}
