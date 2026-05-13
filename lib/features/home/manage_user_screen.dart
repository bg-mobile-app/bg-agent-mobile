import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/view_toggle_button.dart';
import 'dashboard_screen.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_StaffMember> _members = List<_StaffMember>.from(_seedMembers);

  String _query = '';
  bool _isCardView = false;
  int _visibleCount = 6;
  static const int _chunkSize = 6;

  static const bool _currentUserIsAdmin = true;
  static const String _currentUserRole = 'Admin';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels >= threshold) {
      final total = _filteredMembers.length;
      if (_visibleCount < total) {
        setState(
          () => _visibleCount = (_visibleCount + _chunkSize).clamp(0, total),
        );
      }
    }
  }

  List<_StaffMember> get _filteredMembers {
    final lower = _query.trim().toLowerCase();
    return _members.where((member) {
      final textMatch =
          lower.isEmpty ||
          member.userId.toLowerCase().contains(lower) ||
          member.name.toLowerCase().contains(lower) ||
          member.email.toLowerCase().contains(lower) ||
          member.phone.toLowerCase().contains(lower) ||
          member.designation.toLowerCase().contains(lower) ||
          member.role.toLowerCase().contains(lower);
      return textMatch;
    }).toList();
  }

  List<_StaffMember> get _visibleItems {
    final filtered = _filteredMembers;
    return filtered.take(_visibleCount.clamp(0, filtered.length)).toList();
  }

  bool _canManage(_StaffMember member) =>
      _currentUserIsAdmin || member.role == _currentUserRole;

  void _toggleBlock(_StaffMember member) {
    setState(() {
      final index = _members.indexWhere((item) => item.userId == member.userId);
      if (index != -1) {
        _members[index] = _members[index].copyWith(
          isBlocked: !_members[index].isBlocked,
        );
      }
    });
  }

  void _resetInfiniteData() {
    setState(() => _visibleCount = _chunkSize);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCount = _filteredMembers.length;
    final visible = _visibleItems;

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
                        'Infinite scroll enabled for list and card view.',
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
                        onQueryChanged: (value) {
                          _query = value;
                          _resetInfiniteData();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _isCardView
                          ? _CardGrid(
                              members: visible,
                              canManage: _canManage,
                              onToggleBlock: _toggleBlock,
                            )
                          : _UserTableCard(
                              members: visible,
                              canManage: _canManage,
                              onToggleBlock: _toggleBlock,
                            ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Text(
                          visible.length < filteredCount
                              ? 'Scroll down to load more users...'
                              : 'Showing all $filteredCount users',
                          style: AppTextStyles.body2,
                        ),
                      ),
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

class _SearchAndActions extends StatelessWidget {
  const _SearchAndActions({
    required this.isCardView,
    required this.onViewChanged,
    required this.controller,
    required this.onQueryChanged,
  });
  final bool isCardView;
  final ValueChanged<bool> onViewChanged;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ViewToggleButton(isCardView: isCardView, onChanged: onViewChanged),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard/user/create-user'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSearchBar(
          controller: controller,
          hintText: 'Search by user ID, email, phone, role...',
          onChanged: onQueryChanged,
          onSearchTap: () => onQueryChanged(controller.text),
        ),
      ],
    );
  }
}

class _UserTableCard extends StatelessWidget {
  const _UserTableCard({
    required this.members,
    required this.canManage,
    required this.onToggleBlock,
  });
  final List<_StaffMember> members;
  final bool Function(_StaffMember member) canManage;
  final ValueChanged<_StaffMember> onToggleBlock;

