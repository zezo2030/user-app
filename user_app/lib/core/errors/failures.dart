import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure({
    required this.message,
    this.statusCode,
  });
  
  @override
  List<Object?> get props => [message, statusCode];
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required String message,
  }) : super(message: message);
}

// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    required String message,
  }) : super(message: message);
}

class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({
    required String message,
  }) : super(message: message);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
  }) : super(message: message);
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure({
    required String message,
  }) : super(message: message);
}

// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
  }) : super(message: message);
}

