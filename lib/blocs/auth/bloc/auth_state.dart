import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Base state class for authentication
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Loading state
class AuthStateLoading extends AuthState {
  final String? loadingText;

  const AuthStateLoading({this.loadingText});

  bool get isLoading => true;

  @override
  List<Object?> get props => [loadingText];
}

// Logged-in state
class AuthStateLoggedIn extends AuthState {
  final User user;

  const AuthStateLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

// Logged-out state
class AuthStateLoggedOut extends AuthState {}

// Registering state
class AuthStateRegistering extends AuthState {}

// Error state
class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
