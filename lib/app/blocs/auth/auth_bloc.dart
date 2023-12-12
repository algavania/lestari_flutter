import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lestari_flutter/app/repositories/auth/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<LoginWithPasswordEvent>(_loginWithPassword);
    on<RegisterWithPasswordEvent>(_registerWithPassword);
    on<AuthWithGoogleEvent>(_authWithGoogle);
  }

  Future<void> _loginWithPassword(LoginWithPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.loginWithPassword(event.email, event.password);
      emit(const AuthLoaded());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _registerWithPassword(RegisterWithPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.registerWithPassword(event.email, event.password, event.displayName);
      emit(const AuthLoaded());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _authWithGoogle(AuthWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _repository.fetchGoogleUserCredential();
      await _repository.socialAuth(isLogin: event.isLogin, userCredential: userCredential);
      emit(const AuthLoaded());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
