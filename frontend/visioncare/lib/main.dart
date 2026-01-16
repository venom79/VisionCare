import 'package:flutter/material.dart';
import 'routes/app_routes.dart';


void main() {
  runApp(const VisionCareApp());
}

class VisionCareApp extends StatelessWidget {
  const VisionCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VisionCare',
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

