import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/complete_registration_screen.dart';
import '../../features/auth/presentation/screens/kinetic_login_screen.dart';
import '../../features/auth/presentation/screens/kinetic_otp_login_screen.dart';
import '../../features/auth/presentation/screens/kinetic_otp_verify_screen.dart';
import '../../features/auth/presentation/screens/otp_login_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/booking/presentation/pages/hall_booking_wizard_page.dart';
import '../../features/bookings/presentation/my_bookings_page.dart';
import '../../features/home/presentation/pages/branch_details_page.dart';
import '../../features/home/presentation/pages/hall_details_page.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/trips/domain/entities/school_trip_request_entity.dart';
import '../../features/trips/presentation/pages/trip_request_details_page.dart';
import '../../features/trips/presentation/pages/trip_request_wizard_page.dart';
import '../../features/trips/presentation/pages/trip_requests_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const otpLogin = '/otp-login';
  static const otpLoginKinetic = '/otp-login-kinetic';
  static const register = '/register';
  static const otpVerify = '/otp-verify';
  static const otpVerifyKinetic = '/otp-verify-kinetic';
  static const completeRegistration = '/complete-registration';
  static const profile = '/profile';
  static const main = '/main';
  static const branchDetails = '/branch-details';
  static const hallDetails = '/hall-details';
  static const myBookings = '/my-bookings';
  static const hallBookingWizard = '/hall-booking-wizard';
  static const schoolTrips = '/school-trips';
  static const schoolTripsCreate = '/school-trips/create';
  static const schoolTripsDetails = '/school-trips/details';
  static const notifications = '/notifications';
}

class AppRouteGenerator {
  const AppRouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      case AppRoutes.login:
        return _buildSoftFadeRoute(
          settings: settings,
          page: const KineticLoginScreen(),
        );
      case AppRoutes.otpLogin:
        return MaterialPageRoute(builder: (context) => const OtpLoginScreen());
      case AppRoutes.otpLoginKinetic:
        return _buildSoftFadeRoute(
          settings: settings,
          page: const KineticOtpLoginScreen(),
        );
      case AppRoutes.register:
        return _buildSoftFadeRoute(
          settings: settings,
          page: const RegisterScreen(),
        );
      case AppRoutes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildSoftFadeRoute(
          settings: settings,
          page: OtpVerifyScreen(
            phone: args?['phone'] ?? '',
            isRegistration: args?['isRegistration'] ?? false,
          ),
        );
      case AppRoutes.otpVerifyKinetic:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildSoftFadeRoute(
          settings: settings,
          page: KineticOtpVerifyScreen(
            phone: args?['phone'] ?? '',
            isRegistration: args?['isRegistration'] ?? false,
          ),
        );
      case AppRoutes.completeRegistration:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildSoftFadeRoute(
          settings: settings,
          page: const CompleteRegistrationScreen(),
          arguments: args,
        );
      case AppRoutes.profile:
        return _buildSoftFadeRoute(
          settings: settings,
          page: const ProfileScreen(),
        );
      case AppRoutes.main:
        return MaterialPageRoute(builder: (context) => const MainScreen());
      case AppRoutes.branchDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) =>
              BranchDetailsPage(branchId: args?['branchId'] ?? ''),
        );
      case AppRoutes.hallDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => HallDetailsPage(hallId: args?['hallId'] ?? ''),
        );
      case AppRoutes.myBookings:
        return MaterialPageRoute(builder: (context) => const MyBookingsPage());
      case AppRoutes.hallBookingWizard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => HallBookingWizardPage(
            hallId: args?['hallId'] ?? '',
            branchId: args?['branchId'] ?? '',
            hallName: args?['hallName'] ?? '',
          ),
        );
      case AppRoutes.schoolTrips:
        return MaterialPageRoute(
          builder: (context) => const TripRequestsPage(),
        );
      case AppRoutes.schoolTripsCreate:
        return MaterialPageRoute(
          builder: (context) => const TripRequestWizardPage(),
        );
      case AppRoutes.schoolTripsDetails:
        final args = settings.arguments;
        SchoolTripRequestEntity? request;
        if (args is SchoolTripRequestEntity) {
          request = args;
        } else if (args is Map<String, dynamic>) {
          request = args['request'] as SchoolTripRequestEntity?;
        }
        final requestId =
            request?.id ??
            (args is Map<String, dynamic>
                ? args['requestId'] as String?
                : null);
        return MaterialPageRoute(
          builder: (context) => TripRequestDetailsPage(
            requestId: requestId ?? request?.id ?? '',
            initialRequest: request,
          ),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (context) => const NotificationsPage(),
        );
      default:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
    }
  }
}

PageRoute<dynamic> _buildSoftFadeRoute({
  required RouteSettings settings,
  Map<String, dynamic>? arguments,
  required Widget page,
}) {
  final routeSettings = RouteSettings(
    name: settings.name,
    arguments: arguments ?? settings.arguments,
  );

  return PageRouteBuilder(
    settings: routeSettings,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(curvedAnimation);
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
  );
}
