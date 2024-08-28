import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String username;

  AuthLoginRequested({required this.email, required this.username});

  @override
  List<Object?> get props => [email, username];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String username;

  AuthRegisterRequested({required this.email, required this.username});

  @override
  List<Object?> get props => [email, username];
}

class AuthLogoutRequested extends AuthEvent {}
