import 'package:expense_manager/features/auth/service/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<CreateAccountEvent>(_onCreateAccount);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final res = await authService.sendOtp(event.phone);

      final otp = res['otp'];
      if (otp == null || otp.toString().isEmpty) {
        emit(AuthError("Unable to send OTP"));
        return;
      }

      final userExists = res['user_exists'] ?? false;
      final nickname = res['nickname']?.toString();
      final token = res['token']?.toString();

      
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        if (nickname != null) {
          await prefs.setString("nickname", nickname);
        }
        print(" Token saved from SendOtp");
      }

      emit(
        OtpSentState(
          phone: event.phone,
          otp: otp.toString(),
          userExists: userExists,
          nickname: nickname,
          token: token,
        ),
      );
    } catch (e) {
      emit(AuthError("Unable to send OTP"));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      
      final res = await authService.createAccount(event.phone, event.nickname);
      print("API response: $res"); 

      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res['token']);
      await prefs.setString("nickname", event.nickname);
      print("Saved locally: token=${res['token']}, nickname=${event.nickname}");

      
      final savedToken = prefs.getString("token");
      final savedNickname = prefs.getString("nickname");

      if (savedToken != null && savedNickname != null) {
        print(" Local save confirmed: $savedNickname / $savedToken");
      } else {
        print(" Local save failed!");
        emit(AuthError("Local save failed"));
        return;
      }

  
      emit(AuthSuccess());
    } catch (e, st) {
      print(" SendOtp exception: $e\n$st"); 
      emit(AuthError("Unable to create account"));
    }
  }
}
