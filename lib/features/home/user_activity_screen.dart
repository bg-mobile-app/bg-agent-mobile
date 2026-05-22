import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/styled_data_table_card.dart';
import 'dashboard_screen.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  static const int _pageSize = 10;
  int _currentPage = 1;

  final List<UserActivityItem> _allResults = const [
    UserActivityItem(id: 101, fullName: 'Jane Doe', email: 'jane.doe@example.com', phone: '+1987654321', userCode: 'USR-54321', userRole: 'AGENCY_ADMIN', changes: 'User successfully logged in.', createdAt: '2023-10-27T14:30:00Z'),
    UserActivityItem(id: 102, fullName: 'Jane Doe', email: 'jane.doe@example.com', phone: '+1987654321', userCode: 'USR-54321', userRole: 'AGENCY_ADMIN', changes: 'Viewed the main dashboard.', createdAt: '2023-10-27T14:30:15Z'),
    UserActivityItem(id: 103, fullName: 'Jane Doe', email: 'jane.doe@example.com', phone: '+1987654321', userCode: 'USR-54321', userRole: 'AGENCY_ADMIN', changes: 'Updated profile contact number.', createdAt: '2023-10-27T14:32:45Z'),
    UserActivityItem(id: 104, fullName: 'Jane Doe', email: 'jane.doe@example.com', phone: '+1987654321', userCode: 'USR-54321', userRole: 'AGENCY_ADMIN', changes: "Created a new staff account for 'John Smith'.", createdAt: '2023-10-28T09:15:10Z'),
  ];

  int get _totalCount => 23;
  int get _totalPages => (_totalCount / _pageSize).ceil();

  List<UserActivityItem> get _pagedResults {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _allResults.length) return const [];
    final end = (start + _pageSize).clamp(0, _allResults.length);
    return _allResults.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/user/manage-user',
      child: ColoredBox(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/dashboard/user/manage-user'),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                    ),
                    Text(
                      'User Activity',
                      style: AppTextStyles.headline1.copyWith(color: AppPalette.textStrongBlue),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _breadcrumb(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Viewing activity logs for user ID: ${widget.userId}',
                  style: AppTextStyles.body2.copyWith(color: AppPalette.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Scroll horizontally to view all columns. Pagination appears below the table.',
                  style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                StyledDataTableCard(
                  columns: const [
                    DataColumn(label: Text('USER INFO')),
                    DataColumn(label: Text('EMAIL')),
                    DataColumn(label: Text('PHONE')),
                    DataColumn(label: Text('ROLE')),
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('ACTIVITY')),
                  ],
                  rows: _pagedResults.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${item.fullName}\n#${item.userCode}')),
                        DataCell(Text(item.email)),
                        DataCell(Text(item.phone)),
                        DataCell(Text(item.userRole)),
                        DataCell(Text(_prettyDate(item.createdAt))),
                        DataCell(SizedBox(width: 280, child: Text(item.changes))),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Page $_currentPage of $_totalPages', style: AppTextStyles.body2),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(content: Text('Dashboard', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
        BreadCrumbItem(content: Text('Manage User', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
        BreadCrumbItem(content: Text('User Activity', style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700))),
      ],
      divider: const Icon(Icons.chevron_right, size: 16, color: AppPalette.textMuted),
    );
  }

  String _prettyDate(String iso) => DateTime.parse(iso).toLocal().toString().replaceFirst('.000', '');
}

class UserActivityItem {
  const UserActivityItem({required this.id, required this.fullName, required this.email, required this.phone, required this.userCode, required this.userRole, required this.changes, required this.createdAt});

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String userCode;
  final String userRole;
  final String changes;
  final String createdAt;
}
