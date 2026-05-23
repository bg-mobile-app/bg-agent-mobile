import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/services/auth_service.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      final response = await authService.getCurrentUser();
      
      if (response.statusCode == 200) {
        // User is authenticated
        // Extract role if needed, e.g., final role = response.data['role'];
        // For now, route to home or dashboard
        if (mounted) context.go(AppRoutes.home);
      } else {
        // Not authenticated
        if (mounted) context.go(AppRoutes.getStarted);
      }
    } catch (e) {
      // Error or not authenticated
      if (mounted) context.go(AppRoutes.getStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
                  child: Image.asset(
                    'assets/img/logo/logo_white.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
