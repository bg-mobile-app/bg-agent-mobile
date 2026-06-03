import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/profile_service.dart';
import '../../common/services/api_client.dart';
import 'models/agency_profile.dart';
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
      final data = await _profileService.getAgencyProfile();
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
      id: '0',
      owner: AgentUser(
        id: '0',
        userCode: 'AGENCY-0000',
        fullName: 'Loading Name',
        email: 'loading@example.com',
        phone: '01XXXXXXXXX',
        status: 'Loading',
      ),
      image: null,
      gender: 'Loading',
      dob: '1990-01-01',
      agencyName: 'Agency Name Loading',
      agencyPhone: '01XXXXXXXXX',
      agencyAddress: 'Agency address loading',
      address: 'Residential address loading',
      policeStation: RecruitingAgencyLocation(name: 'Police Station'),
      district: RecruitingAgencyLocation(name: 'District'),
      bankInformation: [
        RecruitingAgencyBankInformation(
          bankName: 'Bank Name',
          branchName: 'Branch Name',
          accountName: 'Account Name',
          accountNo: 'Account Number',
          routingNo: 'Routing Number',
        ),
      ],
      documents: [
        RecruitingAgencyDocument(
          id: '0',
          rlNo: 'RL-0000',
          nidImage: 'https://example.com/nid.jpg',
          tradeLicenseImage: 'https://example.com/trade.jpg',
          rlLicenseImage: 'https://example.com/rl.jpg',
          civilAviationLicenseImage: 'https://example.com/civil-aviation.jpg',
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
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
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
                            title: 'Profile Details',
                            subtitle:
                                'Personal and agency information for your profile',
                          ),
                          const SizedBox(height: 12),
                          _OwnerInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _AgencyInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _BankInfoCard(profile: profile),
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
    final String title = profile.agencyName ?? profile.owner?.fullName ?? 'N/A';
    final String subtitle =
        profile.agencyPhone ?? profile.owner?.email ?? 'N/A';
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
                  border: Border.all(
                    color: AppPalette.borderSoftBlue,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: image != null && image.isNotEmpty
                      ? NetworkImage(image)
                      : const AssetImage('assets/img/sign-in/login.jpg')
                            as ImageProvider,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Working on this page'),
                    duration: Duration(seconds: 2),
                  ),
                );
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

class _AgencyInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _AgencyInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.business_outlined,
      title: 'Agency Info',
      rows: [
        _InfoRow(label: 'AGENCY ID', value: _display(profile.id)),
        _InfoRow(label: 'AGENCY NAME', value: _display(profile.agencyName)),
        _InfoRow(label: 'AGENCY PHONE', value: _display(profile.agencyPhone)),
        _InfoRow(label: 'RL NUMBER', value: _display(_primaryRlNo(profile))),
        _InfoRow(
          label: 'AGENCY ADDRESS',
          value: _display(profile.agencyAddress),
        ),
        _InfoRow(
          label: 'POLICE STATION',
          value: _locationLabel(profile.policeStation),
        ),
        _InfoRow(
          label: 'DISTRICT',
          value: _locationLabel(profile.district),
          isLast: true,
        ),
      ],
    );
  }
}

class _OwnerInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _OwnerInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.badge_outlined,
      title: 'Personal Details',
      rows: [
        _InfoRow(label: 'USER CODE', value: _display(profile.owner?.userCode)),
        _InfoRow(label: 'FULL NAME', value: _display(profile.owner?.fullName)),
        _InfoRow(label: 'EMAIL', value: _display(profile.owner?.email)),
        _InfoRow(label: 'PHONE', value: _display(profile.owner?.phone)),
        _InfoRow(label: 'STATUS', value: _display(profile.owner?.status)),
        _InfoRow(label: 'GENDER', value: _display(profile.gender)),
        _InfoRow(
          label: 'DATE OF BIRTH',
          value: _formatDob(profile.dob),
          isLast: true,
        ),
      ],
    );
  }
}

class _BankInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _BankInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final banks = profile.bankInformation;

    return _InfoCard(
      icon: Icons.account_balance_outlined,
      title: 'Bank Info',
      rows: banks.isEmpty ? _emptyBankRows() : _bankRows(banks),
    );
  }

  List<Widget> _emptyBankRows() {
    return const [
      _InfoRow(label: 'BANK NAME', value: 'N/A'),
      _InfoRow(label: 'BRANCH NAME', value: 'N/A'),
      _InfoRow(label: 'ACCOUNT NAME', value: 'N/A'),
      _InfoRow(label: 'ACCOUNT NO', value: 'N/A'),
      _InfoRow(label: 'ROUTING NO', value: 'N/A', isLast: true),
    ];
  }

  List<Widget> _bankRows(List<RecruitingAgencyBankInformation> banks) {
    final rows = <Widget>[];
    for (var i = 0; i < banks.length; i++) {
      final bank = banks[i];
      final prefix = banks.length == 1 ? '' : 'BANK ${i + 1} ';
      rows.add(
        _InfoRow(label: '${prefix}NAME', value: _display(bank.bankName)),
      );
      rows.add(
        _InfoRow(label: '${prefix}BRANCH', value: _display(bank.branchName)),
      );
      rows.add(
        _InfoRow(
          label: '${prefix}ACCOUNT NAME',
          value: _display(bank.accountName),
        ),
      );
      rows.add(
        _InfoRow(label: '${prefix}ACCOUNT NO', value: _display(bank.accountNo)),
      );
      rows.add(
        _InfoRow(
          label: '${prefix}ROUTING NO',
          value: _display(bank.routingNo),
          isLast: i == banks.length - 1,
        ),
      );
    }
    return rows;
  }
}

