import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  SendOtpEvent(this.phone);
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  VerifyOtpEvent(this.phone, this.otp);
}

class CreateAccountEvent extends AuthEvent {
  final String phone;
  final String nickname;
  CreateAccountEvent(this.phone, this.nickname);
}