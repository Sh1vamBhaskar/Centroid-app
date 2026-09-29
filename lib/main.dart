import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CentroidApp());
}

class CentroidApp extends StatelessWidget {
  const CentroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Centroid',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}