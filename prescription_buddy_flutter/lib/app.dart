import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class PrescriptionBuddyApp extends StatelessWidget {
  const PrescriptionBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthScreen(),
    );
  }
}
