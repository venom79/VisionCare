import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/features_page.dart';
import '../screens/cataract_scan_screen.dart';
import '../screens/history_screen.dart';
import '../screens/screening_detail_screen.dart';
import '../screens/doctor_pending_screen.dart';




class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const features = '/features';
  static const scan = '/scan';
  static const history = '/history';
  static const screeningDetail = '/screening-detail';
  static const doctorPending = '/doctor/pending';



  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case features:
        return MaterialPageRoute(builder: (_) => const FeaturesPage());
      case scan:
        return MaterialPageRoute(
          builder: (_) => const CataractScanScreen(),
        );
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case screeningDetail:
        final screeningId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ScreeningDetailScreen(
            screeningId: screeningId,
          ),
        );
      case doctorPending:
        return MaterialPageRoute(
          builder: (_) => const DoctorPendingScreen(),
        );


      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
