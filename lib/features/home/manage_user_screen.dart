import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_colors.dart';
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
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
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

  void _toggleBlock(RecruitingAgencyStaffGETProps member) {
    setState(() {
      final index = _members.indexWhere((item) => item.id == member.id);
      if (index != -1) {
        final isNowActive = _members[index].isActive == 'False';
        _members[index] = _members[index].copyWith(
          isActive: isNowActive ? 'True' : 'False',
        );
      }
    });
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

class _UserTableCard extends StatelessWidget { const _UserTableCard({required this.members,required this.canManage,required this.onToggleBlock,}); final List<RecruitingAgencyStaffGETProps> members; final bool Function(RecruitingAgencyStaffGETProps member) canManage; final ValueChanged<RecruitingAgencyStaffGETProps> onToggleBlock; @override Widget build(BuildContext context){ const currentUserRole='Admin'; final isAdmin=currentUserRole=='Admin'; return StyledDataTableCard(columns:[const DataColumn(label:Text('USER ID')),const DataColumn(label:Text('EMAIL')),const DataColumn(label:Text('PHONE')),const DataColumn(label:Text('ROLE')),const DataColumn(label:Text('DESIGNATION')),if(isAdmin) const DataColumn(label:Text('ACTIVITY')),const DataColumn(label:Text('STATUS / ACTIONS')),],rows:members.map((member){ final hasPermission=canManage(member); final isBlocked=member.isActive=='False'; return DataRow(cells:[DataCell(Text('#${member.userCode}')),DataCell(Text(member.email)),DataCell(Text(member.phone)),DataCell(Text(member.userRole)),DataCell(Text(member.designation)),if(isAdmin) DataCell(TextButton(onPressed:hasPermission?(){}:null,child:const Text('See Activity'))),DataCell(Row(children:[Switch(value:!isBlocked,onChanged:hasPermission?(_)=>onToggleBlock(member):null),Text(isBlocked?'Blocked':'Active')])))]);}).toList()); }}

class _CardGrid extends StatelessWidget { const _CardGrid({required this.members,required this.canManage,required this.onToggleBlock,}); final List<RecruitingAgencyStaffGETProps> members; final bool Function(RecruitingAgencyStaffGETProps member) canManage; final ValueChanged<RecruitingAgencyStaffGETProps> onToggleBlock; @override Widget build(BuildContext context){ return Column(children:List.generate(members.length,(index){ final m=members[index]; final isBlocked=m.isActive=='False'; return ListTile(title:Text(m.userCode),subtitle:Text('${m.email}\n${m.designation}'),isThreeLine:true,trailing:Switch(value:!isBlocked,onChanged:canManage(m)?(_)=>onToggleBlock(m):null)); })); }}

const _skeletonMembers = [
  RecruitingAgencyStaffGETProps(id: 0, userId: 'loading', userCode: 'STF-0000', email: 'loading@example.com', phone: '+0 000', userRole: 'Role', designation: 'Designation', isActive: 'True'),
  RecruitingAgencyStaffGETProps(id: 1, userId: 'loading2', userCode: 'STF-0001', email: 'loading2@example.com', phone: '+0 001', userRole: 'Role', designation: 'Designation', isActive: 'True'),
  RecruitingAgencyStaffGETProps(id: 2, userId: 'loading3', userCode: 'STF-0002', email: 'loading3@example.com', phone: '+0 002', userRole: 'Role', designation: 'Designation', isActive: 'True'),
];
