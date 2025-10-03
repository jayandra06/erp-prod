import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';

class QuickActionsCard extends StatefulWidget {
  const QuickActionsCard({super.key});

  @override
  State<QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends State<QuickActionsCard>
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

    final actions = [
      QuickAction(
        icon: Symbols.person_add,
        title: 'Add User',
        subtitle: 'Create new user',
        color: AppTheme.successGreen,
        emoji: '👤',
      ),
      QuickAction(
        icon: Symbols.business,
        title: 'New Tenant',
        subtitle: 'Register tenant',
        color: AppTheme.infoCyan,
        emoji: '🏢',
      ),
      QuickAction(
        icon: Symbols.settings,
        title: 'Settings',
        subtitle: 'System config',
        color: AppTheme.warningOrange,
        emoji: '⚙️',
      ),
      QuickAction(
        icon: Symbols.analytics,
        title: 'Reports',
        subtitle: 'Generate report',
        color: AppTheme.primaryBlue,
        emoji: '📊',
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
                        color: AppTheme.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Symbols.flash_on,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.grey900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '⚡',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Actions Grid
                ...actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 200 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _handleActionTap(action.title);
                                },
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: action.color.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    border: Border.all(
                                      color: action.color.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: action.color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          action.icon,
                                          color: action.color,
                                          size: 18,
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
                                                  action.title,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.white : AppTheme.grey900,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  action.emoji,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              action.subtitle,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Arrow
                                      Icon(
                                        Symbols.arrow_forward_ios,
                                        size: 16,
                                        color: action.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                      HapticFeedback.lightImpact();
                      // Handle view all actions
                    },
                    icon: Icon(
                      Symbols.apps,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    label: Text(
                      'View All Actions',
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

  void _handleActionTap(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$actionTitle action triggered! 🚀',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String emoji;

  QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.emoji,
  });
}
