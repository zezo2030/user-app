import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/register_send_otp_usecase.dart';
import '../../domain/usecases/register_verify_otp_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterSendOtpUseCase registerSendOtpUseCase;
  final RegisterVerifyOtpUseCase registerVerifyOtpUseCase;
  final GetProfileUseCase getProfileUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final SecureStorageService _storageService =
      GetIt.instance<SecureStorageService>();

  AuthCubit({
    required this.loginUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerSendOtpUseCase,
    required this.registerVerifyOtpUseCase,
    required this.getProfileUseCase,
    required this.refreshTokenUseCase,
  }) : super(AuthInitial());

  // Login with email/phone and password
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      identifier: identifier,
      password: password,
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      authResponse,
    ) async {
      // Save tokens
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user data
      await _storageService.saveUserData(authResponse.user.toString());

      emit(Authenticated(user: authResponse.user));
    });
  }

  // Send OTP for login
  Future<void> sendOtp({required String email, String language = 'ar'}) async {
    print('🚀 Starting sendOtp for email: $email, language: $language');
    emit(AuthLoading());

    final result = await sendOtpUseCase(email: email, language: language);

    result.fold(
      (failure) {
        print('❌ SendOtp failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (success) {
        print('✅ SendOtp successful for email: $email');
        emit(OtpSent(email: email));
      },
    );
  }

  // Verify OTP for login
  Future<void> verifyOtp({
    required String email,
    required String otp,
    String? name,
  }) async {
    print('🚀 Starting verifyOtp for email: $email, otp: $otp, name: $name');
    emit(AuthLoading());

    final result = await verifyOtpUseCase(email: email, otp: otp, name: name);

    result.fold(
      (failure) {
        print('❌ VerifyOtp failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (authResponse) async {
        print('✅ VerifyOtp successful, saving tokens...');
        // Save tokens
        await _storageService.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        // Save user data
        await _storageService.saveUserData(authResponse.user.toString());

        print('✅ Tokens and user data saved successfully');
        emit(OtpVerified(authResponse: authResponse));
      },
    );
  }

  // Send OTP for registration
  Future<void> registerSendOtp({
    required String name,
    required String email,
    required String password,
    String? phone,
    String language = 'ar',
  }) async {
    emit(AuthLoading());

    final result = await registerSendOtpUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      language: language,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (success) => emit(RegisterOtpSent(email: email)),
    );
  }

  // Verify OTP for registration
  Future<void> registerVerifyOtp({
    required String email,
    required String otp,
  }) async {
    emit(AuthLoading());

    final result = await registerVerifyOtpUseCase(email: email, otp: otp);

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      authResponse,
    ) async {
      // Save tokens
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user data
      await _storageService.saveUserData(authResponse.user.toString());

      emit(RegisterSuccess(authResponse: authResponse));
    });
  }

  // Get user profile
  Future<void> getProfile() async {
    emit(AuthLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  // Refresh token
  Future<void> refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) {
      emit(Unauthenticated());
      return;
    }

    final result = await refreshTokenUseCase(refreshToken: refreshToken);

    result.fold((failure) => emit(Unauthenticated()), (authResponse) async {
      // Save new tokens
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user data
      await _storageService.saveUserData(authResponse.user.toString());

      emit(Authenticated(user: authResponse.user));
    });
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearTokens();
    emit(Unauthenticated());
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      await getProfile();
    } else {
      emit(Unauthenticated());
    }
  }
}
