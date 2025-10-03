import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../services/theme_service.dart';

class AppHeader extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  final bool isMobile;

  const AppHeader({
    super.key,
    this.onMenuTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Row(
            children: [
              // Menu Button (Mobile)
              if (isMobile) ...[
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
              ],
              
              // Logo and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.secondaryBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.anchor,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppTheme.grey900,
                        ),
                      ),
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Header Actions
              Row(
                children: [
                  // Search Button
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Handle search
                    },
                    icon: const Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.grey100,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Notifications
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Handle notifications
                        },
                        icon: const Icon(Icons.notifications_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.grey100,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '3',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Theme Toggle
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : themeMode == ThemeMode.light
                              ? Icons.dark_mode
                              : Icons.brightness_6,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.grey100,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // User Profile
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Handle profile
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.secondaryBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Admin User',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'admin@maritime.com',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
