import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/profile_service.dart';
import '../../common/services/api_client.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';
import 'models/customer_profile.dart';
import 'dashboard_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ProfileService _profileService = ProfileService();
  CustomerProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final raw = await _profileService.getCustomerProfile();
      if (!mounted) return;
      if (raw != null) {
        setState(() {
          _profile = CustomerProfileModel.fromJson(raw);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('EXCEPTION IN _fetchProfile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred while fetching profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder used while skeleton is shown
    final placeholder = CustomerProfileModel(
      id: '0',
      image: null,
      dob: '1990-01-01',
      gender: 'Male',
      passportNo: 'AB1234567',
      passportExpiry: '2030-01-01',
      passportIssue: '2020-01-01',
      address: 'Loading address...',
      policeStation: const CustomerLocation(name: 'Police Station'),
      district: const CustomerLocation(name: 'District'),
      services: const ['Loading...'],
      countries: const [CustomerNamedItem(name: 'Loading...')],
      workTypes: const [CustomerNamedItem(name: 'Loading...')],
      user: const CustomerUser(
        fullName: 'Loading Name',
        email: 'loading@example.com',
        phone: '01XXXXXXXXX',
      ),
    );

    final profile = _profile ?? placeholder;

    return DashboardPageScaffold(
      currentHref: '/dashboard/customer/profile',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: _errorMessage != null && !_isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppPalette.danger,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppPalette.danger,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.brandBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _profileService.invalidateCustomerCache();
                    await _fetchProfile();
                  },
                  child: Skeletonizer(
                    enabled: _isLoading,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Breadcrumb(),
                          const SizedBox(height: 8),
                          const _PageHeading(),
                          const SizedBox(height: 16),
                          _ProfileHeaderCard(profile: profile),
                          const SizedBox(height: 18),
                          const _SectionTitle(
                            title: 'Profile Details',
                            subtitle: 'Personal and contact information for your profile',
                          ),
                          const SizedBox(height: 12),
                          _BasicInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _ContactInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _PassportInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _PersonalizedInfoCard(profile: profile),
                          const SizedBox(height: 24),
                          const _LogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Breadcrumb ────────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: const Text(
            'Dashboard',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: const Text(
            'My Profile',
            style: TextStyle(
              color: AppPalette.textStrongBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      divider: const Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

// ── Page heading ──────────────────────────────────────────────────────────────

class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push('/dashboard/customer/profile/edit'),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.brandBlue,
            side: const BorderSide(color: AppPalette.brandBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile.user?.fullName ?? 'N/A';
    final email = profile.user?.email ?? 'N/A';
    final image = profile.image;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPalette.borderSoftBlue,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFD7E3FF),
                  backgroundImage: (image != null && image.isNotEmpty)
                      ? NetworkImage(image)
                      : null,
                  child: (image == null || image.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF2563EB),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppPalette.brandBlue,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          const _Pill(
            label: 'Customer Account',
            bg: Color(0xFFEFF6FF),
            fg: AppPalette.textStrongBlue,
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppPalette.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ── Info sections ─────────────────────────────────────────────────────────────

class _BasicInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const _BasicInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.person_outline,
      title: 'Basic Info',
      rows: [
        _InfoRow(label: 'NAME', value: _disp(profile.user?.fullName)),
        _InfoRow(label: 'DATE OF BIRTH', value: _formatDate(profile.dob)),
        _InfoRow(label: 'GENDER', value: _disp(profile.gender), isLast: true),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const _ContactInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.contact_mail_outlined,
      title: 'Contact Info',
      rows: [
        _InfoRow(label: 'EMAIL ADDRESS', value: _disp(profile.user?.email)),
        _InfoRow(label: 'PHONE NUMBER', value: _disp(profile.user?.phone)),
        _InfoRow(label: 'ADDRESS', value: _disp(profile.address)),
        _InfoRow(
          label: 'POLICE STATION',
          value: _disp(profile.policeStation?.name),
        ),
        _InfoRow(
          label: 'DISTRICT',
          value: _disp(profile.district?.name),
          isLast: true,
        ),
      ],
    );
  }
}

class _PassportInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const _PassportInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.article_outlined,
      title: 'Passport Info',
      rows: [
        _InfoRow(label: 'PASSPORT NUMBER', value: _disp(profile.passportNo)),
        _InfoRow(
          label: 'PASSPORT EXPIRE DATE',
          value: _formatDate(profile.passportExpiry),
        ),
        _InfoRow(
          label: 'PASSPORT ISSUE DATE',
          value: _formatDate(profile.passportIssue),
          isLast: true,
        ),
      ],
    );
  }
}

class _PersonalizedInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const _PersonalizedInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.favorite_border,
            title: 'Personalized Info',
          ),
          const SizedBox(height: 12),
          _ChipSection(
            label: 'LIKED SERVICES',
            items: profile.services,
          ),
          const Divider(height: 20),
          _ChipSection(
            label: 'LIKED COUNTRIES',
            items: profile.countries.map((c) => c.name).toList(),
          ),
          const Divider(height: 20),
          _ChipSection(
            label: 'LIKED JOB TYPE',
            items: profile.workTypes.map((w) => w.name).toList(),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Chip section ──────────────────────────────────────────────────────────────

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.label,
    required this.items,
    this.isLast = false,
  });

  final String label;
  final List<String> items;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppPalette.textMuted,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        items.isEmpty
            ? const Text(
                'N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: items
                    .where((s) => s.isNotEmpty)
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.textStrongBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

// ── Shared card widget ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: icon, title: title),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppPalette.brandBlue, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppPalette.borderNeutral,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppPalette.textMuted,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 15,
                color: AppPalette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pill ──────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final router = GoRouter.of(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text(
                'Are you sure you want to logout from this device?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppPalette.danger,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ApiClient().tokenStorage.clearCookies();
            final rootCtx = rootNavigatorKey.currentContext;
            if (rootCtx != null) {
              if (rootCtx.mounted) GoRouter.of(rootCtx).go(AppRoutes.login);
            } else {
              if (context.mounted) router.go(AppRoutes.login);
            }
          }
        },
        icon: const Icon(Icons.logout, color: AppPalette.danger),
        label: const Text(
          'Logout from Device',
          style: TextStyle(
            color: AppPalette.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppPalette.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppPalette.borderSoftBlue),
    boxShadow: AppPalette.cardShadow,
  );
}

String _disp(String? value) {
  final t = value?.trim();
  return (t == null || t.isEmpty) ? 'N/A' : t;
}

String _formatDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return 'N/A';
  try {
    final parsed = DateTime.parse(rawDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = parsed.day.toString().padLeft(2, '0');
    return '$day ${months[parsed.month - 1]} ${parsed.year}';
  } catch (_) {
    return rawDate;
  }
}
