import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/services/agency_access.dart';
import '../../common/services/api_client.dart';
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
        if (AgencyAccess.isAgencyAccount(response.data)) {
          if (mounted) context.go(AppRoutes.home);
          return;
        }

        await ApiClient().tokenStorage.clearCookies();
        if (mounted) context.go(AppRoutes.login);
      } else {
        // Not authenticated
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (e) {
      // Error or not authenticated
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 220,
                    maxHeight: 220,
                  ),
                  child: Image.asset(
                    'assets/img/logo/logo_black.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
