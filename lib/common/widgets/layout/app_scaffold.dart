import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../common/services/auth_service.dart';
import '../../../common/services/agency_access.dart';
import '../../../features/booking/appointment_booking_screen.dart';
import '../../../features/booking/received_all_booking_screen.dart';
import '../../../features/booking/my_booking_screen.dart';
import '../../../features/booking/passport_return_accept_screen.dart';
import '../../../features/booking/passport_return_bg_collect_return_pp_screen.dart';
import '../../../features/booking/passport_return_bg_handover_screen.dart';
import '../../../features/booking/passport_return_pp_sent_to_bg_screen.dart';
import '../../../features/booking/passport_return_request_screen.dart';
import '../../../features/booking/return_passport_screen.dart';
import '../../../features/booking/success_flight_screen.dart';
import '../../../features/booking/booking_documents_screen.dart';
import '../../../features/booking/pp_sent_bg_add_screen.dart';
import '../../../features/chat/chat_list_screen.dart';
import '../../../features/home/change_password_screen.dart';
import '../../../features/home/check_status_screen.dart';
import '../../../features/home/commission_screen.dart';
import '../../../features/home/create_ad_form_screen.dart';
import '../../../features/home/create_ad_screen.dart';
import '../../../features/home/create_user_screen.dart';
import '../../../features/home/customer_profile_screen.dart';
import '../../../features/home/customer_profile_edit_screen.dart';
import '../../../features/home/dashboard_screen.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/home/manage_user_screen.dart';
import '../../../features/home/my_ads_screen.dart';
import '../../../features/home/notifications_screen.dart';
import '../../../features/home/payments_screen.dart';
import '../../../features/home/receive_payment_screen.dart';
import '../../../features/home/receive_payment_history_screen.dart';
import '../../../features/home/receive_payment_detail_screen.dart';
import '../../../features/home/refund_request_list_screen.dart';
import '../../../features/home/terms_conditions_screen.dart';
import '../../../features/home/manage_bill_screen.dart';
import '../../../features/home/user_activity_screen.dart';
import '../../../features/reminder/medical_expiry_screen.dart';
import '../../../features/search/work_permit_list_screen.dart';
import '../../../common/services/api_client.dart';
import '../../../routes/app_router.dart';
import 'app_bottom_nav.dart';
import '../../../common/theme/app_palette.dart';

