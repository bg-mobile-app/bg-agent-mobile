import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'models/dashboard_models.dart';
import 'services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.currentHref = '/dashboard/agency'});

  final String currentHref;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Last Year',
    'Last 2 Years',
    'Last 3 Years',
    'Last 4 Years',
    'Last 5 Years',
  ];

  final DashboardService _dashboardService = DashboardService();
  late Future<AgencyDashboardStats> _dashboardFuture;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getAgencyDashboard(_selectedPeriod);
  }

  void _changePeriod(String? period) {
    if (period == null || period == _selectedPeriod) return;
    setState(() {
      _selectedPeriod = period;
      _dashboardFuture = _dashboardService.getAgencyDashboard(_selectedPeriod);
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardFuture = _dashboardService.getAgencyDashboard(_selectedPeriod);
    });
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: widget.currentHref,
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: FutureBuilder<AgencyDashboardStats>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data ?? AgencyDashboardStats.empty();
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final hasError = snapshot.hasError;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _DashboardBreadcrumbs(),
                          const SizedBox(height: 14),
                          Text(
                            'Agency Dashboard Overview',
                            style: AppTextStyles.headline1.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Live booking, payment, commission, and expiry data for your agency.',
                            style: AppTextStyles.body2.copyWith(
                              color: AppPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _PeriodSelector(
                            selectedPeriod: _selectedPeriod,
                            periods: _periods,
                            onChanged: _changePeriod,
                            isLoading: isLoading,
                          ),
                          if (hasError) ...[
                            const SizedBox(height: 12),
                            _DashboardErrorBanner(onRetry: _refreshDashboard),
                          ],
                          const SizedBox(height: 16),
                          if (isLoading && snapshot.data == null)
                            const _DashboardLoadingState()
                          else ...[
                            _DashboardSection(
                              title: 'Agency Summary',
                              child: _DashboardCardGrid(
                                cards: _buildAgencySummaryCards(stats),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DashboardSection(
                              title: 'My Bookings',
                              child: _DashboardCardGrid(
                                cards: _buildMyBookingCards(stats.myBookings),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DashboardSection(
                              title: 'Agency Bookings',
                              child: _DashboardCardGrid(
                                cards: _buildAgencyBookingCards(stats.agencyBookings),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _DashboardSection(
                              title: 'Expiry Reminders',
                              child: _ExpiryReminderPanel(stats: stats.expiryReminders),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<DashboardSmallCard> _buildAgencySummaryCards(AgencyDashboardStats stats) {
    final agency = stats.agencyBookings;
    return [
      DashboardSmallCard(
        label: 'Total Agency Booking',
        icon: Icons.fact_check_outlined,
        value: '${agency.total}',
      ),
      DashboardSmallCard(
        label: 'Ready For Flight',
        icon: Icons.flight_takeoff_rounded,
        value: '${agency.readyForFlight}',
      ),
      DashboardSmallCard(
        label: 'Total Commission',
        icon: Icons.account_balance_wallet_outlined,
        value: _formatMoney(agency.commissionAmount),
      ),
      DashboardSmallCard(
        label: 'Total Due',
        icon: Icons.money_off_csred_outlined,
        value: _formatMoney(agency.dueAmount),
        red: true,
      ),
    ];
  }

  List<DashboardSmallCard> _buildMyBookingCards(MyBookingStats stats) {
    return [
      DashboardSmallCard(
        label: 'Total Applied Job',
        icon: Icons.menu_book_outlined,
        value: '${stats.total}',
      ),
      DashboardSmallCard(
        label: 'Under Processing',
        icon: Icons.hourglass_top_rounded,
        value: '${stats.processing}',
      ),
      DashboardSmallCard(
        label: 'Success Flight',
        icon: Icons.flight_takeoff_rounded,
        value: '${stats.successFlight}',
      ),
      DashboardSmallCard(
        label: 'Reject Flight',
        icon: Icons.flight_land_rounded,
        value: '${stats.rejectFlight}',
        red: true,
      ),
      DashboardSmallCard(
        label: 'Return Passport',
        icon: Icons.badge_outlined,
        value: '${stats.returnProcessing}',
      ),
      DashboardSmallCard(
        label: 'Total Amount',
        icon: Icons.payments_outlined,
        value: _formatMoney(stats.totalAmount),
      ),
      DashboardSmallCard(
        label: 'Paid Amount',
        icon: Icons.account_balance_wallet_outlined,
        value: _formatMoney(stats.paidAmount),
      ),
      DashboardSmallCard(
        label: 'Due Amount',
        icon: Icons.money_off_csred_outlined,
        value: _formatMoney(stats.dueAmount),
        red: true,
      ),
      DashboardSmallCard(
        label: 'Commission Amount',
        icon: Icons.savings_outlined,
        value: _formatMoney(stats.commissionAmount),
      ),
    ];
  }

  List<DashboardSmallCard> _buildAgencyBookingCards(AgencyBookingStats stats) {
    return [
      DashboardSmallCard(label: 'All Booking', icon: Icons.list_alt_outlined, value: '${stats.total}'),
      DashboardSmallCard(label: 'Applied Customer', icon: Icons.person_add_alt, value: '${stats.appliedCustomer}'),
      DashboardSmallCard(label: 'BG Collect PP', icon: Icons.assignment_ind_outlined, value: '${stats.bgCollectPp}'),
      DashboardSmallCard(label: 'BG Sent PP', icon: Icons.outbox_outlined, value: '${stats.bgSentPp}'),
      DashboardSmallCard(label: 'Agency Receive PP', icon: Icons.inventory_2_outlined, value: '${stats.aRecievePp}'),
      DashboardSmallCard(label: 'Under Processing', icon: Icons.hourglass_top_rounded, value: '${stats.underProcessing}'),
      DashboardSmallCard(label: 'Visa Approved', icon: Icons.verified_user_outlined, value: '${stats.visaApproved}'),
      DashboardSmallCard(label: 'BMET Done', icon: Icons.task_alt_rounded, value: '${stats.bmetDone}'),
      DashboardSmallCard(label: 'Ticket Done', icon: Icons.airplane_ticket_outlined, value: '${stats.ticketDone}'),
      DashboardSmallCard(label: 'PP Sent To BG', icon: Icons.mark_email_read_outlined, value: '${stats.ppSentToBg}'),
      DashboardSmallCard(label: 'BG Received PP', icon: Icons.move_to_inbox_outlined, value: '${stats.bgReceivedPp}'),
      DashboardSmallCard(label: 'Ready For Flight', icon: Icons.flight_takeoff_rounded, value: '${stats.readyForFlight}'),
      DashboardSmallCard(label: 'Success Flight', icon: Icons.flight_rounded, value: '${stats.successFlight}'),
      DashboardSmallCard(label: 'Return Request', icon: Icons.assignment_return_outlined, value: '${stats.returnRequest}'),
      DashboardSmallCard(label: 'Return Accepted', icon: Icons.assignment_turned_in_outlined, value: '${stats.returnAccepted}'),
      DashboardSmallCard(label: 'Return PP Sent To BG', icon: Icons.reply_all_outlined, value: '${stats.returnPpSentToBg}'),
      DashboardSmallCard(label: 'BG Collect Return PP', icon: Icons.badge_outlined, value: '${stats.bgCollectReturnPp}'),
      DashboardSmallCard(label: 'BG Handover PP', icon: Icons.handshake_outlined, value: '${stats.bgHandoverPpToCustomer}'),
      DashboardSmallCard(label: 'Reject Flight', icon: Icons.flight_land_rounded, value: '${stats.rejectFlight}', red: true),
      DashboardSmallCard(label: 'Total Amount', icon: Icons.payments_outlined, value: _formatMoney(stats.totalAmount)),
      DashboardSmallCard(label: 'Paid Amount', icon: Icons.account_balance_wallet_outlined, value: _formatMoney(stats.paidAmount)),
      DashboardSmallCard(label: 'Due Amount', icon: Icons.money_off_csred_outlined, value: _formatMoney(stats.dueAmount), red: true),
      DashboardSmallCard(label: 'Commission Amount', icon: Icons.savings_outlined, value: _formatMoney(stats.commissionAmount)),
    ];
  }

  String _formatMoney(int value) => '৳${_formatNumber(value)}';

  String _formatNumber(int value) {
    final raw = value.toString();
    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }
}


class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.periods,
    required this.onChanged,
    required this.isLoading,
  });

  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderSoftBlue),
        boxShadow: AppPalette.softShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          isExpanded: true,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppPalette.textPrimary,
                ),
          items: periods
              .map(
                (period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(
                    period,
                    style: AppTextStyles.subtitle1.copyWith(fontSize: 17),
                  ),
                ),
              )
              .toList(),
          onChanged: isLoading ? null : onChanged,
        ),
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppPalette.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unable to load agency dashboard data. Please check your connection and try again.',
              style: AppTextStyles.body2.copyWith(color: AppPalette.danger),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle1.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DashboardCardGrid extends StatelessWidget {
  const _DashboardCardGrid({required this.cards});

  final List<DashboardSmallCard> cards;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 960 ? 3 : (width >= 640 ? 2 : 1);
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: width < 640 ? 2.45 : 2.0,
      children: cards,
    );
  }
}

class _ExpiryReminderPanel extends StatelessWidget {
  const _ExpiryReminderPanel({required this.stats});

  final ExpiryReminderStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExpiryReminderCard(title: 'Expiring in 3 Days', group: stats.days3),
        const SizedBox(height: 12),
        _ExpiryReminderCard(title: 'Expiring in 10 Days', group: stats.days10),
      ],
    );
  }
}

