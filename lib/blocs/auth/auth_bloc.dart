import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:docibry/services/firestore_helper.dart';
import 'auth_events.dart';
import 'auth_states.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      bool usernameExists = await _firestoreHelper.checkUsernameExists(
        event.email,
        event.username,
      );

      if (usernameExists) {
        emit(AuthLoggedIn(userEmail: event.email));
      } else {
        emit(AuthError(error: 'Login failed: Incorrect username or email.'));
      }
    } catch (e) {
      log('Error during login: $e');
      emit(AuthError(error: 'Login failed: $e'));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    try {
      bool emailExists = await _firestoreHelper.checkEmailExists(event.email);

      if (!emailExists) {
        // Register user
        await _firestoreHelper.databaseRegister(event.email, event.username);
        emit(AuthLoggedIn(userEmail: event.email));
      } else {
        emit(AuthError(error: 'Email already registered.'));
      }
    } catch (e) {
      log('Error during registration: $e');
      emit(AuthError(error: 'Registration failed: $e'));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoggedOut());
    } catch (e) {
      log('Error during logout: $e');
      emit(AuthError(error: 'Logout failed: $e'));
    }
  }
}
