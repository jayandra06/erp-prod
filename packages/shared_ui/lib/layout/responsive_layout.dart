import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

/// Responsive layout utilities
class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile &&
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet &&
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;

  static bool isDesktopOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;

  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= ResponsiveBreakpoints.desktop && largeDesktop != null) {
      return largeDesktop;
    } else if (width >= ResponsiveBreakpoints.tablet && desktop != null) {
      return desktop;
    } else if (width >= ResponsiveBreakpoints.mobile && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= ResponsiveBreakpoints.desktop && largeDesktop != null) {
      return largeDesktop;
    } else if (width >= ResponsiveBreakpoints.tablet && desktop != null) {
      return desktop;
    } else if (width >= ResponsiveBreakpoints.mobile && tablet != null) {
      return tablet;
    } else {
      return mobile ?? const EdgeInsets.all(16.0);
    }
  }
}

/// Responsive widget that adapts to different screen sizes
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop!;
    } else if (ResponsiveLayout.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveLayout.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Responsive container with max width constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveMaxWidth = maxWidth ?? ResponsiveLayout.getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      largeDesktop: 1400,
    );

    return Container(
      width: double.infinity,
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
        child: Padding(
          padding: padding ?? ResponsiveLayout.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(16.0),
            tablet: const EdgeInsets.all(24.0),
            desktop: const EdgeInsets.all(32.0),
            largeDesktop: const EdgeInsets.all(40.0),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid that adapts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.getResponsiveValue(
      context,
      mobile: mobileColumns?.toDouble() ?? 1,
      tablet: tabletColumns?.toDouble() ?? 2,
      desktop: desktopColumns?.toDouble() ?? 3,
      largeDesktop: largeDesktopColumns?.toDouble() ?? 4,
    ).toInt();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 
                 (columns - 1) * spacing - 
                 (ResponsiveLayout.getResponsivePadding(context).horizontal)) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}