import '../../../routes/navigation_history.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.tabIndex, this.dashboardPath, this.queryParams});

  final int tabIndex;
  final String? dashboardPath;
  final Map<String, String>? queryParams;

  @override
  Widget build(BuildContext context) {
    final currentPath = dashboardPath ?? _tabPath(tabIndex);
    AppNavigationHistory.recordVisit(currentPath);

    final screens = [
      const HomeScreen(),
      WorkPermitListScreen(queryParams: queryParams),
      _DashboardHostScreen(
        route: tabIndex == 2
            ? (dashboardPath ?? '/dashboard/ads/create')
            : '/dashboard/ads/create',
      ),
      const ChatListScreen(),
      tabIndex == 4
          ? _DashboardHostScreen(route: dashboardPath ?? '/profile')
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
        body: IndexedStack(index: tabIndex, children: screens),
        bottomNavigationBar: AppBottomNav(
          currentIndex: tabIndex,
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
      if (widget.route.startsWith('/dashboard/ads/create') || widget.route.startsWith('/dashboard/ads/edit/')) {
        return const _PremiumPermissionDeniedScreen(
          message: 'You are not permitted to create ad.\nFor permission, talk to your admin.',
        );
      }
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
                  Icon(
                    Icons.gpp_maybe_outlined,
                    color: Colors.amber,
                    size: 50,
                  ),
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
                'You are not permitted to access this screen. For permission, please talk to your admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Understand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
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
      case '/dashboard/ads/create':
        return const CreateAdScreen();
      case '/dashboard/ads/my':
        return const MyAdsScreen();
      case '/dashboard/ads/create/form/bn':
        return const CreateAdFormScreen(isBangla: true);
      case '/dashboard/ads/create/form/en':
        return const CreateAdFormScreen(isBangla: false);
      case '/dashboard/reminder/medical-expiry':
        return const MedicalExpiryScreen();
      case '/dashboard/reminder/police-clearance-expiry':
        return const PoliceClearanceExpiryScreen();
      case '/dashboard/reminder/visa-expiry':
        return const VisaExpiryScreen();
      case '/dashboard/receive-booking/all-booking':
        return const ReceivedAllBookingScreen();
      case '/dashboard/receive-booking/applied-booking':
        return const ReceivedAllBookingScreen(
          initialStatus: 'APPLIED_FILE',
          pageTitle: 'Applied Booking',
          currentHref: '/dashboard/receive-booking/applied-booking',
        );
      case '/dashboard/receive-booking/bg-collect-passport':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BG_COLLECT_PP',
          pageTitle: 'BG Collect Passport',
          currentHref: '/dashboard/receive-booking/bg-collect-passport',
        );
      case '/dashboard/receive-booking/bg-sent-passport':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BG_SENT_PP',
          pageTitle: 'BG Sent Passport',
          currentHref: '/dashboard/receive-booking/bg-sent-passport',
        );
      case '/dashboard/receive-booking/receive-passport':
        return const ReceivedAllBookingScreen(
          initialStatus: 'A_RECEIVE_PP',
          pageTitle: 'Receive Passport',
          currentHref: '/dashboard/receive-booking/receive-passport',
        );
      case '/dashboard/receive-booking/under-processing':
        return const ReceivedAllBookingScreen(
          initialStatus: 'UNDER_PROCESSING',
          pageTitle: 'Under Processing',
          currentHref: '/dashboard/receive-booking/under-processing',
        );
      case '/dashboard/receive-booking/visa-approved':
        return const ReceivedAllBookingScreen(
          initialStatus: 'VISA_APPROVED',
          pageTitle: 'Visa Approved',
          currentHref: '/dashboard/receive-booking/visa-approved',
        );
      case '/dashboard/receive-booking/bmet-done':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BMET_DONE',
          pageTitle: 'BMET Done',
          currentHref: '/dashboard/receive-booking/bmet-done',
        );
      case '/dashboard/receive-booking/ticket-done':
        return const ReceivedAllBookingScreen(
          initialStatus: 'TICKET_DONE',
          pageTitle: 'Ticket Done',
          currentHref: '/dashboard/receive-booking/ticket-done',
        );
      case '/dashboard/receive-booking/pp-sent-to-bg':
        return const ReceivedAllBookingScreen(
          initialStatus: 'PP_SENT_TO_BG',
          pageTitle: 'PP Sent to BG',
          currentHref: '/dashboard/receive-booking/pp-sent-to-bg',
        );
      case '/dashboard/receive-booking/bg-receive-passport':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BG_RECEIVED_PP',
          pageTitle: 'BG Receive Passport',
          currentHref: '/dashboard/receive-booking/bg-receive-passport',
        );
      case '/dashboard/receive-booking/ready-for-flight':
        return const ReceivedAllBookingScreen(
          initialStatus: 'READY_FOR_FLIGHT',
          pageTitle: 'Ready For Flight',
          currentHref: '/dashboard/receive-booking/ready-for-flight',
        );
      case '/dashboard/receive-booking/success-flight':
        return const ReceivedAllBookingScreen(
          initialStatus: 'SUCCESS_FLIGHT',
          pageTitle: 'Success Flight',
          currentHref: '/dashboard/receive-booking/success-flight',
        );
      case '/dashboard/receive-booking/reject-flight':
        return const ReceivedAllBookingScreen(
          initialStatus: 'REJECT_FILE',
          pageTitle: 'Reject File',
          currentHref: '/dashboard/receive-booking/reject-flight',
        );
      case '/dashboard/passport-return/request-review':
        return const PassportReturnRequestScreen();
      case '/dashboard/passport-return/accept':
        return const PassportReturnAcceptScreen();
      case '/dashboard/passport-return/pp-sent-to-bg':
        return const PassportReturnPpSentToBgScreen();
      case '/dashboard/passport-return/bg-collect-return-pp':
        return const PassportReturnBgCollectReturnPpScreen();
      case '/dashboard/passport-return/bg-handover-pp-to-customer':
        return const PassportReturnBgHandoverScreen();
      case '/dashboard/customer/profile':
        return const CustomerProfileScreen();
      case '/dashboard/customer/profile/edit':
        return const CustomerProfileEditScreen();
      case '/dashboard/user/create-user':
        return const CreateUserScreen();
      case '/dashboard/user/manage-user':
        return const ManageUserScreen();
      case '/dashboard/customer/change-password':
        return const ChangePasswordScreen();
      case '/dashboard/customer/check-status':
        return const CheckStatusScreen();
      case '/dashboard/my-payments':
        return const PaymentsScreen();
      case '/dashboard/receive-payment/all-request-payment':
        return const ReceivePaymentScreen(
          currentHref: '/dashboard/receive-payment/all-request-payment',
          title: 'All Request Payment',
        );
      case '/dashboard/receive-payment/approve-payment':
        return const ReceivePaymentScreen(
          initialStatus: 'APPROVE',
          currentHref: '/dashboard/receive-payment/approve-payment',
          title: 'Approve Payment',
        );
      case '/dashboard/receive-payment/receive-payment':
        return const ReceivePaymentHistoryScreen(
          currentHref: '/dashboard/receive-payment/receive-payment',
        );
      case '/dashboard/refund-payment/request-list':
        return const RefundRequestListScreen();
      case '/dashboard/refund-payment/manage-bill':
        return const ManageBillScreen(currentHref: '/dashboard/refund-payment/manage-bill');
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
        final segments = Uri.parse(widget.route).pathSegments;
        if (segments.length == 4 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'booking' &&
            segments[2] == 'documents') {
          final bookingIdStr = segments[3];
          final bookingId = int.tryParse(bookingIdStr) ?? 0;
          return BookingDocumentsScreen(bookingId: bookingId);
        }
        if (segments.length == 6 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'agency' &&
            segments[2] == 'booking-file' &&
            segments[3] == 'pp-sent-bg' &&
            segments[4] == 'add') {
          final bookingIdStr = segments[5];
          final bookingId = int.tryParse(bookingIdStr) ?? 0;
          return PPSentBGAddScreen(initialBookingId: bookingId);
        }
        if (segments.length == 4 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'receive-payment' &&
            segments[2] == 'view') {
          return ReceivePaymentDetailScreen(
            billId: segments[3],
            currentHref: widget.route,
          );
        }
        if (segments.length == 4 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'ads' &&
            segments[2] == 'edit') {
          final adSlug = segments[3];
          if (adSlug.isNotEmpty) {
            return CreateAdFormScreen(isBangla: false, adSlug: adSlug);
          }
        }
        if (segments.length == 5 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'ads' &&
            segments[2] == 'edit') {
          final adSlug = segments[4];
          if (adSlug.isNotEmpty) {
            return CreateAdFormScreen(
              isBangla: segments[3].toLowerCase() == 'bn',
              adSlug: adSlug,
            );
          }
        }
        if (segments.length == 4 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'user' &&
            segments[2] == 'create-user') {
          return CreateUserScreen(userId: segments[3]);
        }
        if (segments.length == 5 &&
            segments[0] == 'dashboard' &&
            segments[1] == 'user' &&
            segments[2] == 'manage-user' &&
            segments[3] == 'activity') {
          return UserActivityScreen(userId: segments[4]);
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
      // Instantly clear cookies
      await ApiClient().tokenStorage.clearCookies();
      // Reset system navigation color to default for unauthenticated state
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
      // Fire-and-forget backend logout request in background
      authService.getSingOut().catchError((_) {});
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _PremiumPermissionDeniedScreen extends StatelessWidget {
  const _PremiumPermissionDeniedScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Premium Gradient Icon Box
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    color: Color(0xFF2563EB),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 28),
                // Premium Headline
                const Text(
                  'Access Restricted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Message Body
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                // Premium Styled Action Button
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.go('/profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go to Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
