import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthStateLoggedOut()) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventLoginRequested>(_onLoginRequested);
    on<AuthEventRegisterRequested>(_onRegisterRequested);
    on<AuthEventLogoutRequested>(_onLogoutRequested);
  }

  void _onInitialize(AuthEventInitialize event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthStateLoggedIn(user));
    } else {
      emit(AuthStateLoggedOut());
    }
  }

  void _onLoginRequested(
      AuthEventLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading(loadingText: 'Logging in...'));
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthStateLoggedIn(userCredential.user!));
    } catch (e) {
      emit(AuthStateError(e.toString()));
      emit(AuthStateLoggedOut());
    }
  }

  void _onRegisterRequested(
      AuthEventRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoading(loadingText: 'Registering...'));
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthStateLoggedIn(userCredential.user!));
    } catch (e) {
      emit(AuthStateError(e.toString()));
      emit(AuthStateLoggedOut());
    }
  }

  void _onLogoutRequested(
      AuthEventLogoutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(AuthStateLoggedOut());
  }
}
