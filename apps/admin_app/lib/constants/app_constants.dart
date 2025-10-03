class AppConstants {
  // App Information
  static const String appName = 'Maritime Admin Portal';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Admin Portal for Maritime Procurement ERP';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String tenantKey = 'tenant_id';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // Maritime Theme Colors
  static const int primaryBlue = 0xFF1E3A8A;
  static const int secondaryBlue = 0xFF3B82F6;
  static const int accentBlue = 0xFF60A5FA;
  static const int successGreen = 0xFF10B981;
  static const int warningOrange = 0xFFF59E0B;
  static const int errorRed = 0xFFEF4444;
  static const int infoCyan = 0xFF06B6D4;
  
  // Demo Data
  static const String demoEmail = 'admin@maritime-procurement.com';
  static const String demoPassword = 'AdminPass123!';
  
  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableAnimations = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
}
