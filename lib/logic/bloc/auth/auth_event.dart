import 'package:booking_villa/data/models/auth_request.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final AuthRequest request;
  LoginRequested(this.request);
}

class RegisterRequested extends AuthEvent {
  final AuthRequest request;
  final String nama;
  final String notelp;
  final String? photoUrl;
  RegisterRequested(this.request, this.nama, this.notelp, {this.photoUrl});
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}