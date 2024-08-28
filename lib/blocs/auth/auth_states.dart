import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoggedIn extends AuthState {
  final String userEmail;

  AuthLoggedIn({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

class AuthLoggedOut extends AuthState {}

class AuthError extends AuthState {
  final String error;

  AuthError({required this.error});

  @override
  List<Object?> get props => [error];
}
