import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeToggled extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ThemeLoaded extends ThemeEvent {}

// Theme States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoadedState extends ThemeState {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeLoadedState({
    required this.themeMode,
    required this.isDark,
  });

  @override
  List<Object?> get props => [themeMode, isDark];
}

// Theme Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeLoaded(ThemeLoaded event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final themeMode = ThemeMode.values[themeIndex];
      
      emit(ThemeLoadedState(
        themeMode: themeMode,
        isDark: themeMode == ThemeMode.dark,
      ));
    } catch (e) {
      emit(const ThemeLoadedState(
        themeMode: ThemeMode.system,
        isDark: false,
      ));
    }
  }

  Future<void> _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final currentState = state;
    if (currentState is ThemeLoadedState) {
      final newThemeMode = currentState.isDark ? ThemeMode.light : ThemeMode.dark;
      await _saveTheme(newThemeMode);
      
      emit(ThemeLoadedState(
        themeMode: newThemeMode,
        isDark: newThemeMode == ThemeMode.dark,
      ));
    }
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    await _saveTheme(event.themeMode);
    
    emit(ThemeLoadedState(
      themeMode: event.themeMode,
      isDark: event.themeMode == ThemeMode.dark,
    ));
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Handle error silently
    }
  }
}
