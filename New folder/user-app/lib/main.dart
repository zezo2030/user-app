import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/di/auth_injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'core/routes/app_route_generator.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await firebaseBackgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting User App...');

  // Initialize Firebase
  try {
    await FirebaseService.instance.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
  }

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
  const MyApp({super.key});

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
        theme: AppTheme.lightTheme,

        // Dark Theme
        darkTheme: AppTheme.darkTheme,

        // Force light mode always
        themeMode: ThemeMode.light,

        // Routes
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRouteGenerator.generateRoute,
      ),
    );
  }
}
