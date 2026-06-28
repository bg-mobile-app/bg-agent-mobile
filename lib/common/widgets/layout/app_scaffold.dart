import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../common/services/auth_service.dart';
import '../../../common/services/agency_access.dart';
import '../../../features/booking/appointment_booking_screen.dart';
import '../../../features/booking/my_booking_screen.dart';
import '../../../features/booking/return_passport_screen.dart';
import '../../../features/booking/success_flight_screen.dart';
import '../../../features/booking/booking_documents_screen.dart';
import '../../../features/chat/chat_list_screen.dart';
import '../../../features/home/change_password_screen.dart';
import '../../../features/home/check_status_screen.dart';
import '../../../features/home/favourite_screen.dart';
import '../../../features/home/customer_profile_screen.dart';
import '../../../features/home/customer_profile_edit_screen.dart';
import '../../../features/home/dashboard_screen.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/home/notifications_screen.dart';
import '../../../features/home/payments_screen.dart';
import '../../../features/home/terms_conditions_screen.dart';
import '../../../features/search/work_permit_list_screen.dart';
import '../../../common/services/api_client.dart';
import '../../../routes/app_router.dart';
import 'app_bottom_nav.dart';
import '../../../common/theme/app_palette.dart';

import '../../../routes/navigation_history.dart';

import 'sign_in_required_placeholder.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.tabIndex, this.dashboardPath, this.queryParams});

  final int tabIndex;
  final String? dashboardPath;
  final Map<String, String>? queryParams;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    final loggedIn = cookies != null && cookies.isNotEmpty;
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = widget.dashboardPath ?? _tabPath(widget.tabIndex);
    AppNavigationHistory.recordVisit(currentPath);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppPalette.brandBlue),
          ),
        ),
      );
    }

    final screens = [
      const HomeScreen(),
      WorkPermitListScreen(queryParams: widget.queryParams),
      _isLoggedIn
          ? const AppointmentBookingScreen()
          : SignInRequiredPlaceholder(
              title: 'View Your Bookings',
              description: 'Sign in to keep track of your appointments, flight statuses, and passport handovers.',
              icon: Icons.calendar_month_rounded,
              onExploreHome: () => context.go('/home'),
            ),
      _isLoggedIn
          ? const ChatListScreen()
          : SignInRequiredPlaceholder(
              title: 'Chat with Agents',
              description: 'Sign in to message agents, discuss visa requirements, and receive real-time support.',
              icon: Icons.chat_bubble_outline_rounded,
              onExploreHome: () => context.go('/home'),
            ),
      widget.tabIndex == 4
          ? (_isLoggedIn
              ? _DashboardHostScreen(route: widget.dashboardPath ?? '/profile')
              : SignInRequiredPlaceholder(
                  title: 'Manage Your Profile',
                  description: 'Sign in to view your profile details, manage documents, and configure app settings.',
                  icon: Icons.person_outline_rounded,
                  onExploreHome: () => context.go('/home'),
                ))
          : const SizedBox.shrink(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (AppNavigationHistory.canPop) {
          final previous = AppNavigationHistory.pop();
          if (previous != null && context.mounted) {
            context.go(previous);
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: widget.tabIndex, children: screens),
        bottomNavigationBar: AppBottomNav(
          currentIndex: widget.tabIndex,
          onTap: (index) => context.go(_tabPath(index)),
        ),
      ),
    );
  }

  String _tabPath(int index) {
    switch (index) {
      case 1:
        return '/search';
      case 2:
        return '/booking';
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
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _checkLoginAndPermissions();
  }

  Future<void> _checkLoginAndPermissions() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    final isLoggedIn = cookies != null && cookies.isNotEmpty;
    if (isLoggedIn) {
      try {
        await AuthService().getCurrentUser();
        _userData = AuthService.currentUserData;
      } catch (e) {
        debugPrint('Error fetching current user in scaffold: $e');
      }
    }
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null || _isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn! &&
        (widget.route == '/profile' || widget.route.startsWith('/dashboard'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn! && !AgencyAccess.isRouteAllowed(widget.route, _userData)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/profile');
          showDialog(
            context: rootNavigatorKey.currentContext ?? context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gpp_maybe_outlined, color: Colors.amber, size: 50),
                  SizedBox(height: 16),
                  Text(
                    'Access Restricted',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'You are not permitted to access this screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Understand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (widget.route) {
      case '/profile':
        return const CustomerProfileScreen();
      case '/dashboard/agent':
        return const DashboardScreen(currentHref: '/dashboard/agent');
      case '/dashboard/booking/my':
        return const MyBookingScreen();
      case '/dashboard/booking/my/success-file':
        return const SuccessFlightScreen();
      case '/dashboard/booking/my/return-passport':
        return const ReturnPassportScreen();
      case '/dashboard/booking/appointment':
        return const AppointmentBookingScreen();
      case '/dashboard/agent/check-status':
        return const CheckStatusScreen();
      case '/dashboard/my-payments':
        return const PaymentsScreen();
      case '/dashboard/notifications':
        return const NotificationsScreen();
      case '/dashboard/chat':
        return const ChatListScreen();
      case '/dashboard/agent/change-password':
        return const ChangePasswordScreen();
      case '/dashboard/agent/terms-conditions':
        return const TermsConditionsScreen();
      case '/dashboard/customer/profile':
        return const CustomerProfileScreen();
      case '/dashboard/customer/profile/edit':
        return const CustomerProfileEditScreen();
      case '/dashboard/customer/favourite':
        return const FavouriteScreen();
      case '/logout':
        return _buildLogoutScreen(context);
      default:
        final segments = Uri.parse(widget.route).pathSegments;
        if (segments.length == 4 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'booking' &&
            segments[2] == 'documents') {
          final bookingId = int.tryParse(segments[3]) ?? 0;
          return BookingDocumentsScreen(bookingId: bookingId);
        }
        return DashboardDummyScreen(
          currentHref: widget.route,
          title: widget.route.split('/').last.replaceAll('-', ' '),
        );
    }
  }

  Widget _buildLogoutScreen(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = AuthService();
      await ApiClient().tokenStorage.clearCookies();
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: AppPalette.pageBackground,
          systemNavigationBarDividerColor: AppPalette.pageBackground,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      if (context.mounted) {
        context.go('/login');
      }
      authService.getSingOut().catchError((_) {});
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
