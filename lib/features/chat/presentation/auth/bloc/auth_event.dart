part of 'auth_bloc.dart';

abstract class AuthEvent {}

/// User tapped "Send OTP"
class SendOtpRequested extends AuthEvent {
  final String phone;
  final String name;
  SendOtpRequested({required this.phone, required this.name});
}

/// User submitted the 6-digit OTP
class VerifyOtpRequested extends AuthEvent {
  final String otp;
  final String name;
  VerifyOtpRequested({required this.otp, required this.name});
}

/// User tapped "Wrong number? Change"
class OtpResetRequested extends AuthEvent {}

/// App cold-started — check if Firebase session exists
class SessionRestoreRequested extends AuthEvent {}

/// User tapped logout
class LogoutRequested extends AuthEvent {}
