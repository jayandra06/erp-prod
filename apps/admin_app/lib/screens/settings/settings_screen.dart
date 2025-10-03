import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
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
    final themeMode = ref.watch(themeModeProvider);
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
                            AppTheme.warningOrange,
                            AppTheme.errorRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
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
                            'System Settings ⚙️',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.grey900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure system preferences, security, and integrations',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppTheme.grey300 : AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Settings Sections
                _buildSettingsSection(
                  'Appearance & Theme',
                  'Customize the look and feel of your admin portal',
                  Icons.palette,
                  '🎨',
                  [
                    _buildThemeSetting(themeMode),
                    _buildLanguageSetting(),
                    _buildAccentColorSetting(),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                _buildSettingsSection(
                  'Security & Privacy',
                  'Manage authentication, permissions, and data protection',
                  Icons.security,
                  '🔐',
                  [
                    _buildSecuritySetting('Two-Factor Authentication', 'Enabled', true),
                    _buildSecuritySetting('Session Timeout', '30 minutes', false),
                    _buildSecuritySetting('IP Whitelist', 'Configured', false),
                    _buildSecuritySetting('Audit Logs', 'Enabled', true),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                _buildSettingsSection(
                  'Notifications',
                  'Configure how and when you receive notifications',
                  Icons.notifications,
                  '🔔',
                  [
                    _buildNotificationSetting('Email Notifications', true),
                    _buildNotificationSetting('Push Notifications', true),
                    _buildNotificationSetting('SMS Alerts', false),
                    _buildNotificationSetting('System Updates', true),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                _buildSettingsSection(
                  'Integrations',
                  'Connect with external services and APIs',
                  Icons.integration_instructions,
                  '🔌',
                  [
                    _buildIntegrationSetting('API Gateway', 'Connected', AppTheme.successGreen),
                    _buildIntegrationSetting('Email Service', 'Connected', AppTheme.successGreen),
                    _buildIntegrationSetting('Payment Gateway', 'Disconnected', AppTheme.errorRed),
                    _buildIntegrationSetting('Analytics', 'Connected', AppTheme.successGreen),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                _buildSettingsSection(
                  'System Information',
                  'View system status and version information',
                  Icons.info,
                  'ℹ️',
                  [
                    _buildInfoSetting('App Version', AppConstants.appVersion),
                    _buildInfoSetting('Database Version', 'MongoDB 6.0'),
                    _buildInfoSetting('Last Backup', '2 hours ago'),
                    _buildInfoSetting('System Uptime', '15 days'),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: AppTheme.errorRed,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Danger Zone ⚠️',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'These actions are irreversible. Please proceed with caution.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppTheme.grey300 : AppTheme.grey700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showResetDialog();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Settings'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showClearDataDialog();
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Clear All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorRed,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    String subtitle,
    IconData icon,
    String emoji,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.grey900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSetting(ThemeMode themeMode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.brightness_6,
            color: isDark ? AppTheme.grey300 : AppTheme.grey600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                Text(
                  'Current: ${themeMode.themeName} ${themeMode.themeEmoji}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.brightness_6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: isDark ? AppTheme.grey300 : AppTheme.grey600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                Text(
                  'English (US)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorSetting() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.color_lens,
            color: isDark ? AppTheme.grey300 : AppTheme.grey600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accent Color',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                Text(
                  'Maritime Blue',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySetting(String title, String value, bool isEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Symbols.check_circle : Symbols.circle,
            color: isEnabled ? AppTheme.successGreen : AppTheme.grey400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle toggle
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(String title, bool isEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Symbols.notifications_active : Symbols.notifications_off,
            color: isEnabled ? AppTheme.infoCyan : AppTheme.grey400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.grey900,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle toggle
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationSetting(String title, String status, Color statusColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.power,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.grey900,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.settings,
            size: 16,
            color: isDark ? AppTheme.grey400 : AppTheme.grey600,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSetting(String title, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.grey50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.info,
            color: isDark ? AppTheme.grey300 : AppTheme.grey600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.grey900,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.refresh, color: AppTheme.warningOrange),
            const SizedBox(width: 8),
            Text(
              'Reset Settings',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle reset
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text(
              'Clear All Data',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all data. This action cannot be undone!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle clear data
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text(
              'Clear Data',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
