class ApiConstants {
  // Base URL - Choose the appropriate one based on your setup:
  // For production server:
  // static const String baseUrl = 'http://72.61.159.84:3000/api/v1';

  // For Android emulator:
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // For iOS simulator (if needed):
  // static const String baseUrl = 'http://localhost:3000/api/v1';

  // For physical device on same network (replace with your computer's IP):
  // static const String baseUrl = 'http://192.168.1.3:3000/api/v1';

  static void printEndpoints() {
    print('🌐 API Endpoints:');
    print('   Base URL: $baseUrl');
    print('   Login: $baseUrl$loginEndpoint');
    print('   Register: $baseUrl$registerEndpoint');
    print('   Send OTP: $baseUrl$sendOtpEndpoint');
    print('   Verify OTP: $baseUrl$verifyOtpEndpoint');
    print('   Register Send OTP: $baseUrl$registerSendOtpEndpoint');
    print('   Register Verify OTP: $baseUrl$registerVerifyOtpEndpoint');
    print('   Profile: $baseUrl$profileEndpoint');
    print('   Refresh Token: $baseUrl$refreshTokenEndpoint');
  }

  // Authentication Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String sendOtpEndpoint = '/auth/otp/send';
  static const String verifyOtpEndpoint = '/auth/otp/verify';
  static const String registerSendOtpEndpoint = '/auth/register/otp/send';
  static const String registerVerifyOtpEndpoint = '/auth/register/otp/verify';
  static const String completeRegistrationEndpoint = '/auth/register/complete';
  static const String profileEndpoint = '/auth/me';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String emailConfigEndpoint = '/auth/email-config';
  static const String updateLanguageEndpoint = '/auth/language';

  // User Profile Endpoints
  static const String updateProfileEndpoint = '/users/profile';

  // Home Endpoints
  static const String homeEndpoint = '/home';
  static const String branchDetailsEndpoint = '/content/branches';
  static const String branchesEndpoint = '/content/branches';
  static const String hallsEndpoint = '/content/halls';

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
