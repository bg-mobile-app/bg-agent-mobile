import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/booking/appointment_booking_screen.dart';
import '../../../features/booking/my_booking_screen.dart';
import '../../../features/booking/received_all_booking_screen.dart';
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
import '../../../features/home/terms_conditions_screen.dart';
import '../../../features/home/commission_screen.dart';
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

class _DashboardHostScreen extends StatelessWidget {
  const _DashboardHostScreen({required this.route});
  final String route;

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case '/dashboard/agency':
        return const DashboardScreen(currentHref: '/dashboard/agency');
      case '/dashboard/customer':
        return const DashboardScreen(currentHref: '/dashboard/customer');
      case '/dashboard/booking/my':
        return const MyBookingScreen();
      case '/dashboard/receive-booking/all-booking':
        return const ReceivedAllBookingScreen(currentHref: '/dashboard/receive-booking/all-booking');
      case '/dashboard/receive-booking/applied-booking':
        return const ReceivedAllBookingScreen(initialStatus: 'APPLIED_FILE', pageTitle: 'Applied Booking', currentHref: '/dashboard/receive-booking/applied-booking');
      case '/dashboard/receive-booking/bg-collect-passport':
        return const ReceivedAllBookingScreen(initialStatus: 'BG_COLLECT_PP', pageTitle: 'BG Collect Passport', currentHref: '/dashboard/receive-booking/bg-collect-passport');
      case '/dashboard/receive-booking/bg-sent-passport':
        return const ReceivedAllBookingScreen(initialStatus: 'BG_SENT_PP', pageTitle: 'BG Sent Passport', currentHref: '/dashboard/receive-booking/bg-sent-passport');
      case '/dashboard/receive-booking/receive-passport':
        return const ReceivedAllBookingScreen(initialStatus: 'A_RECEIVE_PP', pageTitle: 'Receive Passport', currentHref: '/dashboard/receive-booking/receive-passport');
      case '/dashboard/receive-booking/under-processing':
        return const ReceivedAllBookingScreen(initialStatus: 'UNDER_PROCESSING', pageTitle: 'Under Processing', currentHref: '/dashboard/receive-booking/under-processing');
      case '/dashboard/receive-booking/visa-approved':
        return const ReceivedAllBookingScreen(initialStatus: 'VISA_APPROVED', pageTitle: 'Visa Approved', currentHref: '/dashboard/receive-booking/visa-approved');
      case '/dashboard/receive-booking/bmet-done':
        return const ReceivedAllBookingScreen(initialStatus: 'BMET_DONE', pageTitle: 'BMET Done', currentHref: '/dashboard/receive-booking/bmet-done');
      case '/dashboard/receive-booking/ticket-done':
        return const ReceivedAllBookingScreen(initialStatus: 'TICKET_DONE', pageTitle: 'Ticket Done', currentHref: '/dashboard/receive-booking/ticket-done');
      case '/dashboard/receive-booking/pp-sent-to-bg':
        return const ReceivedAllBookingScreen(initialStatus: 'PP_SENT_TO_BG', pageTitle: 'PP Sent to BG', currentHref: '/dashboard/receive-booking/pp-sent-to-bg');
      case '/dashboard/receive-booking/bg-receive-passport':
        return const ReceivedAllBookingScreen(initialStatus: 'BG_RECEIVED_PP', pageTitle: 'BG Receive Passport', currentHref: '/dashboard/receive-booking/bg-receive-passport');
      case '/dashboard/receive-booking/ready-for-flight':
        return const ReceivedAllBookingScreen(initialStatus: 'READY_FOR_FLIGHT', pageTitle: 'Ready For Flight', currentHref: '/dashboard/receive-booking/ready-for-flight');
      case '/dashboard/receive-booking/success-flight':
        return const ReceivedAllBookingScreen(initialStatus: 'SUCCESS_FLIGHT', pageTitle: 'Success Flight', currentHref: '/dashboard/receive-booking/success-flight');
      case '/dashboard/receive-booking/reject-flight':
        return const ReceivedAllBookingScreen(initialStatus: 'REJECT_FILE', pageTitle: 'Reject File', currentHref: '/dashboard/receive-booking/reject-flight');
      case '/dashboard/passport-return/request-review':
        return const ReceivedAllBookingScreen(
          initialStatus: 'RETURN_REQUEST',
          pageTitle: 'Return Request/Review',
          currentHref: '/dashboard/passport-return/request-review',
        );
      case '/dashboard/passport-return/accept':
        return const ReceivedAllBookingScreen(
          initialStatus: 'RETURN_ACCEPTED',
          pageTitle: 'Return Accept',
          currentHref: '/dashboard/passport-return/accept',
        );
      case '/dashboard/passport-return/pp-sent-to-bg':
        return const ReceivedAllBookingScreen(
          initialStatus: 'RETURN_PP_SENT_TO_BG',
          pageTitle: 'Return PP Sent to BG',
          currentHref: '/dashboard/passport-return/pp-sent-to-bg',
        );
      case '/dashboard/passport-return/bg-collect-return-pp':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BG_COLLECT_RETURN_PP',
          pageTitle: 'BG Collect Return PP',
          currentHref: '/dashboard/passport-return/bg-collect-return-pp',
        );
      case '/dashboard/passport-return/bg-handover-pp-to-customer':
        return const ReceivedAllBookingScreen(
          initialStatus: 'BG_HANDOVER_PP_TO_CUSTOMER',
          pageTitle: 'BG Handover PP to Customer',
          currentHref: '/dashboard/passport-return/bg-handover-pp-to-customer',
        );
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
      case '/dashboard/commission':
        return const CommissionScreen();
      case '/dashboard/notifications':
        return const NotificationsScreen();
      case '/dashboard/ads/my':
        return const MyAdsScreen();
      case '/dashboard/terms-and-conditions':
        return const TermsConditionsScreen();
      default:
        if (route.startsWith('/dashboard/user/create-user/')) {
          final userId = route.substring('/dashboard/user/create-user/'.length);
          return CreateUserScreen(userId: userId);
        }

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
