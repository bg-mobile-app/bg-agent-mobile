import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/profile_service.dart';
import '../../common/services/api_client.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/agency_access.dart';
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
  Map<String, dynamic>? _staffProfileData;
  bool _isStaff = false;
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
      await AuthService().getCurrentUser();
      final userData = AuthService.currentUserData;
      final isStaff = AgencyAccess.isAgencyStaffAccount(userData);

      if (isStaff) {
        final staffListResponse = await _profileService.getAgencyStaffProfile();
        if (!mounted) return;
        if (staffListResponse != null && staffListResponse['results'] is List) {
          final results = staffListResponse['results'] as List;
          
          final myEmail = userData?['email']?.toString() ?? userData?['user']?['email']?.toString();
          final myId = userData?['id']?.toString() ?? userData?['userId']?.toString() ?? userData?['user']?['id']?.toString() ?? userData?['user']?['userId']?.toString();
          final myUserCode = userData?['userCode']?.toString() ?? userData?['user_code']?.toString() ?? userData?['user']?['userCode']?.toString();
          
          Map<String, dynamic>? myRecord;
          for (var item in results) {
            if (item is Map<String, dynamic>) {
              final itemUserId = item['userId']?.toString() ?? item['user_id']?.toString();
              final itemEmail = item['email']?.toString();
              final itemUserCode = item['userCode']?.toString() ?? item['user_code']?.toString();
              
              if ((myId != null && itemUserId == myId) ||
                  (myEmail != null && itemEmail?.toLowerCase() == myEmail.toLowerCase()) ||
                  (myUserCode != null && itemUserCode == myUserCode)) {
                myRecord = item;
                break;
              }
            }
          }
          
          if (myRecord != null) {
            setState(() {
              _isStaff = true;
              _staffProfileData = myRecord;
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = "Could not find matching staff record for logged-in user.";
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = "Failed to load staff profile data.";
            _isLoading = false;
          });
        }
      } else {
        final data = await _profileService.getAgencyProfile();
        if (!mounted) return;
        if (data != null) {
          setState(() {
            _isStaff = false;
            _agentProfileData = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Failed to load profile data.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('EXCEPTION IN _fetchProfile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred while fetching profile: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isStaff) {
      final staff = _staffProfileData ?? {
        'fullName': 'Loading Staff Name',
        'designation': 'Staff',
        'email': 'loading@example.com',
        'phone': 'N/A',
        'userCode': 'AGS-00000',
        'userId': 'usr_00000',
        'userRole': 'agency_staff',
        'isActive': true,
        'permissions': const <String>[],
      };

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
                            _StaffProfileHeaderCard(staffData: staff),
                            const SizedBox(height: 18),
                            const _SectionTitle(
                              title: 'Staff Profile Details',
                              subtitle: 'Personal and system access details',
                            ),
                            const SizedBox(height: 12),
                            _StaffInfoCard(staffData: staff),
                            const SizedBox(height: 12),
                            _StaffPermissionsCard(staffData: staff),
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
                          _ProfileHeaderCard(
                            profile: profile,
                          ),
                          const SizedBox(height: 18),
                          const _SectionTitle(
                            title: 'Profile Details',
                            subtitle:
                                'Personal and contact information for your profile',
                          ),
                          const SizedBox(height: 12),
                          _BasicInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _ContactInfoCard(profile: profile),
                          const SizedBox(height: 12),
                          _DocumentGalleryCard(profile: profile),
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

  const _ProfileHeaderCard({
    required this.profile,
  });

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
      icon: Icons.person_outline,
      title: 'Basic Info',
      rows: [
        _InfoRow(label: 'STATUS', value: _display(profile.owner?.status)),
        _InfoRow(label: 'AGENT ID', value: _display(profile.owner?.userCode)),
        _InfoRow(label: 'NAME', value: _display(profile.owner?.fullName)),
        _InfoRow(label: 'GENDER', value: _display(profile.gender)),
        _InfoRow(label: 'DATE OF BIRTH', value: _formatDob(profile.dob)),
        _InfoRow(label: 'AGENCY NAME', value: _display(profile.agencyName)),
        _InfoRow(
          label: 'AGENCY ADDRESS',
          value: _display(profile.agencyAddress),
          isLast: true,
        ),
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
      icon: Icons.contact_mail_outlined,
      title: 'Contact Info',
      rows: [
        _InfoRow(label: 'EMAIL ADDRESS', value: _display(profile.owner?.email)),
        _InfoRow(label: 'PHONE NUMBER', value: _display(profile.owner?.phone)),
        _InfoRow(label: 'ADDRESS', value: _display(profile.address)),
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

class _DocumentGalleryCard extends StatelessWidget {
  final RecruitingAgencyMeDetailsProps profile;
  const _DocumentGalleryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final doc = profile.documents.isNotEmpty ? profile.documents.first : null;
    return _InfoCard(
      icon: Icons.photo_library_outlined,
      title: 'Image Gallery',
      rows: [
        _DocumentImageRow(label: 'NID IMAGE', imageUrl: doc?.nidImage),
        _DocumentImageRow(
          label: 'TRADE LICENSE IMAGE',
          imageUrl: doc?.tradeLicenseImage,
          isLast: true,
        ),
      ],
    );
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

    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(12),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                color: const Color(0xFF0F172A),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                  size: 48,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: ClipRRect(
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

class _StaffProfileHeaderCard extends StatelessWidget {
  final Map<String, dynamic> staffData;

  const _StaffProfileHeaderCard({required this.staffData});

  @override
  Widget build(BuildContext context) {
    final String fullName = staffData['fullName'] ?? staffData['full_name'] ?? 'N/A';
    final String designation = staffData['designation'] ?? 'Staff Member';
    final bool isActive = staffData['isActive'] == true || staffData['is_active'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.borderSoftBlue,
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFD7E3FF),
              child: Icon(Icons.person, size: 50, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            designation,
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: isActive ? 'Active' : 'Inactive',
                bg: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                fg: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
              const _Pill(
                label: 'Agency Staff',
                bg: Color(0xFFEFF6FF),
                fg: AppPalette.textStrongBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffInfoCard extends StatelessWidget {
  final Map<String, dynamic> staffData;

  const _StaffInfoCard({required this.staffData});

  @override
  Widget build(BuildContext context) {
    final String userCode = staffData['userCode'] ?? staffData['user_code'] ?? 'N/A';
    final String userId = staffData['userId'] ?? staffData['user_id'] ?? 'N/A';
    final String email = staffData['email'] ?? 'N/A';
    final String phone = staffData['phone'] ?? 'N/A';
    final String role = staffData['userRole'] ?? staffData['user_role'] ?? 'agency_staff';

    return _InfoCard(
      icon: Icons.badge_outlined,
      title: 'Staff Member Details',
      rows: [
        _InfoRow(label: 'STAFF CODE', value: userCode),
        _InfoRow(label: 'USER ID', value: userId),
        _InfoRow(label: 'USER ROLE', value: role.replaceAll('_', ' ').toUpperCase()),
        _InfoRow(label: 'EMAIL', value: email),
        _InfoRow(label: 'PHONE', value: phone, isLast: true),
      ],
    );
  }
}

class _StaffPermissionsCard extends StatelessWidget {
  final Map<String, dynamic> staffData;

  const _StaffPermissionsCard({required this.staffData});

  @override
  Widget build(BuildContext context) {
    final permissionsRaw = staffData['permissions'];
    final List<String> permissions = permissionsRaw is List
        ? permissionsRaw.map((e) => e.toString()).toList()
        : [];

    final Map<String, String> permissionLabels = {
      "ADS_CREATE": "Ads Create",
      "ADS_LIST": "Ads List",
      "BOOKING_LIST": "Booking List",
      "RETURN_LIST": "Return List",
      "OUR_BOOKING": "Our Booking",
      "APPOINTMENT_LIST": "Appointment List",
      "USER": "User",
      "REMINDER_LIST": "Reminder List",
      "CHECK_STATUS": "Check Status",
      "COMMISSION": "Commission",
      "PAYMENT_LIST": "Payment List",
      "RECEIVE_PAYMENT_LIST": "Receive Payment List",
      "REFUND_PAYMENT": "Refund Payment",
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.lock_open_outlined, title: 'Assigned Permissions'),
          const SizedBox(height: 14),
          permissions.isEmpty
              ? const Text(
                  'No specific permissions assigned.',
                  style: TextStyle(color: AppPalette.textMuted, fontSize: 14),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: permissions.map((perm) {
                    final label = permissionLabels[perm] ?? perm;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
