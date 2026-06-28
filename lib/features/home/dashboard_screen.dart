import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/services/api_client.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/profile_service.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';
import 'models/customer_profile.dart';
import 'models/dashboard_models.dart';
import 'services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.currentHref = '/dashboard/agent'});

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

  static final CustomerDashboardStats _mockStats = const CustomerDashboardStats(
    total: 99,
    successFlight: 99,
    rejectFlight: 99,
    processing: 99,
    returnProcessing: 99,
    totalAppointment: 99,
    totalAmount: 999999,
    paidAmount: 999999,
    dueAmount: 999999,
  );

  final DashboardService _dashboardService = DashboardService();
  late Future<CustomerDashboardStats> _dashboardFuture;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getCustomerDashboard(_selectedPeriod);
  }

  void _changePeriod(String? period) {
    if (period == null || period == _selectedPeriod) return;
    setState(() {
      _selectedPeriod = period;
      _dashboardFuture =
          _dashboardService.getCustomerDashboard(_selectedPeriod);
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardFuture =
          _dashboardService.getCustomerDashboard(_selectedPeriod);
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
            child: FutureBuilder<CustomerDashboardStats>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final stats = snapshot.data ??
                    (isLoading ? _mockStats : CustomerDashboardStats.empty());
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
                            'Dashboard Overview',
                            style: AppTextStyles.headline1.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track your bookings, appointments, and payment history.',
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
                            child: _DashboardCardGrid(
                              cards: _buildCards(stats),
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

  List<DashboardSmallCard> _buildCards(CustomerDashboardStats stats) {
    return [
      DashboardSmallCard(
        label: 'Total Applied Job',
        icon: Icons.work_outline_rounded,
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
        icon: Icons.assignment_return_outlined,
        value: '${stats.returnProcessing}',
      ),
      DashboardSmallCard(
        label: 'Total Appointment',
        icon: Icons.calendar_month_outlined,
        value: '${stats.totalAppointment}',
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

// ── Period selector ───────────────────────────────────────────────────────────

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

// ── Error banner ──────────────────────────────────────────────────────────────

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
              'Unable to load dashboard data. Please check your connection and try again.',
              style: AppTextStyles.body2.copyWith(color: AppPalette.danger),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Card grid ─────────────────────────────────────────────────────────────────

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

// ── Breadcrumbs ───────────────────────────────────────────────────────────────

class _DashboardBreadcrumbs extends StatelessWidget {
  const _DashboardBreadcrumbs();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
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

// ── Sidebar links for customer ────────────────────────────────────────────────

const List<SidebarLink> kDashboardSidebarLinks = [
  SidebarLink(name: 'Home', icon: Icons.home_outlined, href: '/home'),
  SidebarLink(
    name: 'Dashboard',
    icon: Icons.dashboard,
    href: '/dashboard/agent',
  ),
  SidebarLink(
    name: 'My Profile',
    icon: Icons.person,
    href: '/dashboard/customer/profile',
  ),
  SidebarLink(
    name: 'Favourite',
    icon: Icons.favorite_border,
    href: '/dashboard/customer/favourite',
  ),
  SidebarLink(
    name: 'My Booking',
    icon: Icons.grid_view,
    children: [
      SidebarLink(name: 'My Booking', href: '/dashboard/booking/my'),
      SidebarLink(
        name: 'Success File',
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
    name: 'Check Status',
    icon: Icons.radio_button_checked,
    href: '/dashboard/agent/check-status',
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
    name: 'Change Password',
    icon: Icons.swap_horiz,
    href: '/dashboard/agent/change-password',
  ),
  SidebarLink(
    name: 'Terms & Conditions',
    icon: Icons.gavel_outlined,
    href: '/dashboard/agent/terms-conditions',
  ),
];

// ── DashboardPageScaffold ─────────────────────────────────────────────────────

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
  CustomerProfileModel? _customerProfile;

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final raw = await _profileService.getCustomerProfile();
      if (mounted && raw != null) {
        setState(() {
          _customerProfile = CustomerProfileModel.fromJson(raw);
        });
      }
    } catch (e) {
      debugPrint('Error fetching customer profile in scaffold: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _customerProfile?.user?.fullName ?? 'My Account';
    final displayEmail = _customerProfile?.user?.email ?? '';
    final displayPhone = _customerProfile?.user?.phone ?? '';
    final profileImage = _customerProfile?.image;

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: CustomerSidebarDrawer(
        currentHref: widget.currentHref,
        fullName: displayName,
        email: displayEmail,
        phone: displayPhone,
        profileImage: profileImage,
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
            onTap: () => context.push('/dashboard/customer/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFD7E3FF),
                backgroundImage: (profileImage != null &&
                        profileImage.isNotEmpty)
                    ? NetworkImage(profileImage)
                    : null,
                child: (profileImage == null || profileImage.isEmpty)
                    ? const Icon(
                        Icons.person,
                        size: 18,
                        color: Color(0xFF2563EB),
                      )
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

// ── CustomerSidebarDrawer ─────────────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _openKey = _activeParentKey(widget.currentHref);
  }

  @override
  void didUpdateWidget(CustomerSidebarDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentHref != widget.currentHref) {
      _openKey = _activeParentKey(widget.currentHref);
    }
  }

  String? _activeParentKey(String currentHref) {
    for (final link in widget.links) {
      if (link.children.any((child) => child.href == currentHref)) {
        return link.name;
      }
    }
    return null;
  }

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
                      currentHref: widget.currentHref,
                      isOpen: _openKey == link.name,
                      onExpandToggle: () {
                        setState(() {
                          _openKey =
                              _openKey == link.name ? null : link.name;
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
                  Navigator.pop(context);
                  final rootContext = rootNavigatorKey.currentContext;
                  await ApiClient().tokenStorage.clearCookies();
                  if (rootContext != null) {
                    if (rootContext.mounted) {
                      GoRouter.of(rootContext).go(AppRoutes.login);
                    }
                  } else {
                    if (context.mounted) {
                      GoRouter.of(context).go(AppRoutes.login);
                    }
                  }

                  // Fire-and-forget backend logout request in background
                  _authService.getSingOut().catchError((_) {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sidebar user info ─────────────────────────────────────────────────────────

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
        if (email.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        if (phone.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ── Sidebar nav tile ──────────────────────────────────────────────────────────

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.link,
    required this.currentHref,
    required this.isOpen,
    required this.onExpandToggle,
    required this.onTap,
  });

  final SidebarLink link;
  final String currentHref;
  final bool isOpen;
  final VoidCallback onExpandToggle;
  final ValueChanged<SidebarLink> onTap;

  bool get _isDirectlyActive => link.href == currentHref;

  bool get _hasActiveChild =>
      link.children.any((child) => child.href == currentHref);

  @override
  Widget build(BuildContext context) {
    final isActive = _isDirectlyActive || _hasActiveChild;
    final activeColor = AppPalette.brandBlue;
    final activeBackground = activeColor.withValues(alpha: 0.1);

    if (link.children.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          key: ValueKey('${link.name}-$isOpen'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          initiallyExpanded: isOpen,
          onExpansionChanged: (_) => onExpandToggle(),
          leading: Icon(
            link.icon ?? Icons.circle,
            size: 20,
            color: isActive ? activeColor : const Color(0xFF475569),
          ),
          title: Text(
            link.name,
            style: TextStyle(
              color: isActive ? activeColor : const Color(0xFF334155),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          iconColor: activeColor,
          collapsedIconColor:
              isActive ? activeColor : const Color(0xFF64748B),
          children: link.children
              .map(
                (child) => _SidebarChildLink(
                  child: child,
                  isActive: child.href == currentHref,
                  onTap: () => onTap(child),
                ),
              )
              .toList(),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Icon(
          link.icon ?? Icons.circle,
          size: 20,
          color: isActive ? activeColor : const Color(0xFF475569),
        ),
        title: Text(
          link.name,
          style: TextStyle(
            color: isActive ? activeColor : const Color(0xFF334155),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        onTap: () => onTap(link),
      ),
    );
  }
}

class _SidebarChildLink extends StatelessWidget {
  const _SidebarChildLink({
    required this.child,
    required this.isActive,
    required this.onTap,
  });

  final SidebarLink child;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppPalette.brandBlue;
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 8, bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFFBFDBFE) : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(
          Icons.circle,
          size: 7,
          color: isActive ? activeColor : const Color(0xFF94A3B8),
        ),
        title: Text(
          child.name,
          style: TextStyle(
            color: isActive ? activeColor : const Color(0xFF475569),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ── SidebarLink model ─────────────────────────────────────────────────────────

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

// ── DashboardDummyScreen ──────────────────────────────────────────────────────

class DashboardDummyScreen extends StatelessWidget {
  const DashboardDummyScreen({
    super.key,
    required this.title,
    this.currentHref,
  });

  final String title;
  final String? currentHref;

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: currentHref ?? '/dashboard/dummy/$title',
      child: Center(child: Text('$title screen (Coming Soon)')),
    );
  }
}

// ── DashboardSmallCard ────────────────────────────────────────────────────────

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
    final borderColor =
        red ? const Color(0xFFF6C6C6) : const Color(0xFFC9D1E8);
    final iconBg = red ? const Color(0xFFF8DDDD) : const Color(0xFFE7EEFF);
    final iconColor =
        red ? const Color(0xFFB01414) : AppColors.primary;
    final labelColor =
        red ? const Color(0xFFC11212) : const Color(0xFFB3BAD1);

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
