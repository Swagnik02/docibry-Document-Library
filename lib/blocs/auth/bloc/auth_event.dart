import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthEventRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegisterRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthEventLogoutRequested extends AuthEvent {
  const AuthEventLogoutRequested();
}
