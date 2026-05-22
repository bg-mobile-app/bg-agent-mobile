import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/services/api_client.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/profile_service.dart';
import 'models/agency_profile.dart';
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

  static final AgentDashboardStats _mockStats = AgentDashboardStats(
    total: 99,
    successFlight: 99,
    rejectFlight: 99,
    processing: 99,
    returnProcessing: 99,
    totalAmount: 999999,
    paidAmount: 999999,
    dueAmount: 999999,
    commissionAmount: 999999,
  );

  final DashboardService _dashboardService = DashboardService();
  late Future<AgentDashboardStats> _dashboardFuture;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getAgentDashboard(_selectedPeriod);
  }

  void _changePeriod(String? period) {
    if (period == null || period == _selectedPeriod) return;
    setState(() {
      _selectedPeriod = period;
      _dashboardFuture = _dashboardService.getAgentDashboard(_selectedPeriod);
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardFuture = _dashboardService.getAgentDashboard(_selectedPeriod);
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
            child: FutureBuilder<AgentDashboardStats>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final stats = snapshot.data ?? (isLoading ? _mockStats : AgentDashboardStats.empty());
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
                            'Agent Dashboard Overview',
                            style: AppTextStyles.headline1.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Live booking, payment, and commission data for your account.',
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
                          Skeletonizer(
                            enabled: isLoading && snapshot.data == null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DashboardSection(
                                  title: 'My Bookings',
                                  child: _DashboardCardGrid(
                                    cards: _buildMyBookingCards(stats),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  List<DashboardSmallCard> _buildMyBookingCards(AgentDashboardStats stats) {
    return [
      DashboardSmallCard(
        label: 'My Booking',
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
        label: 'Return Passport',
        icon: Icons.badge_outlined,
        value: '${stats.returnProcessing}',
      ),
      DashboardSmallCard(
        label: 'Total Payment',
        icon: Icons.payments_outlined,
        value: _formatMoney(stats.totalAmount),
      ),
      DashboardSmallCard(
        label: 'Paid Payment',
        icon: Icons.account_balance_wallet_outlined,
        value: _formatMoney(stats.paidAmount),
      ),
      DashboardSmallCard(
        label: 'Due Payment',
        icon: Icons.money_off_csred_outlined,
        value: _formatMoney(stats.dueAmount),
        red: true,
      ),
      DashboardSmallCard(
        label: 'Commission',
        icon: Icons.savings_outlined,
        value: _formatMoney(stats.commissionAmount),
      ),
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
    name: 'My Booking',
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
    name: 'Commission',
    icon: Icons.account_balance_wallet_outlined,
    href: '/dashboard/commission',
  ),
  SidebarLink(
    name: 'Check Status',
    icon: Icons.radio_button_checked,
    href: '/dashboard/customer/check-status',
  ),
  SidebarLink(
    name: 'Payment',
    icon: Icons.payment,
    href: '/dashboard/my-payments',
  ),
  SidebarLink(
    name: 'Notifications',
    icon: Icons.notifications_none,
    href: '/dashboard/notifications',
  ),
  SidebarLink(
    name: 'Chat',
    icon: Icons.chat_outlined,
    href: '/dashboard/chat',
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
  SidebarLink(
    name: 'Logout',
    icon: Icons.logout,
    href: '/logout',
  ),
];

class DashboardPageScaffold extends StatefulWidget {
  const DashboardPageScaffold({
    super.key,
    required this.child,
    required this.currentHref,
  });

  final Widget child;
  final String currentHref;

  @override
  State<DashboardPageScaffold> createState() => _DashboardPageScaffoldState();
}

class _DashboardPageScaffoldState extends State<DashboardPageScaffold> {
  final ProfileService _profileService = ProfileService();
  RecruitingAgencyMeDetailsProps? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getAgencyProfile();
    if (mounted) {
      setState(() => _profile = profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = _profile?.owner;
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: CustomerSidebarDrawer(
        currentHref: widget.currentHref,
        fullName: owner?.fullName ?? _profile?.agencyName ?? 'User',
        email: owner?.email ?? 'N/A',
        phone: owner?.phone ?? _profile?.agencyPhone ?? 'N/A',
        profileImage: _profile?.image,
        links: kDashboardSidebarLinks,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/img/logo/logo_black.png',
              height: 34,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/dashboard/notifications'),
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            tooltip: 'Notifications',
          ),
          GestureDetector(
            onTap: () => context.push('/dashboard/customer-profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFD7E3FF),
                backgroundImage: (_profile?.image != null && _profile!.image!.isNotEmpty)
                    ? NetworkImage(_profile!.image!)
                    : null,
                child: (_profile?.image == null || _profile!.image!.isEmpty)
                    ? const Icon(Icons.person, size: 18, color: Color(0xFF2563EB))
                    : null,
              ),
            ),
          ),
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
      body: widget.child,
    );
  }
}

class CustomerSidebarDrawer extends StatefulWidget {
  const CustomerSidebarDrawer({
    super.key,
    required this.currentHref,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.links,
  });

  final String fullName;
  final String currentHref;
  final String email;
  final String phone;
  final String? profileImage;
  final List<SidebarLink> links;

  @override
  State<CustomerSidebarDrawer> createState() => _CustomerSidebarDrawerState();
}

class _CustomerSidebarDrawerState extends State<CustomerSidebarDrawer> {
  final AuthService _authService = AuthService();
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
                onTap: () async {
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  try {
                    await _authService.getSingOut();
                  } catch (_) {
                    // Continue local logout even if backend logout request fails.
                  }
                  await ApiClient().tokenStorage.clearCookies();
                  if (!mounted) return;
                  router.go('/login');
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
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFFD7E3FF),
          backgroundImage: (profileImage != null && profileImage!.isNotEmpty)
              ? NetworkImage(profileImage!)
              : null,
          child: (profileImage == null || profileImage!.isEmpty)
              ? const Icon(Icons.person, color: Color(0xFF2563EB), size: 36)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          fullName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 14, color: Color(0xFF475569)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                email,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF475569)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                phone,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