class _DocumentsInfoCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _DocumentsInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final documents = profile.documents;

    return _InfoCard(
      icon: Icons.description_outlined,
      title: 'Documents Info',
      rows: documents.isEmpty ? _emptyDocumentRows() : _documentRows(documents),
    );
  }

  List<Widget> _emptyDocumentRows() {
    return const [
      _InfoRow(label: 'DOCUMENT ID', value: 'N/A'),
      _InfoRow(label: 'RL NO', value: 'N/A'),
      _DocumentImageRow(label: 'NID IMAGE', imageUrl: null),
      _DocumentImageRow(label: 'TRADE LICENSE IMAGE', imageUrl: null),
      _DocumentImageRow(label: 'RL LICENSE IMAGE', imageUrl: null),
      _DocumentImageRow(
        label: 'CIVIL AVIATION LICENSE IMAGE',
        imageUrl: null,
        isLast: true,
      ),
    ];
  }

  List<Widget> _documentRows(List<RecruitingAgencyDocument> documents) {
    final rows = <Widget>[];
    for (var i = 0; i < documents.length; i++) {
      final document = documents[i];
      final prefix = documents.length == 1 ? '' : 'DOCUMENT ${i + 1} ';
      rows.add(_InfoRow(label: '${prefix}ID', value: _display(document.id)));
      rows.add(
        _InfoRow(label: '${prefix}RL NO', value: _display(document.rlNo)),
      );
      rows.add(
        _DocumentImageRow(
          label: '${prefix}NID IMAGE',
          imageUrl: document.nidImage,
        ),
      );
      rows.add(
        _DocumentImageRow(
          label: '${prefix}TRADE LICENSE IMAGE',
          imageUrl: document.tradeLicenseImage,
        ),
      );
      rows.add(
        _DocumentImageRow(
          label: '${prefix}RL LICENSE IMAGE',
          imageUrl: document.rlLicenseImage,
        ),
      );
      rows.add(
        _DocumentImageRow(
          label: '${prefix}CIVIL AVIATION LICENSE IMAGE',
          imageUrl: document.civilAviationLicenseImage,
          isLast: i == documents.length - 1,
        ),
      );
    }
    return rows;
  }
}

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

class _DocumentImageRow extends StatelessWidget {
  const _DocumentImageRow({
    required this.label,
    required this.imageUrl,
    this.isLast = false,
  });

  final String label;
  final String? imageUrl;
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
            child: Align(
              alignment: Alignment.centerRight,
              child: _DocumentPreview(imageUrl: imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const Text(
        'N/A',
        style: TextStyle(
          fontSize: 15,
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        width: 88,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 88,
          height: 60,
          color: const Color(0xFFE2E8F0),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppPalette.textMuted,
          ),
        ),
      ),
    );
  }
}

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
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
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
            router.go('/login');
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppPalette.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppPalette.borderSoftBlue),
    boxShadow: AppPalette.cardShadow,
  );
}

String _display(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return 'N/A';
  return trimmed;
}

String? _primaryRlNo(RecruitingAgencyMeDetailsProps profile) {
  for (final document in profile.documents) {
    final rlNo = document.rlNo?.trim();
    if (rlNo != null && rlNo.isNotEmpty) return rlNo;
  }
  return null;
}

String _locationLabel(RecruitingAgencyLocation? location) {
  if (location == null) return 'N/A';
  final name = location.name.trim();
  final id = location.id?.toString().trim();
  if (name.isEmpty && (id == null || id.isEmpty)) return 'N/A';
  if (id == null || id.isEmpty) return name;
  if (name.isEmpty) return 'ID $id';
  return '$name (ID $id)';
}

String _formatDob(String? rawDob) {
  if (rawDob == null || rawDob.trim().isEmpty) return 'N/A';
  try {
    final parsed = DateTime.parse(rawDob);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = parsed.day.toString().padLeft(2, '0');
    return '$day ${months[parsed.month - 1]} ${parsed.year}';
  } catch (_) {
    return rawDob;
  }
}