class _ExpiryReminderCard extends StatelessWidget {
  const _ExpiryReminderCard({required this.title, required this.group});

  final String title;
  final ExpiryReminderGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.borderSoftBlue),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm_outlined, color: AppPalette.brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ReminderPill(label: 'Total', value: group.total),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ReminderPill(label: 'Medical', value: group.medical),
              _ReminderPill(label: 'Police', value: group.police),
              _ReminderPill(label: 'Visa', value: group.visa),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.borderSoftBlue),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppPalette.brandBlue,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DashboardBreadcrumbs extends StatelessWidget {
  const _DashboardBreadcrumbs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.home_outlined, size: 14, color: AppPalette.textMuted),
        SizedBox(width: 6),
        Text(
          'Home',
          style: TextStyle(
            fontSize: 12,
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 6),
        Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: AppPalette.textMuted,
        ),
        SizedBox(width: 6),
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 12,
            color: AppPalette.brandBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

const List<SidebarLink> kDashboardSidebarLinks = [
  SidebarLink(name: 'Home', icon: Icons.home_outlined, href: '/home'),
  SidebarLink(
    name: 'Dashboard',
    icon: Icons.dashboard,
    href: '/dashboard/agency',
  ),
  SidebarLink(
    name: 'My Profile',
    icon: Icons.person,
    href: '/dashboard/customer/profile',
  ),
  SidebarLink(
    name: 'Create Ads',
    icon: Icons.add_box_outlined,
    href: '/dashboard/ads/create',
  ),
  SidebarLink(
    name: 'My Ads',
    icon: Icons.campaign_outlined,
    href: '/dashboard/ads/my',
  ),
  SidebarLink(
    name: 'Receive Booking List',
    icon: Icons.fact_check_outlined,
    children: [
      SidebarLink(
        name: 'All Booking',
        href: '/dashboard/receive-booking/all-booking',
      ),
      SidebarLink(
        name: 'Applied Booking',
        href: '/dashboard/receive-booking/applied-booking',
      ),
      SidebarLink(
        name: 'BG Collect Passport',
        href: '/dashboard/receive-booking/bg-collect-passport',
      ),
      SidebarLink(
        name: 'BG Sent Passport',
        href: '/dashboard/receive-booking/bg-sent-passport',
      ),
      SidebarLink(
        name: 'Receive Passport',
        href: '/dashboard/receive-booking/receive-passport',
      ),
      SidebarLink(
        name: 'Under Processing',
        href: '/dashboard/receive-booking/under-processing',
      ),
      SidebarLink(
        name: 'Visa Approved',
        href: '/dashboard/receive-booking/visa-approved',
      ),
      SidebarLink(
        name: 'BMET Done',
        href: '/dashboard/receive-booking/bmet-done',
      ),
      SidebarLink(
        name: 'Ticket Done',
        href: '/dashboard/receive-booking/ticket-done',
      ),
      SidebarLink(
        name: 'PP Sent to BG',
        href: '/dashboard/receive-booking/pp-sent-to-bg',
      ),
      SidebarLink(
        name: 'BG Receive Passport',
        href: '/dashboard/receive-booking/bg-receive-passport',
      ),
      SidebarLink(
        name: 'Ready For Flight',
        href: '/dashboard/receive-booking/ready-for-flight',
      ),
      SidebarLink(
        name: 'Success Flight',
        href: '/dashboard/receive-booking/success-flight',
      ),
      SidebarLink(
        name: 'Reject Flight',
        href: '/dashboard/receive-booking/reject-flight',
      ),
    ],
  ),
  SidebarLink(
    name: 'Passport Return List',
    icon: Icons.assignment_return_outlined,
    children: [
      SidebarLink(
        name: 'Return Request/Review',
        href: '/dashboard/passport-return/request-review',
      ),
      SidebarLink(
        name: 'Return Accept',
        href: '/dashboard/passport-return/accept',
      ),
      SidebarLink(
        name: 'Return PP Sent to BG',
        href: '/dashboard/passport-return/pp-sent-to-bg',
      ),
      SidebarLink(
        name: 'BG Collect Return PP',
        href: '/dashboard/passport-return/bg-collect-return-pp',
      ),
      SidebarLink(
        name: 'BG Handover PP to Customer',
        href: '/dashboard/passport-return/bg-handover-pp-to-customer',
      ),
    ],
  ),
  SidebarLink(
    name: 'My Booking List',
    icon: Icons.grid_view,
    children: [
      SidebarLink(name: 'All Booking', href: '/dashboard/booking/my'),
      SidebarLink(
        name: 'Success Flight',
        href: '/dashboard/booking/my/success-file',
      ),
      SidebarLink(
        name: 'Return Passport',
        href: '/dashboard/booking/my/return-passport',
      ),
    ],
  ),
  SidebarLink(
    name: 'Appointment Booking',
    icon: Icons.calendar_month,
    href: '/dashboard/booking/appointment',
  ),
  SidebarLink(
    name: 'User',
    icon: Icons.group_outlined,
    children: [
      SidebarLink(name: 'Create User', href: '/dashboard/user/create-user'),
      SidebarLink(name: 'Manage User', href: '/dashboard/user/manage-user'),
    ],
  ),
  SidebarLink(
    name: 'Reminder List',
    icon: Icons.alarm_outlined,
    children: [
      SidebarLink(
        name: 'Medical Expiry',
        href: '/dashboard/reminder/medical-expiry',
      ),
      SidebarLink(
        name: 'Police Clearance Expiry',
        href: '/dashboard/reminder/police-clearance-expiry',
      ),
      SidebarLink(name: 'Visa Expiry', href: '/dashboard/reminder/visa-expiry'),
    ],
  ),
  SidebarLink(
    name: 'Check Status',
    icon: Icons.radio_button_checked,
    href: '/dashboard/customer/check-status',
  ),
  SidebarLink(
    name: 'My Payments',
    icon: Icons.payment,
    href: '/dashboard/my-payments',
  ),
  SidebarLink(
    name: 'Receive Payment',
    icon: Icons.payments_outlined,
    children: [
      SidebarLink(
        name: 'All Request Payment',
        href: '/dashboard/receive-payment/all-request-payment',
      ),
      SidebarLink(
        name: 'Approve Payment',
        href: '/dashboard/receive-payment/approve-payment',
      ),
      SidebarLink(
        name: 'Receive Payment',
        href: '/dashboard/receive-payment/receive-payment',
      ),
    ],
  ),
  SidebarLink(
    name: 'Refund Payment',
    icon: Icons.request_page_outlined,
    children: [
      SidebarLink(
        name: 'Request List',
        href: '/dashboard/refund-payment/request-list',
      ),
      SidebarLink(
        name: 'Manage Bill',
        href: '/dashboard/refund-payment/manage-bill',
      ),
    ],
  ),
  SidebarLink(
    name: 'Commission',
    icon: Icons.account_balance_wallet_outlined,
    href: '/dashboard/commission',
  ),
  SidebarLink(
    name: 'Notifications',
    icon: Icons.notifications_none,
    href: '/dashboard/notifications',
  ),
  SidebarLink(
    name: 'Change Password',
    icon: Icons.swap_horiz,
    href: '/dashboard/customer/change-password',
  ),
  SidebarLink(
    name: 'Terms & Conditions',
    icon: Icons.gavel_outlined,
    href: '/dashboard/terms-and-conditions',
  ),
];

