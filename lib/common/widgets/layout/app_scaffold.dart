import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../common/services/auth_service.dart';
import '../../../features/booking/appointment_booking_screen.dart';
import '../../../features/booking/my_booking_screen.dart';
import '../../../features/booking/return_passport_screen.dart';
import '../../../features/booking/success_flight_screen.dart';
import '../../../features/chat/chat_list_screen.dart';
import '../../../features/home/change_password_screen.dart';
import '../../../features/home/check_status_screen.dart';
import '../../../features/home/customer_profile_screen.dart';
import '../../../features/home/dashboard_screen.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/home/notifications_screen.dart';
import '../../../features/home/payments_screen.dart';
import '../../../features/home/terms_conditions_screen.dart';
import '../../../features/home/commission_screen.dart';
import '../../../features/home/create_ad_screen.dart';
import '../../../features/home/unauthenticated_profile_screen.dart';
import '../../../features/search/work_permit_list_screen.dart';
import '../../../common/services/api_client.dart';
import 'app_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.tabIndex, this.dashboardPath});

  final int tabIndex;
  final String? dashboardPath;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const WorkPermitListScreen(),
      const CreateAdScreen(),
      const ChatListScreen(),
      _DashboardHostScreen(route: dashboardPath ?? '/dashboard/agency'),
    ];

    return Scaffold(
      body: IndexedStack(index: tabIndex, children: screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: tabIndex,
        onTap: (index) => context.go(_tabPath(index)),
      ),
    );
  }

  String _tabPath(int index) {
    switch (index) {
      case 1:
        return '/search';
      case 2:
        return '/dashboard/ads/create';
      case 3:
        return '/chat';
      case 4:
        return '/profile';
      default:
        return '/home';
    }
  }
}

class _DashboardHostScreen extends StatefulWidget {
  const _DashboardHostScreen({required this.route});
  final String route;

  @override
  State<_DashboardHostScreen> createState() => _DashboardHostScreenState();
}

class _DashboardHostScreenState extends State<_DashboardHostScreen> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    if (mounted) {
      setState(() {
        _isLoggedIn = cookies != null && cookies.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn! && (widget.route == '/profile' || widget.route.startsWith('/dashboard'))) {
      return const UnauthenticatedProfileScreen();
    }

    switch (widget.route) {
      case '/dashboard/agency':
        return const DashboardScreen(currentHref: '/dashboard/agency');
      case '/dashboard/agent':
        return const DashboardScreen(currentHref: '/dashboard/agent');
      case '/dashboard/customer':
        return const DashboardScreen(currentHref: '/dashboard/customer');
      case '/dashboard/booking/my':
        return const MyBookingScreen();
      case '/dashboard/booking/my/success-file':
        return const SuccessFlightScreen();
      case '/dashboard/booking/my/return-passport':
        return const ReturnPassportScreen();
      case '/dashboard/booking/appointment':
        return const AppointmentBookingScreen();
      case '/dashboard/customer/profile':
        return const CustomerProfileScreen();
      case '/dashboard/customer/change-password':
        return const ChangePasswordScreen();
      case '/dashboard/customer/check-status':
        return const CheckStatusScreen();
      case '/dashboard/my-payments':
        return const PaymentsScreen();
      case '/dashboard/commission':
        return const CommissionScreen();
      case '/dashboard/notifications':
        return const NotificationsScreen();
      case '/dashboard/chat':
        return const ChatListScreen();
      case '/dashboard/terms-and-conditions':
        return const TermsConditionsScreen();
      case '/logout':
        return _buildLogoutScreen(context);
      default:
        return DashboardDummyScreen(
          title: widget.route.split('/').last.replaceAll('-', ' '),
        );
    }
  }

  Widget _buildLogoutScreen(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = AuthService();
      await authService.getSingOut();
      if (context.mounted) {
        context.go('/login');
      }
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DummyScreen extends StatelessWidget {
  const _DummyScreen({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title Screen (Coming Soon)')),
  );
}
