import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/booking/appointment_booking_screen.dart';
import '../../../features/booking/my_booking_screen.dart';
import '../../../features/booking/received_all_booking_screen.dart';
import '../../../features/booking/received_applied_booking_screen.dart';
import '../../../features/booking/received_bg_collect_passport_screen.dart';
import '../../../features/booking/received_bg_sent_passport_screen.dart';
import '../../../features/booking/received_bmet_done_screen.dart';
import '../../../features/booking/passport_return_request_screen.dart';
import '../../../features/booking/passport_return_accept_screen.dart';
import '../../../features/booking/passport_return_pp_sent_to_bg_screen.dart';
import '../../../features/booking/passport_return_bg_handover_screen.dart';
import '../../../features/booking/received_passport_screen.dart';
import '../../../features/booking/received_pp_sent_to_bg_screen.dart';
import '../../../features/booking/received_ready_for_flight_screen.dart';
import '../../../features/booking/received_reject_flight_screen.dart';
import '../../../features/booking/received_success_flight_screen.dart';
import '../../../features/booking/received_ticket_done_screen.dart';
import '../../../features/booking/received_under_processing_screen.dart';
import '../../../features/booking/received_visa_approved_screen.dart';
import '../../../features/booking/return_passport_screen.dart';
import '../../../features/booking/success_flight_screen.dart';
import '../../../features/chat/chat_list_screen.dart';
import '../../../features/home/change_password_screen.dart';
import '../../../features/home/check_status_screen.dart';
import '../../../features/home/customer_profile_screen.dart';
import '../../../features/home/create_ad_form_screen.dart';
import '../../../features/home/create_ad_screen.dart';
import '../../../features/home/create_user_screen.dart';
import '../../../features/home/dashboard_screen.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/home/my_ads_screen.dart';
import '../../../features/home/manage_user_screen.dart';
import '../../../features/home/notifications_screen.dart';
import '../../../features/home/payments_screen.dart';
import '../../../features/search/work_permit_list_screen.dart';
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
      _DashboardHostScreen(route: dashboardPath ?? '/dashboard/customer'),
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

class _DashboardHostScreen extends StatelessWidget {
  const _DashboardHostScreen({required this.route});
  final String route;

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case '/dashboard/customer':
        return const DashboardScreen();
      case '/dashboard/booking/my':
        return const MyBookingScreen();
      case '/dashboard/receive-booking/all-booking':
        return const ReceivedAllBookingScreen();
      case '/dashboard/receive-booking/applied-booking':
        return const ReceivedAppliedBookingScreen();
      case '/dashboard/receive-booking/bg-collect-passport':
        return const ReceivedBgCollectPassportScreen();
      case '/dashboard/receive-booking/bg-sent-passport':
        return const ReceivedBgSentPassportScreen();
      case '/dashboard/receive-booking/receive-passport':
        return const ReceivedPassportScreen();
      case '/dashboard/receive-booking/under-processing':
        return const ReceivedUnderProcessingScreen();
      case '/dashboard/receive-booking/visa-approved':
        return const ReceivedVisaApprovedScreen();
      case '/dashboard/receive-booking/bmet-done':
        return const ReceivedBmetDoneScreen();
      case '/dashboard/receive-booking/ticket-done':
        return const ReceivedTicketDoneScreen();
      case '/dashboard/receive-booking/pp-sent-to-bg':
        return const ReceivedPpSentToBgScreen();
      case '/dashboard/receive-booking/ready-for-flight':
        return const ReceivedReadyForFlightScreen();
      case '/dashboard/receive-booking/success-flight':
        return const ReceivedSuccessFlightScreen();
      case '/dashboard/receive-booking/reject-flight':
        return const ReceivedRejectFlightScreen();
      case '/dashboard/passport-return/request-review':
        return const PassportReturnRequestScreen();
      case '/dashboard/passport-return/accept':
        return const PassportReturnAcceptScreen();
      case '/dashboard/passport-return/pp-sent-to-bg':
        return const PassportReturnPpSentToBgScreen();
      case '/dashboard/passport-return/bg-handover-pp-to-customer':
        return const PassportReturnBgHandoverScreen();
      case '/dashboard/customer/profile':
        return const CustomerProfileScreen();
      case '/dashboard/ads/create':
        return const CreateAdScreen();
      case '/dashboard/ads/create/form/bn':
        return const CreateAdFormScreen(isBangla: true);
      case '/dashboard/ads/create/form/en':
        return const CreateAdFormScreen(isBangla: false);
      case '/dashboard/booking/my/success-file':
        return const SuccessFlightScreen();
      case '/dashboard/booking/my/return-passport':
        return const ReturnPassportScreen();
      case '/dashboard/booking/appointment':
        return const AppointmentBookingScreen();
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
      case '/dashboard/notifications':
        return const NotificationsScreen();
      case '/dashboard/ads/my':
        return const MyAdsScreen();
      default:
        return DashboardDummyScreen(
          title: route.split('/').last.replaceAll('-', ' '),
        );
    }
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