class DashboardPageScaffold extends StatelessWidget {
  const DashboardPageScaffold({
    super.key,
    required this.child,
    required this.currentHref,
  });

  final Widget child;
  final String currentHref;

  String get _screenName {
    const titles = <String, String>{
      '/dashboard/agency': 'Agency Dashboard',
      '/dashboard/customer': 'Dashboard',
      '/dashboard/booking/my': 'All Booking',
      '/dashboard/receive-booking/all-booking': 'All Booking',
      '/dashboard/receive-booking/applied-booking': 'Applied Booking',
      '/dashboard/receive-booking/bg-collect-passport': 'BG Collect Passport',
      '/dashboard/receive-booking/bg-sent-passport': 'BG Sent Passport',
      '/dashboard/receive-booking/receive-passport': 'Receive Passport',
      '/dashboard/booking/my/success-file': 'Success Flight',
      '/dashboard/booking/my/return-passport': 'Return Passport',
      '/dashboard/booking/appointment': 'Appointment Booking',
      '/dashboard/notifications': 'Notifications',
      '/dashboard/check-status': 'Check Status',
      '/dashboard/payments': 'Payments',
      '/dashboard/my-ads': 'My Ads',
      '/dashboard/my-favourite': 'My Favourite',
      '/dashboard/create-ad': 'Create Ad',
      '/dashboard/create-user': 'Create User',
      '/dashboard/manage-user': 'Manage User',
      '/dashboard/change-password': 'Change Password',
      '/dashboard/customer-profile': 'Customer Profile',
    };
    final matchedTitle = titles[currentHref];
    if (matchedTitle != null) return matchedTitle;
    final parts = currentHref
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    final segment = parts.isEmpty ? 'screen' : parts.last;
    return segment
        .split('-')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: CustomerSidebarDrawer(
        currentHref: currentHref,
        fullName: 'Demo User',
        userId: 'BG-1024',
        email: 'demo.user@example.com',
        phone: '+1 555 0102',
        profileImage: 'assets/img/logo/logo_black.png',
        links: kDashboardSidebarLinks,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _screenName,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/img/logo/logo_black.png',
                  height: 34,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, color: Colors.black87),
              tooltip: 'Sidebar',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
    );
  }
}

