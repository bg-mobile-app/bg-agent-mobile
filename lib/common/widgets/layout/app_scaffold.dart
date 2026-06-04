import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../common/services/auth_service.dart';
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
import '../../../features/chat/chat_list_screen.dart';
import '../../../features/home/change_password_screen.dart';
import '../../../features/home/check_status_screen.dart';
import '../../../features/home/commission_screen.dart';
import '../../../features/home/create_ad_form_screen.dart';
import '../../../features/home/create_ad_screen.dart';
import '../../../features/home/create_user_screen.dart';
import '../../../features/home/customer_profile_screen.dart';
import '../../../features/home/dashboard_screen.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/home/manage_user_screen.dart';
import '../../../features/home/my_ads_screen.dart';
import '../../../features/home/notifications_screen.dart';
import '../../../features/home/payments_screen.dart';
import '../../../features/home/receive_payment_screen.dart';
import '../../../features/home/terms_conditions_screen.dart';
import '../../../features/home/unauthenticated_profile_screen.dart';
import '../../../features/home/user_activity_screen.dart';
import '../../../features/reminder/medical_expiry_screen.dart';
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
      const _DashboardHostScreen(route: '/dashboard/ads/create'),
      const ChatListScreen(),
      tabIndex == 4
          ? _DashboardHostScreen(route: dashboardPath ?? '/profile')
          : const SizedBox.shrink(),
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

    if (!_isLoggedIn! &&
        (widget.route == '/profile' || widget.route.startsWith('/dashboard'))) {
      return const UnauthenticatedProfileScreen();
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
          initialStatus: 'APPROVED',
          currentHref: '/dashboard/receive-payment/approve-payment',
          title: 'Approve Payment',
        );
      case '/dashboard/receive-payment/receive-payment':
        return const ReceivePaymentScreen(
          initialStatus: 'PAID',
          currentHref: '/dashboard/receive-payment/receive-payment',
          title: 'Receive Payment',
        );
      case '/dashboard/refund-payment/request-list':
        return const DashboardDummyScreen(
          currentHref: '/dashboard/refund-payment/request-list',
          title: 'Request List',
        );
      case '/dashboard/refund-payment/manage-bill':
        return const DashboardDummyScreen(
          currentHref: '/dashboard/refund-payment/manage-bill',
          title: 'Manage Bill',
        );
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
      await authService.getSingOut();
      if (context.mounted) {
        context.go('/login');
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
