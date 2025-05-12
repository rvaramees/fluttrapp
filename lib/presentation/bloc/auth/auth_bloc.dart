import 'package:equatable/equatable.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';
import 'package:fluttr_app/core/usecases/usecase.dart';
import 'package:fluttr_app/domain/entities/user.dart';
import 'package:fluttr_app/domain/usecases/auth/get_current_user.dart';
import 'package:fluttr_app/domain/usecases/auth/login_usecase.dart';
import 'package:fluttr_app/domain/usecases/auth/logout_usecase.dart';
import 'package:fluttr_app/domain/usecases/auth/signup_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final SignupUseCase signup;
  final LogoutUseCase logout;
  final GetCurrentUserUseCase getCurrentUser;

  AuthBloc({
    required this.login,
    required this.signup,
    required this.logout,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthGetCurrentUser>(_onGetCurrentUser);
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await login(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onSignupRequested(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signup(SignUpParams(
        email: event.email, password: event.password, name: event.name));
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logout(NoParams());
    result.fold((failure) => emit(AuthFailure(message: failure.message)), (_) {
      emit(AuthLoggedOut());
      emit(AuthInitial());
    });
  }

  Future<void> _onGetCurrentUser(
      AuthGetCurrentUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) {
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthLoggedOut());
        }
      },
    );
  }
}
