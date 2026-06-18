import 'package:booking_villa/data/repositories/auth_repository.dart';
import 'package:booking_villa/logic/bloc/auth/auth_event.dart';
import 'package:booking_villa/logic/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userProfile = await authRepository.login(event.request);
        emit(AuthSuccess(userProfile));
      } catch (e) {
        String msg = e.toString();

        msg = msg.replaceAll('Exception: ', '');
        msg = msg.replaceAll('exception: ', '');
        emit(AuthFailure(msg));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(
          event.request,
          event.nama,
          event.notelp,
          photoUrl: event.photoUrl, 
        );
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await authRepository.logout();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      try {
        final isLoggedIn = await authRepository.isLoggedIn();
        if (isLoggedIn) {
          final user = await authRepository.getUser();
          emit(AuthSuccess(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(Unauthenticated());
      }
    });
  }
}
