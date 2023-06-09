import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:book_mate/blocs/auth/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late final StreamSubscription authSubscription;
  AuthBloc({required this.authRepository}) : super(AuthState.unknown()) {
    authSubscription = authRepository.user.listen((fb_auth.User? user) {
      add(AuthStateChangedEvent(user: user));
    });

    on<AuthStateChangedEvent>((event, emit) {
      if (event.user != null) {
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          user: event.user,
        ));
      } else {
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          user: null,
        ));
      }
    });

    on<LogOutRequestedEvent>((event, emit) async {
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: null,
      ));
      await authRepository.logOut();
    });
  }
}