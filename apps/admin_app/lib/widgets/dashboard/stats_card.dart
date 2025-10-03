import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';

enum ChangeType { increase, decrease, neutral }

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final ChangeType changeType;
  final IconData icon;
  final String emoji;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.changeType,
    required this.icon,
    required this.emoji,
    required this.color,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
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
                border: Border.all(
                  color: widget.color.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Icon and Emoji
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Value
                  Text(
                    widget.value,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.grey900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Change Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getChangeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getChangeIcon(),
                          size: 14,
                          color: _getChangeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.change,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getChangeColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Indicator
                  LinearProgressIndicator(
                    value: _getProgressValue(),
                    backgroundColor: isDark
                        ? AppTheme.darkBorder
                        : AppTheme.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getChangeColor() {
    switch (widget.changeType) {
      case ChangeType.increase:
        return AppTheme.successGreen;
      case ChangeType.decrease:
        return AppTheme.errorRed;
      case ChangeType.neutral:
        return AppTheme.grey500;
    }
  }

  IconData _getChangeIcon() {
    switch (widget.changeType) {
      case ChangeType.increase:
        return Symbols.trending_up;
      case ChangeType.decrease:
        return Symbols.trending_down;
      case ChangeType.neutral:
        return Symbols.trending_flat;
    }
  }

  double _getProgressValue() {
    // Simulate progress based on the change percentage
    final changeValue = double.tryParse(
      widget.change.replaceAll(RegExp(r'[%+\-$]'), ''),
    ) ?? 0.0;
    
    // Normalize to 0.0 - 1.0 range
    return (changeValue / 100.0).clamp(0.0, 1.0);
  }
}