  @override
  Widget build(BuildContext context) {
    const currentUserRole = 'Admin';
    final isAdmin = currentUserRole == 'Admin';

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12051B).withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: const Color(0xFFE5E7EB)),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F3FF)),
            dataRowColor: WidgetStateProperty.all(Colors.white),
            dividerThickness: 1,
            dataRowMaxHeight: 72,
            columnSpacing: 28,
            headingTextStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF434655),
              letterSpacing: 0.5,
            ),
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
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      '#${member.userId}',
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
                        color: member.roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        member.role,
                        style: TextStyle(
                          color: member.roleColor,
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
                        onPressed: hasPermission ? () {} : null,
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
                            value: !member.isBlocked,
                            onChanged: (_) => onToggleBlock(member),
                            activeTrackColor: const Color(0xFF004AC6),
                            inactiveTrackColor: const Color(0xFFC3C6D7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member.isBlocked ? 'Blocked' : 'Active',
                            style: TextStyle(
                              fontSize: 12,
                              color: member.isBlocked
                                  ? AppPalette.danger
                                  : AppPalette.success,
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
                            onPressed: () {},
                            tooltip: 'Edit User',
                          ),
                        ] else ...[
                          Icon(
                            member.isBlocked ? Icons.block : Icons.check_circle,
                            size: 16,
                            color: member.isBlocked
                                ? AppPalette.danger
                                : AppPalette.success,
                          ),
                          const SizedBox(width: 4),
                          Text(member.isBlocked ? 'Blocked' : 'Active'),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.members,
    required this.canManage,
    required this.onToggleBlock,
  });
  final List<_StaffMember> members;
  final bool Function(_StaffMember member) canManage;
  final ValueChanged<_StaffMember> onToggleBlock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        members.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _StaffCard(
            member: members[index],
            canManage: canManage(members[index]),
            onToggleBlock: () => onToggleBlock(members[index]),
          ),
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    required this.canManage,
    required this.onToggleBlock,
  });
  final _StaffMember member;
  final bool canManage;
  final VoidCallback onToggleBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0D2563),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE2F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${member.userId}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF434655),
                  ),
                ),
              ),
              _RoleBadge(role: member.role, color: member.roleColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CircleAvatar(
            radius: 44,
            backgroundColor: AppPalette.brandBlue.withValues(alpha: 0.1),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                member.name.split(' ').map((e) => e[0]).take(2).join(),
                style: AppTextStyles.subtitle1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            member.name,
            style: AppTextStyles.subtitle1.copyWith(fontSize: 20),
          ),
          Text(member.designation, style: AppTextStyles.body2),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.mail,
                      color: AppPalette.brandBlue,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(member.email, style: AppTextStyles.body2),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: AppPalette.brandBlue,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(member.phone, style: AppTextStyles.body2),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Status',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: !member.isBlocked,
                onChanged: canManage ? (_) => onToggleBlock() : null,
                activeTrackColor: AppPalette.brandBlue,
                inactiveTrackColor: const Color(0xFFC3C6D7),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canManage ? () {} : null,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Activity'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9EDFF),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 2,
                    side: BorderSide.none,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canManage ? () {} : null,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9EDFF),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 2,
                    side: BorderSide.none,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.color});
  final String role;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      role,
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _CustomToggleSwitch extends StatefulWidget {
  const _CustomToggleSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<_CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<_CustomToggleSwitch> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(_CustomToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: _currentValue
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 64,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onChanged != null
                      ? () {
                          setState(() => _currentValue = false);
                          widget.onChanged!(false);
                        }
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        size: 18,
                        color: !_currentValue
                            ? AppPalette.danger
                            : const Color(0xFF434655),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Block',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: !_currentValue
                              ? AppPalette.danger
                              : const Color(0xFF434655),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onChanged != null
                      ? () {
                          setState(() => _currentValue = true);
                          widget.onChanged!(true);
                        }
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: _currentValue
                            ? AppPalette.success
                            : const Color(0xFF434655),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _currentValue
                              ? AppPalette.success
                              : const Color(0xFF434655),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffMember {
  const _StaffMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.designation,
    required this.roleColor,
    this.isBlocked = false,
  });
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String designation;
  final Color roleColor;
  final bool isBlocked;
  _StaffMember copyWith({bool? isBlocked}) => _StaffMember(
    userId: userId,
    name: name,
    email: email,
    phone: phone,
    role: role,
    designation: designation,
    roleColor: roleColor,
    isBlocked: isBlocked ?? this.isBlocked,
  );
}

const List<_StaffMember> _seedMembers = [
  _StaffMember(
    userId: 'STF-1024',
    name: 'Kabir Ahmed',
    email: 'k.ahmed@bideshgami.com',
    phone: '+880 1712 345 678',
    role: 'Admin',
    designation: 'Senior Operations Manager',
    roleColor: AppPalette.success,
  ),
  _StaffMember(
    userId: 'STF-1002',
    name: 'Sarah Jenkins',
    email: 'sarah@company.com',
    phone: '+1 202 555 0123',
    role: 'Manager',
    designation: 'Regional Manager',
    roleColor: AppPalette.brandBlue,
  ),
  _StaffMember(
    userId: 'STF-1003',
    name: 'Amara Okafor',
    email: 'amara@company.com',
    phone: '+1 202 555 0160',
    role: 'Support',
    designation: 'Customer Support Lead',
    roleColor: AppPalette.warning,
  ),
  _StaffMember(
    userId: 'STF-1004',
    name: 'David Tuan',
    email: 'david@company.com',
    phone: '+1 202 555 0135',
    role: 'Reviewer',
    designation: 'Quality Reviewer',
    roleColor: AppPalette.danger,
  ),
  _StaffMember(
    userId: 'STF-1005',
    name: 'Nora Silva',
    email: 'nora@company.com',
    phone: '+1 202 555 0144',
    role: 'Manager',
    designation: 'Operations Manager',
    roleColor: AppPalette.brandBlue,
  ),
  _StaffMember(
    userId: 'STF-1006',
    name: 'Kofi Mensah',
    email: 'kofi@company.com',
    phone: '+1 202 555 0174',
    role: 'Support',
    designation: 'Support Executive',
    roleColor: AppPalette.warning,
  ),
  _StaffMember(
    userId: 'STF-1007',
    name: 'Ruma Das',
    email: 'ruma@company.com',
    phone: '+880 1700 112233',
    role: 'Support',
    designation: 'Support Associate',
    roleColor: AppPalette.warning,
  ),
  _StaffMember(
    userId: 'STF-1008',
    name: 'Tanvir Hasan',
    email: 'tanvir@company.com',
    phone: '+880 1755 010101',
    role: 'Reviewer',
    designation: 'Compliance Reviewer',
    roleColor: AppPalette.danger,
  ),
  _StaffMember(
    userId: 'STF-1009',
    name: 'Maya Roy',
    email: 'maya@company.com',
    phone: '+880 1888 778899',
    role: 'Manager',
    designation: 'Area Manager',
    roleColor: AppPalette.brandBlue,
  ),
];
