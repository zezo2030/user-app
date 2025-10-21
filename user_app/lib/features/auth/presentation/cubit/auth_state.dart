import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class OtpSent extends AuthState {
  final String email;

  const OtpSent({required this.email});

  @override
  List<Object> get props => [email];
}

class OtpVerified extends AuthState {
  final AuthResponseEntity authResponse;

  const OtpVerified({required this.authResponse});

  @override
  List<Object> get props => [authResponse];
}

class RegisterOtpSent extends AuthState {
  final String email;

  const RegisterOtpSent({required this.email});

  @override
  List<Object> get props => [email];
}

class RegisterSuccess extends AuthState {
  final AuthResponseEntity authResponse;

  const RegisterSuccess({required this.authResponse});

  @override
  List<Object> get props => [authResponse];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
