import 'package:booking_villa/data/models/profiles.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthSuccess extends AuthState {
  final ProfilesModel user;
  AuthSuccess(this.user);
}

class Unauthenticated extends AuthState {}