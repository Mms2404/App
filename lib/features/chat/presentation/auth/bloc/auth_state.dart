part of 'auth_bloc.dart';

abstract class AuthState {}

/// Initial / logged out state
class AuthInitial extends AuthState {}

/// Waiting for Firebase to respond
class AuthLoading extends AuthState {}

/// OTP was sent — show OTP input
class OtpSent extends AuthState {
  final String phone;
  final String name; // preserve so user doesn't retype
  OtpSent({required this.phone, required this.name});
}

/// Firebase sign-in succeeded
class AuthAuthenticated extends AuthState {
  final String phone;
  final String name;
  AuthAuthenticated({required this.phone, required this.name});
}

/// Something went wrong
class AuthError extends AuthState {
  final String message;
  // Which stage failed — so UI knows whether to show phone or OTP field
  final bool wasOtpStage;
  AuthError({required this.message, this.wasOtpStage = false});
}
