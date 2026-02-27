import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  OtpSentState({
    required this.phone,
    required this.otp,
    required this.userExists,
     this.nickname,
    this.token,
  });

  @override
  List<Object?> get props => [phone, otp, userExists, nickname, token];
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String msg;
  AuthError(this.msg);

  @override
  List<Object?> get props => [msg];
}