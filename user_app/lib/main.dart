import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/di/auth_injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'core/routes/app_route_generator.dart';
import 'features/notifications/data/models/notification_model.dart';
import 'features/notifications/data/datasources/notifications_local_datasource.dart';
import 'features/notifications/services/firebase_messaging_service.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';

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

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NotificationModelAdapter());
  print('✅ Hive initialized');

  // Initialize Notification Services
  final localDataSource = NotificationsLocalDataSource();
  await localDataSource.init();

  final messagingService = FirebaseMessagingService(localDataSource);
  await messagingService.initialize();
  print('✅ Notification services initialized');

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
      child: MyApp(localDataSource: localDataSource),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationsLocalDataSource localDataSource;

  const MyApp({super.key, required this.localDataSource});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(
          create: (context) =>
              NotificationsCubit(localDataSource)..loadNotifications(),
        ),
      ],
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