class CustomerSidebarDrawer extends StatefulWidget {
  const CustomerSidebarDrawer({
    super.key,
    required this.currentHref,
    required this.fullName,
    required this.userId,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.links,
  });

  final String fullName;
  final String currentHref;
  final String userId;
  final String email;
  final String phone;
  final String profileImage;
  final List<SidebarLink> links;

  @override
  State<CustomerSidebarDrawer> createState() => _CustomerSidebarDrawerState();
}

class _CustomerSidebarDrawerState extends State<CustomerSidebarDrawer> {
  String? _openKey;

  void _handleNavigation(SidebarLink link) {
    Navigator.pop(context);
    final href = link.href;
    if (href == null || href == widget.currentHref) return;
    context.go(href);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SidebarUserInfo(
                fullName: widget.fullName,
                userId: widget.userId,
                email: widget.email,
                phone: widget.phone,
                profileImage: widget.profileImage,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.links.length,
                  itemBuilder: (context, index) {
                    final link = widget.links[index];
                    return _SidebarNavTile(
                      link: link,
                      isOpen: _openKey == link.name,
                      onExpandToggle: () {
                        setState(() {
                          _openKey = _openKey == link.name ? null : link.name;
                        });
                      },
                      onTap: _handleNavigation,
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Color(0xFF475569)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout clicked')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarUserInfo extends StatelessWidget {
  const _SidebarUserInfo({
    required this.fullName,
    required this.userId,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  final String fullName;
  final String userId;
  final String email;
  final String phone;
  final String profileImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 40, backgroundImage: AssetImage(profileImage)),
        const SizedBox(height: 8),
        Text(
          fullName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'User ID: $userId',
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          'User Email: $email',
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          'User Phone: $phone',
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.link,
    required this.isOpen,
    required this.onExpandToggle,
    required this.onTap,
  });

  final SidebarLink link;
  final bool isOpen;
  final VoidCallback onExpandToggle;
  final ValueChanged<SidebarLink> onTap;

  @override
  Widget build(BuildContext context) {
    if (link.children.isNotEmpty) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: isOpen,
        onExpansionChanged: (_) => onExpandToggle(),
        leading: Icon(link.icon ?? Icons.circle, size: 20),
        title: Text(
          link.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: link.children
            .map(
              (child) => ListTile(
                contentPadding: const EdgeInsets.only(left: 40, right: 0),
                title: Text(child.name),
                onTap: () => onTap(child),
              ),
            )
            .toList(),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(link.icon ?? Icons.circle, size: 20),
      title: Text(
        link.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: () => onTap(link),
    );
  }
}

class SidebarLink {
  const SidebarLink({
    required this.name,
    this.href,
    this.icon,
    this.children = const [],
  });

  final String name;
  final String? href;
  final IconData? icon;
  final List<SidebarLink> children;
}

class DashboardDummyScreen extends StatelessWidget {
  const DashboardDummyScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/dummy/$title',
      child: Center(child: Text('$title screen (Coming Soon)')),
    );
  }
}

class DashboardSmallCard extends StatelessWidget {
  const DashboardSmallCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.red = false,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool red;

  @override
  Widget build(BuildContext context) {
    final borderColor = red ? const Color(0xFFF6C6C6) : const Color(0xFFC9D1E8);
    final iconBg = red ? const Color(0xFFF8DDDD) : const Color(0xFFE7EEFF);
    final iconColor = red ? const Color(0xFFB01414) : AppColors.primary;
    final labelColor = red ? const Color(0xFFC11212) : const Color(0xFFB3BAD1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      height: 0.95,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
