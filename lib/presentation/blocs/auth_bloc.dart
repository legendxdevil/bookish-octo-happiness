import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignInWithGoogleRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordResetEmailSent extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final user = _storageService.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } on AuthFailure catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(Authenticated(user: user));
    } on AuthFailure catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.signInWithGoogle();
      emit(Authenticated(user: user));
    } on AuthFailure catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authService.signOut();
      emit(Unauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authService.resetPassword(event.email);
      emit(PasswordResetEmailSent());
    } on AuthFailure catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }
}
