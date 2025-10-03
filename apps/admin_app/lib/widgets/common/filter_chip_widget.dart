import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final Color? backgroundColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? Colors.white
              : isDark
                  ? AppTheme.grey300
                  : AppTheme.grey700,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: selectedColor ?? AppTheme.primaryBlue,
      backgroundColor: backgroundColor ?? 
          (isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey100),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? selectedColor ?? AppTheme.primaryBlue
              : isDark
                  ? AppTheme.darkBorder
                  : AppTheme.grey300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
    );
  }
}
