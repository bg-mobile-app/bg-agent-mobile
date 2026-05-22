import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/profile_service.dart';
import '../../common/services/api_client.dart';
import 'models/agency_profile.dart';
import 'customer_profile_edit_screen.dart';
import 'dashboard_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ProfileService _profileService = ProfileService();
  RecruitingAgencyMeDetailsProps? _agentProfileData;
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
      final data = await _profileService.getAgentProfile();
      if (!mounted) return;
      if (data != null) {
        setState(() {
          _agentProfileData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load profile data.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred while fetching profile.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholderAgencyProfile = RecruitingAgencyMeDetailsProps(
      owner: AgentUser(userCode: 'AGENT-0000', fullName: 'Loading Name', email: 'loading@example.com', phone: '01XXXXXXXXX', status: 'Loading'),
      image: null,
      agencyName: 'Agency Name Loading',
      agencyAddress: 'Agency address loading',
      policeStation: RecruitingAgencyLocation(name: 'Police Station'),
      district: RecruitingAgencyLocation(name: 'District'),
      documents: const [
        RecruitingAgencyDocument(
          nidImage: 'https://example.com/nid.jpg',
          tradeLicenseImage: 'https://example.com/trade.jpg',
        ),
      ],
    );

    final profile = _agentProfileData ?? placeholderAgencyProfile;

    return DashboardPageScaffold(
      currentHref: '/dashboard/customer/profile',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: _errorMessage != null && !_isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  child: Skeletonizer(
                    enabled: _isLoading,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Breadcrumb(),
                          const SizedBox(height: 8),
                          const _PageHeading(),
                          const SizedBox(height: 16),
                          _ProfileHeaderCard(profile: profile),
                          const SizedBox(height: 18),
                          const _SectionTitle(
                            title: 'Agent Details',
                            subtitle: 'Information related to your agent profile',
                          ),
                          const SizedBox(height: 12),
                          _BasicInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _AgencyInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _ContactInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _DocumentsInfoCard(profile: profile),
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

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

class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final String? image = profile.image;
    final String title = profile.owner?.fullName ?? 'N/A';
    final String subtitle = profile.owner?.email ?? 'N/A';
    final String status = profile.owner?.status ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppPalette.borderSoftBlue, width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: image != null && image.isNotEmpty
                      ? NetworkImage(image)
                      : const AssetImage('assets/img/sign-in/login.jpg') as ImageProvider,
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
                  child: const Icon(Icons.verified, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: status.isNotEmpty ? status : 'N/A',
                bg: const Color(0xFFE8F0FF),
                fg: const Color(0xFF1E3A8A),
              ),
              const _Pill(
                label: 'Agency Account',
                bg: Color(0xFFEFF6FF),
                fg: AppPalette.textStrongBlue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 170,
            child: FilledButton.icon(
              onPressed: () {
                final state = context.findAncestorStateOfType<_CustomerProfileScreenState>();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CustomerProfileEditScreen(),
                  ),
                ).then((_) {
                  // Trigger screen refresh when coming back from Edit Screen
                  state?._fetchProfile();
                });
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.brandBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _BasicInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _BasicInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.badge_outlined,
      title: 'Basic Info',
      rows: [
        _InfoRow(label: 'USER CODE', value: profile.owner?.userCode ?? 'N/A'),
        _InfoRow(label: 'GENDER', value: 'N/A'),
        _InfoRow(label: 'DATE OF BIRTH', value: 'N/A', isLast: true),
      ],
    );
  }
}

class _AgencyInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _AgencyInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.business_outlined,
      title: 'Agency Info',
      rows: [
        _InfoRow(label: 'AGENCY NAME', value: profile.agencyName ?? 'N/A'),
        _InfoRow(label: 'AGENCY ADDRESS', value: profile.agencyAddress ?? 'N/A', isLast: true),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _ContactInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.contact_page_outlined,
      title: 'Contact Info',
      rows: [
        _InfoRow(label: 'PHONE', value: profile.owner?.phone ?? 'N/A'),
        _InfoRow(label: 'RESIDENTIAL ADDRESS', value: profile.agencyAddress ?? 'N/A'),
        _InfoRow(label: 'POLICE STATION', value: profile.policeStation?.name ?? 'N/A'),
        _InfoRow(label: 'DISTRICT', value: profile.district?.name ?? 'N/A', isLast: true),
      ],
    );
  }
}

class _DocumentsInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _DocumentsInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.description_outlined,
      title: 'Documents Info',
      rows: [
        _InfoRow(label: 'NID IMAGE', value: (profile.documents.isNotEmpty ? profile.documents.first.nidImage : null) ?? 'N/A'),
        _InfoRow(label: 'TRADE LICENSE IMAGE', value: (profile.documents.isNotEmpty ? profile.documents.first.tradeLicenseImage : null) ?? 'N/A', isLast: true),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.rows});

  final IconData icon;
  final String title;
  final List<_InfoRow> rows;

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
  const _InfoRow({required this.label, required this.value, this.isLast = false});

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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
  });

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
              content: const Text('Are you sure you want to logout from this device?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ApiClient().tokenStorage.clearCookies();
            router.go('/login');
          }
        },
        icon: const Icon(Icons.logout, color: AppPalette.danger),
        label: const Text(
          'Logout from Device',
          style: TextStyle(color: AppPalette.danger, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppPalette.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppPalette.borderSoftBlue),
    boxShadow: AppPalette.cardShadow,
  );
}
