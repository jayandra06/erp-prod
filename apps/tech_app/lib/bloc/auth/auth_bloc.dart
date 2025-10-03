import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_ui/services/api_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthTokenRefreshRequested extends AuthEvent {}

class AuthUserProfileRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  final Map<String, dynamic> tenant;

  const AuthAuthenticated({
    required this.user,
    required this.tenant,
  });

  @override
  List<Object> get props => [user, tenant];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthUserProfileRequested>(_onUserProfileRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      print('🔐 Attempting login for: ${event.email}');
      
      final response = await ApiService.login(
        email: event.email,
        password: event.password,
        userType: 'technical',
      );

      print('🔐 Login response received: $response');

      if (response['user'] != null) {
        print('🔐 User data found, emitting AuthAuthenticated');
        emit(AuthAuthenticated(
          user: response['user'],
          tenant: response['user']['tenant'] ?? {},
        ));
      } else {
        print('🔐 No user data in response, emitting AuthError');
        emit(const AuthError(message: 'Login failed: Invalid response'));
      }
    } catch (e) {
      print('🔐 Login error: $e');
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await ApiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    emit(AuthUnauthenticated());
  }

  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await ApiService.refreshAccessToken();
      add(AuthUserProfileRequested());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUserProfileRequested(
    AuthUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await ApiService.getCurrentUser();
      
      if (response['user'] != null) {
        emit(AuthAuthenticated(
          user: response['user'],
          tenant: response['user']['tenant'] ?? {},
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
