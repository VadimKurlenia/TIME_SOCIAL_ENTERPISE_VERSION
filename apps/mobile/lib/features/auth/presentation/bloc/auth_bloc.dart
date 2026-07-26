import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_models.dart';

abstract class AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final String login;
  final String password;
  AuthLoginSubmitted({required this.login, required this.password});
}

class AuthRegisterSubmitted extends AuthEvent {
  final UserCreateRequest request;
  AuthRegisterSubmitted(this.request);
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {}

class AuthRegisterSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.login(
          login: event.login,
          password: event.password,
        );
        emit(AuthLoginSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<AuthRegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.register(event.request);
        emit(AuthRegisterSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
