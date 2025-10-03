import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.padding,
    this.borderRadius,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.padding,
    this.borderRadius,
  }) : type = AppButtonType.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.padding,
    this.borderRadius,
  }) : type = AppButtonType.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.padding,
    this.borderRadius,
  }) : type = AppButtonType.outline;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.padding,
    this.borderRadius,
  }) : type = AppButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final buttonStyle = _getButtonStyle(theme, colorScheme);
    final textStyle = _getTextStyle(theme);
    final buttonPadding = _getPadding();
    final buttonBorderRadius = borderRadius ?? BorderRadius.circular(8);

    Widget buttonChild = _buildButtonChild(theme);

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: _buildButton(buttonStyle, textStyle, buttonPadding, buttonBorderRadius, buttonChild),
      );
    }

    return _buildButton(buttonStyle, textStyle, buttonPadding, buttonBorderRadius, buttonChild);
  }

  Widget _buildButton(
    ButtonStyle buttonStyle,
    TextStyle textStyle,
    EdgeInsetsGeometry buttonPadding,
    BorderRadius buttonBorderRadius,
    Widget buttonChild,
  ) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle.copyWith(
        padding: WidgetStateProperty.all(buttonPadding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: buttonBorderRadius),
        ),
      ),
      child: buttonChild,
    );
  }

  Widget _buildButtonChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(theme),
          ),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle(theme)),
        ],
      );
    }

    return Text(text, style: _getTextStyle(theme));
  }

  ButtonStyle _getButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryBlue,
          foregroundColor: Colors.white,
          elevation: 1,
        );
      case AppButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryBlue,
          elevation: 0,
          side: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        );
      case AppButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryBlue,
          elevation: 0,
          shadowColor: Colors.transparent,
        );
      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.errorRed.withOpacity(0.3),
        );
      case AppButtonType.success:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.oceanGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.oceanGreen.withOpacity(0.3),
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    switch (size) {
      case AppButtonSize.small:
        return baseStyle?.copyWith(fontSize: 12) ?? const TextStyle(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle?.copyWith(fontSize: 14) ?? const TextStyle(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle?.copyWith(fontSize: 16) ?? const TextStyle(fontSize: 16);
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;

    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.danger:
      case AppButtonType.success:
        return Colors.white;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppTheme.primaryBlue;
    }
  }
}


