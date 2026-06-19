import 'package:app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase _sendOtp;
  final VerifyOtpUseCase _verifyOtp;
  final LogoutUseCase _logout;
  final RestoreSessionUseCase _restoreSession;

  // Persisted across events so VerifyOtpRequested can use it
  String _currentPhone = '';
  String _currentName  = '';

  AuthBloc({
    required SendOtpUseCase sendOtp,
    required VerifyOtpUseCase verifyOtp,
    required LogoutUseCase logout,
    required RestoreSessionUseCase restoreSession,
  })  : _sendOtp        = sendOtp,
        _verifyOtp      = verifyOtp,
        _logout         = logout,
        _restoreSession = restoreSession,
        super(AuthInitial()) {
    on<SessionRestoreRequested>(_onRestoreSession);
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<OtpResetRequested>(_onOtpReset);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onRestoreSession(
      SessionRestoreRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final session = await _restoreSession();
    if (session != null) {
      _currentPhone = session.phone;
      _currentName  = session.name;
      emit(AuthAuthenticated(phone: session.phone, name: session.name));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onSendOtp(
      SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _currentPhone = event.phone;
    _currentName  = event.name;
    try {
      await _sendOtp(event.phone);
      emit(OtpSent(phone: event.phone, name: event.name));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // verificationId is stored in repository between sendOtp and verifyOtp
    final result = await _verifyOtp(event.otp, '', event.name);
    if (result.success) {
      _currentPhone = result.phone!;
      _currentName  = result.name!;
      emit(AuthAuthenticated(phone: result.phone!, name: result.name!));
    } else {
      emit(AuthError(
        message: result.error ?? 'Verification failed.',
        wasOtpStage: true,
      ));
    }
  }

  void _onOtpReset(OtpResetRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  Future<void> _onLogout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _logout(_currentPhone);
    _currentPhone = '';
    _currentName  = '';
    emit(AuthInitial());
  }
}
