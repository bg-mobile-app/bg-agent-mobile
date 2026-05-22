import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import 'dashboard_screen.dart';
import 'services/staff_accounts_service.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StaffAccountsService _staffAccountsService = StaffAccountsService();

  final List<RecruitingAgencyStaffGETProps> _members = [];

  String _query = '';
  bool _isCardView = false;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  bool _hasNextPage = true;

  static const bool _currentUserIsAdmin = true;
  static const String _currentUserRole = 'Admin';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadStaff(page: 1, isInitial: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff({required int page, bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });
    } else {
      if (_isLoadingMore || !_hasNextPage) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await _staffAccountsService.getRecruitingAgencyStaff(
        page: page,
      );

      if (!mounted) return;

      setState(() {
        if (isInitial) _members.clear();
        _members.addAll(response.results);
        _currentPage = page;
        _hasNextPage = response.next != null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load staff. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isInitialLoading) return;
    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold) {
      if (_hasNextPage && !_isLoadingMore) {
        _loadStaff(page: _currentPage + 1);
      }
    }
  }

  List<RecruitingAgencyStaffGETProps> get _filteredMembers {
    final lower = _query.trim().toLowerCase();
    return _members.where((member) {
      final textMatch =
          lower.isEmpty ||
          member.userId.toLowerCase().contains(lower) ||
          member.userCode.toLowerCase().contains(lower) ||
          member.email.toLowerCase().contains(lower) ||
          member.phone.toLowerCase().contains(lower) ||
          member.designation.toLowerCase().contains(lower) ||
          member.userRole.toLowerCase().contains(lower);
      return textMatch;
    }).toList();
  }

  bool _canManage(RecruitingAgencyStaffGETProps member) =>
      _currentUserIsAdmin || member.userRole == _currentUserRole;

  Future<void> _toggleBlock(RecruitingAgencyStaffGETProps member) async {
    final isBlocked = member.isActive == 'False';
    final nextIsActive = isBlocked;
    try {
      await _staffAccountsService.updateStaffVerifiedStatus(
        userId: member.userId,
        isActive: nextIsActive,
      );
      setState(() {
        final index = _members.indexWhere((item) => item.id == member.id);
        if (index != -1) {
          _members[index] = _members[index].copyWith(
            isActive: nextIsActive ? 'True' : 'False',
          );
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredMembers;

    return DashboardPageScaffold(
      currentHref: '/dashboard/user/manage-user',
      child: ColoredBox(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Users',
                        style: AppTextStyles.headline1.copyWith(
                          color: AppPalette.textStrongBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'All staff from recruiting agency API.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SearchAndActions(
                        isCardView: _isCardView,
                        onViewChanged: (value) =>
                            setState(() => _isCardView = value),
                        controller: _searchController,
                        onQueryChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      Skeletonizer(
                        enabled: _isInitialLoading,
                        child: _isCardView
                            ? _CardGrid(
                                members: _isInitialLoading
                                    ? _skeletonMembers
                                    : visible,
                                canManage: _canManage,
                                onToggleBlock: _toggleBlock,
                              )
                            : _UserTableCard(
                                members: _isInitialLoading
                                    ? _skeletonMembers
                                    : visible,
                                canManage: _canManage,
                                onToggleBlock: _toggleBlock,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_isLoadingMore)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// keep other widgets mostly unchanged
class _SearchAndActions extends StatelessWidget { const _SearchAndActions({required this.isCardView,required this.onViewChanged,required this.controller,required this.onQueryChanged,}); final bool isCardView; final ValueChanged<bool> onViewChanged; final TextEditingController controller; final ValueChanged<String> onQueryChanged; @override Widget build(BuildContext context){ return Column(children:[Row(children:[ViewToggleButton(isCardView:isCardView,onChanged:onViewChanged),const SizedBox(width: AppSpacing.sm),Expanded(child:SizedBox(height:48,child:ElevatedButton.icon(onPressed:()=>context.go('/dashboard/user/create-user'),icon:const Icon(Icons.person_add),label:const Text('Add Member'))))]),const SizedBox(height: AppSpacing.sm),AppSearchBar(controller:controller,hintText:'Search by user ID, email, phone, role...',onChanged:onQueryChanged,onSearchTap:()=>onQueryChanged(controller.text))]);}}

class _UserTableCard extends StatelessWidget {
  const _UserTableCard({
    required this.members,
    required this.canManage,
    required this.onToggleBlock,
  });

  final List<RecruitingAgencyStaffGETProps> members;
  final bool Function(RecruitingAgencyStaffGETProps member) canManage;
  final ValueChanged<RecruitingAgencyStaffGETProps> onToggleBlock;

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF004AC6);
      case 'staff':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    const currentUserRole = 'Admin';
    final isAdmin = currentUserRole == 'Admin';

    return StyledDataTableCard(
      columns: [
        const DataColumn(label: Text('USER ID')),
        const DataColumn(label: Text('EMAIL')),
        const DataColumn(label: Text('PHONE')),
        const DataColumn(label: Text('ROLE')),
        const DataColumn(label: Text('DESIGNATION')),
        if (isAdmin) const DataColumn(label: Text('ACTIVITY')),
        const DataColumn(label: Text('STATUS / ACTIONS')),
      ],
      rows: members.map((member) {
        final hasPermission = canManage(member);
        final isBlocked = member.isActive == 'False';
        final roleColor = _getRoleColor(member.userRole);

        return DataRow(
          cells: [
            DataCell(
              Text(
                '#${member.userCode}',
                style: const TextStyle(
                  color: Color(0xFF737686),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataCell(
              Text(
                member.email,
                style: const TextStyle(color: Color(0xFF434655)),
              ),
            ),
            DataCell(
              Text(
                member.phone,
                style: const TextStyle(color: Color(0xFF434655)),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  member.userRole,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                member.designation,
                style: const TextStyle(color: Color(0xFF141B2B)),
              ),
            ),
            if (isAdmin)
              DataCell(
                TextButton(
                  onPressed: hasPermission ? () => context.go('/dashboard/user/manage-user/activity/${member.userId}') : null,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE9EDFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                  ),
                  child: const Text(
                    'See Activity',
                    style: TextStyle(
                      color: Color(0xFF004AC6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            DataCell(
              Row(
                children: [
                  if (hasPermission) ...[
                    Switch(
                      value: !isBlocked,
                      onChanged: (_) => onToggleBlock(member),
                      activeTrackColor: const Color(0xFF004AC6),
                      inactiveTrackColor: const Color(0xFFC3C6D7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBlocked ? 'Blocked' : 'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: isBlocked ? AppPalette.danger : AppPalette.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Color(0xFF434655),
                      ),
                      onPressed: () => context.go('/dashboard/user/create-user/${member.userId}'),
                      tooltip: 'Edit User',
                    ),
                  ] else ...[
                    Icon(
                      isBlocked ? Icons.block : Icons.check_circle,
                      size: 16,
                      color: isBlocked ? AppPalette.danger : AppPalette.success,
                    ),
                    const SizedBox(width: 4),
                    Text(isBlocked ? 'Blocked' : 'Active'),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.members,
    required this.canManage,
    required this.onToggleBlock,
  });

  final List<RecruitingAgencyStaffGETProps> members;
  final bool Function(RecruitingAgencyStaffGETProps member) canManage;
  final ValueChanged<RecruitingAgencyStaffGETProps> onToggleBlock;

  @override
  Widget build(BuildContext context) {
    const currentUserRole = 'Admin';
    final isAdmin = currentUserRole == 'Admin';

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 220,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        final isBlocked = m.isActive == 'False';
        final hasPermission = canManage(m);
        
        final initials = m.userCode.length >= 4 
            ? m.userCode.substring(m.userCode.length - 4) 
            : m.userCode;

        return Container(
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.borderNeutral),
            boxShadow: AppPalette.cardShadow,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${m.userCode}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.borderSoftBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.userRole,
                      style: const TextStyle(
                        color: AppPalette.brandBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.mail_outline, size: 16, color: AppPalette.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppPalette.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(height: 1, color: AppPalette.borderNeutral),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: !isBlocked,
                            onChanged: hasPermission ? (_) => onToggleBlock(m) : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBlocked ? 'Blocked' : 'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isBlocked ? AppPalette.danger : AppPalette.success,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isAdmin) ...[
                        TextButton(
                          onPressed: hasPermission ? () => context.go('/dashboard/user/manage-user/activity/${m.userId}') : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'See Activity',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.brandBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (hasPermission)
                        OutlinedButton.icon(
                          onPressed: () => context.go('/dashboard/user/create-user/${m.userId}'),
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text('Edit', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(color: AppPalette.borderNeutral),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

const _skeletonMembers = [
  RecruitingAgencyStaffGETProps(id: 0, userId: 'loading', userCode: 'STF-0000', email: 'loading@example.com', phone: '+0 000', userRole: 'Role', designation: 'Designation', isActive: 'True'),
  RecruitingAgencyStaffGETProps(id: 1, userId: 'loading2', userCode: 'STF-0001', email: 'loading2@example.com', phone: '+0 001', userRole: 'Role', designation: 'Designation', isActive: 'True'),
  RecruitingAgencyStaffGETProps(id: 2, userId: 'loading3', userCode: 'STF-0002', email: 'loading3@example.com', phone: '+0 002', userRole: 'Role', designation: 'Designation', isActive: 'True'),
];
