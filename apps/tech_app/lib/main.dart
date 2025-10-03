import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/theme/app_theme.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'screens/auth/modern_login_screen.dart';
import 'screens/dashboard/modern_dashboard_screen.dart';

void main() {
  runApp(const MaritimeTechApp());
}

class MaritimeTechApp extends StatelessWidget {
  const MaritimeTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(ThemeLoaded()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          ThemeMode themeMode = ThemeMode.system;
          
          if (themeState is ThemeLoadedState) {
            themeMode = themeState.themeMode;
          }
          
          return MaterialApp.router(
            title: 'Maritime Procurement ERP - Technical Portal',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const ModernLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const ModernDashboardScreen(),
    ),
  ],
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    
    // If user is authenticated and trying to access login, redirect to dashboard
    if (authState is AuthAuthenticated && state.uri.path == '/login') {
      return '/dashboard';
    }
    
    // If user is not authenticated and trying to access protected routes, redirect to login
    if (authState is! AuthAuthenticated && state.uri.path != '/login') {
      return '/login';
    }
    
    return null;
  },
);