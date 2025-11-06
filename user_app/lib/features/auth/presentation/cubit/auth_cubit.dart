import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/register_send_otp_usecase.dart';
import '../../domain/usecases/register_verify_otp_usecase.dart';
import '../../domain/usecases/complete_registration_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/refresh_profile_usecase.dart';
import '../../domain/usecases/update_language_usecase.dart';
import '../../data/models/update_profile_dto.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterSendOtpUseCase registerSendOtpUseCase;
  final RegisterVerifyOtpUseCase registerVerifyOtpUseCase;
  final CompleteRegistrationUseCase completeRegistrationUseCase;
  final GetProfileUseCase getProfileUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final RefreshProfileUseCase refreshProfileUseCase;
  final UpdateLanguageUseCase updateLanguageUseCase;
  final SecureStorageService _storageService =
      GetIt.instance<SecureStorageService>();

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerSendOtpUseCase,
    required this.registerVerifyOtpUseCase,
    required this.completeRegistrationUseCase,
    required this.getProfileUseCase,
    required this.refreshTokenUseCase,
    required this.updateProfileUseCase,
    required this.refreshProfileUseCase,
    required this.updateLanguageUseCase,
  }) : super(AuthInitial());

  // Login with phone and password
  Future<void> login({required String phone, required String password}) async {
    emit(AuthLoading());

    final result = await loginUseCase(phone: phone, password: password);

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

  // Register with email and password
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String language = 'ar',
  }) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      language: language,
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

      emit(RegisterSuccess(authResponse: authResponse));
    });
  }

  // Send OTP for login
  Future<void> sendOtp({required String phone, String language = 'ar'}) async {
    print('🚀 Starting sendOtp for phone: $phone, language: $language');
    emit(AuthLoading());

    final result = await sendOtpUseCase(phone: phone, language: language);

    result.fold(
      (failure) {
        print('❌ SendOtp failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (success) {
        print('✅ SendOtp successful for phone: $phone');
        emit(OtpSent(phone: phone));
      },
    );
  }

  // Verify OTP for login
  Future<void> verifyOtp({required String phone, required String otp}) async {
    print('🚀 Starting verifyOtp for phone: $phone, otp: $otp');
    emit(AuthLoading());

    final result = await verifyOtpUseCase(phone: phone, otp: otp);

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
    required String phone,
    String language = 'ar',
  }) async {
    emit(AuthLoading());

    final result = await registerSendOtpUseCase(
      phone: phone,
      language: language,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (success) => emit(RegisterOtpSent(phone: phone)),
    );
  }

  // Verify OTP for registration
  Future<void> registerVerifyOtp({
    required String phone,
    required String otp,
  }) async {
    emit(AuthLoading());

    final result = await registerVerifyOtpUseCase(phone: phone, otp: otp);

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      response,
    ) {
      // Check if registration requires completion
      if (response['requiresCompletion'] == true) {
        emit(RegistrationIncomplete(phone: phone));
      } else {
        emit(AuthError(message: 'Unexpected response from server'));
      }
    });
  }

  // Complete registration with name and password
  Future<void> completeRegistration({
    required String phone,
    required String name,
    required String password,
    String language = 'ar',
  }) async {
    emit(AuthLoading());

    final result = await completeRegistrationUseCase(
      phone: phone,
      name: name,
      password: password,
      language: language,
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      authResponse,
    ) async {
      print('🔐 [Complete Registration] Received tokens from backend:');
      print('   Access Token: ${authResponse.accessToken.substring(0, 50)}...');
      print(
        '   Refresh Token: ${authResponse.refreshToken.substring(0, 50)}...',
      );
      print('   User ID: ${authResponse.user.id}');
      print('   User Name: ${authResponse.user.name}');

      // Save tokens
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Verify tokens were saved
      final savedAccessToken = await _storageService.getAccessToken();
      final savedRefreshToken = await _storageService.getRefreshToken();
      print('💾 [Complete Registration] Tokens saved to storage:');
      print(
        '   Saved Access Token: ${savedAccessToken?.substring(0, 50) ?? "NULL"}...',
      );
      print(
        '   Saved Refresh Token: ${savedRefreshToken?.substring(0, 50) ?? "NULL"}...',
      );
      print(
        '   Tokens match: ${savedAccessToken == authResponse.accessToken && savedRefreshToken == authResponse.refreshToken}',
      );

      // Save user data
      await _storageService.saveUserData(authResponse.user.toString());

      emit(RegisterSuccess(authResponse: authResponse));
    });
  }

  // Get user profile
  Future<void> getProfile() async {
    if (isClosed) return;
    emit(AuthLoading());

    final result = await getProfileUseCase();

    if (isClosed) return;
    result.fold(
      (failure) {
        print('❌ [Get Profile] Failed: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (user) {
        print('✅ [Get Profile] Success: User ${user.id} - ${user.name}');
        emit(Authenticated(user: user));
      },
    );
  }

  // Refresh token
  Future<void> refreshToken() async {
    if (isClosed) return;
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) {
      if (isClosed) return;
      emit(Unauthenticated());
      return;
    }

    print('🔄 [Refresh Token] Attempting to refresh token...');
    final result = await refreshTokenUseCase(refreshToken: refreshToken);

    if (isClosed) return;
    result.fold(
      (failure) {
        print('❌ [Refresh Token] Failed: ${failure.message}');
        emit(Unauthenticated());
      },
      (authResponse) async {
        print('✅ [Refresh Token] Token refreshed successfully');
        // Save new tokens
        await _storageService.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        // Get user profile with new token (refresh token response doesn't include user data)
        print('🔄 [Refresh Token] Fetching user profile...');
        await getProfile();
      },
    );
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearTokens();
    emit(Unauthenticated());
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    print('🔍 [Check Auth Status] Checking stored tokens...');

    // Try with access token first
    final accessToken = await _storageService.getAccessToken();
    print(
      '   Access Token: ${accessToken != null ? "${accessToken.substring(0, 50)}..." : "NULL"}',
    );

    if (accessToken != null && accessToken.isNotEmpty) {
      print('✅ [Check Auth Status] Access token found, fetching profile...');
      await getProfile();

      // Check if getProfile succeeded by checking if state changed to Authenticated
      if (isClosed) return;
      if (state is Authenticated) {
        print(
          '✅ [Check Auth Status] Profile fetch succeeded, user authenticated',
        );
        return;
      }

      // If getProfile failed (state is AuthError), try refreshing token
      if (state is AuthError) {
        print(
          '⚠️ [Check Auth Status] Profile fetch failed, trying refresh token...',
        );
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          print('🔄 [Check Auth Status] Attempting to refresh token...');
          await refreshTokenUseCase(refreshToken: refreshToken).then((
            result,
          ) async {
            if (isClosed) return;
            await result.fold(
              (_) async {
                print('❌ [Check Auth Status] Token refresh failed');
                emit(Unauthenticated());
              },
              (authResponse) async {
                print('✅ [Check Auth Status] Token refreshed successfully');
                await _storageService.saveTokens(
                  authResponse.accessToken,
                  authResponse.refreshToken,
                );
                // Get user profile with new token (refresh token response doesn't include user data)
                await getProfile();
              },
            );
          });
          return;
        }
      }
      return;
    }

    // If no access token but refresh token exists, try to refresh
    final refreshToken = await _storageService.getRefreshToken();
    print(
      '   Refresh Token: ${refreshToken != null ? "${refreshToken.substring(0, 50)}..." : "NULL"}',
    );

    if (refreshToken != null && refreshToken.isNotEmpty) {
      print(
        '🔄 [Check Auth Status] No access token, but refresh token found. Attempting refresh...',
      );
      await refreshTokenUseCase(refreshToken: refreshToken).then((
        result,
      ) async {
        await result.fold(
          (_) async {
            emit(Unauthenticated());
          },
          (authResponse) async {
            await _storageService.saveTokens(
              authResponse.accessToken,
              authResponse.refreshToken,
            );
            await _storageService.saveUserData(authResponse.user.toString());
            await getProfile();
          },
        );
      });
      return;
    }

    print('❌ [Check Auth Status] No tokens found, user is not authenticated');
    emit(Unauthenticated());
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? language,
    String? phone,
  }) async {
    emit(ProfileUpdating());

    final updateProfileDto = UpdateProfileDto(
      name: name,
      email: email,
      language: language,
      phone: phone,
    );

    final result = await updateProfileUseCase(updateProfileDto);

    result.fold(
      (failure) => emit(ProfileUpdateError(message: failure.message)),
      (user) {
        emit(ProfileUpdated(user: user));
        // Also update the authenticated state with new user data
        emit(Authenticated(user: user));
      },
    );
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    emit(AuthLoading());

    final result = await refreshProfileUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  // Update user language
  Future<void> updateLanguage(String language) async {
    emit(LanguageUpdating());

    final result = await updateLanguageUseCase(language);

    result.fold(
      (failure) => emit(LanguageUpdateError(message: failure.message)),
      (success) {
        emit(LanguageUpdated(language: language));
        // Refresh profile to get updated user data
        refreshProfile();
      },
    );
  }
}
