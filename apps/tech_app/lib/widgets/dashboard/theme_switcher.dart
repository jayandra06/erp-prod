import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_theme.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final currentTheme = Theme.of(context).brightness;
    final newTheme = currentTheme == Brightness.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    
    // Animate the switch
    if (newTheme == ThemeMode.dark) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    // TODO: Implement theme switching logic
    // This would typically use a theme provider or state management
    print('Switching to ${newTheme == ThemeMode.dark ? 'dark' : 'light'} theme');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 3.14159, // 180 degrees
          child: IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.amber : Colors.grey[700],
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}
