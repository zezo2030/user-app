import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/constants/api_constants.dart';
import 'features/auth/di/auth_injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/otp_login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/otp_verify_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/home/presentation/pages/branch_details_page.dart';
import 'features/home/presentation/pages/hall_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting User App...');

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  print('✅ EasyLocalization initialized');

  // Initialize dependency injection
  await init();
  print('✅ Dependency injection initialized');

  // Print API endpoints
  ApiConstants.printEndpoints();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>()..checkAuthStatus(),
      child: MaterialApp(
        title: 'User App',
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: Colors.black26,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        // Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: Colors.black26,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        // Routes
        initialRoute: '/welcome',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/welcome':
              return MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              );

            case '/login':
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );

            case '/otp-login':
              return MaterialPageRoute(
                builder: (context) => const OtpLoginScreen(),
              );

            case '/register':
              return MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              );

            case '/otp-verify':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => OtpVerifyScreen(
                  email: args?['email'] ?? '',
                  isRegistration: args?['isRegistration'] ?? false,
                ),
              );

            case '/profile':
              return MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              );

            case '/main':
              return MaterialPageRoute(
                builder: (context) => const MainScreen(),
              );

            case '/branch-details':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => BranchDetailsPage(
                  branchId: args?['branchId'] ?? '',
                ),
              );

            case '/hall-details':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => HallDetailsPage(
                  hallId: args?['hallId'] ?? '',
                ),
              );

            default:
              return MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              );
          }
        },
      ),
    );
  }
}
