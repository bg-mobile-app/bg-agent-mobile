import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import 'widgets/return_request_card.dart';
import '../home/dashboard_screen.dart';

class PassportReturnRequestScreen extends StatefulWidget {
  const PassportReturnRequestScreen({super.key});

  @override
  State<PassportReturnRequestScreen> createState() =>
      _PassportReturnRequestScreenState();
}

class _PassportReturnRequestScreenState extends State<PassportReturnRequestScreen> {
  bool _isCardView = false;
  bool _isMyReturn = false; // false = Customer Return, true = My Return
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  final List<ReturnRequestItem> _items = const [
    ReturnRequestItem(
      workPermitId: 'WP-RET-1001',
      id: 8801,
      createdAt: '2026-05-15',
      name: 'Rahim Uddin',
      passportNo: 'A1234567',
      fromCountry: 'Bangladesh',
      toCountry: 'UAE',
      agencyTotalCost: 75000,
      paidAmount: 25000,
      isMyReturn: false,
    ),
    ReturnRequestItem(
      workPermitId: 'WP-RET-1002',
      id: 8802,
      createdAt: '2026-05-16',
      name: 'Selim Reza',
      passportNo: 'B9876543',
      fromCountry: 'Bangladesh',
      toCountry: 'Qatar',
      agencyTotalCost: 80000,
      paidAmount: 40000,
      isMyReturn: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReturnRequestItem> get _filteredItems {
    final filteredByType = _items.where((item) => item.isMyReturn == _isMyReturn).toList();
    final query = _searchQuery.trim().toLowerCase();
    
    return filteredByType.where((item) {
      final matchesQuery = query.isEmpty ||
          item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query);
      final createdAt = DateTime.parse(item.createdAt);
      final matchesDate = _selectedDateRange == null ||
          (!createdAt.isBefore(_selectedDateRange!.start) &&
              !createdAt.isAfter(_selectedDateRange!.end));
      return matchesQuery && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/passport-return/request-review',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breadcrumb(),
                    const SizedBox(height: 14),
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'Search by post ID, booking ID, name or passport',
                      onChanged: (value) => setState(() => _searchQuery = value),
                      onSearchTap: () =>
                          setState(() => _searchQuery = _searchController.text),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _viewToggle(),
                        const SizedBox(width: 10),
                        _typeToggle(),
                        const SizedBox(width: 10),
                        Expanded(child: _dateRangeButton()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isCardView) _buildCardList() else _buildTableList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_return_outlined, size: 14, color: AppPalette.textMuted),
              const SizedBox(width: 4),
              const Text('Passport Return List', style: TextStyle(color: AppPalette.textMuted, fontSize: 12)),
            ],
          ),
        ),
        BreadCrumbItem(
          content: const Text(
            'Return Request/Review',
            style: TextStyle(color: AppPalette.textStrongBlue, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
      divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
    );
  }

  Widget _viewToggle() {
    return ViewToggleButton(
      isCardView: _isCardView,
      onChanged: (val) => setState(() => _isCardView = val),
    );
  }

  Widget _typeToggle() {
    return Container(
      width: 110,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFE9EDFF), borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: !_isMyReturn ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 50,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMyReturn = false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Tooltip(
                      message: 'Customer Return',
                      child: Icon(
                        Icons.groups_outlined,
                        size: 22,
                        color: !_isMyReturn ? const Color(0xFF004AC6) : const Color(0xFF434655),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMyReturn = true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Tooltip(
                      message: 'My Return',
                      child: Icon(
                        Icons.person_outline,
                        size: 22,
                        color: _isMyReturn ? const Color(0xFF004AC6) : const Color(0xFF434655),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateRangeButton() {
    final label = _selectedDateRange == null
        ? 'Select Date Range'
        : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}';
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(now.year + 3, 12, 31),
                  initialDateRange: _selectedDateRange,
                );
                if (picked != null) setState(() => _selectedDateRange = picked);
              },
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 18, color: AppPalette.textStrongBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedDateRange != null)
            InkWell(
              onTap: () => setState(() => _selectedDateRange = null),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: AppPalette.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableList() => StyledDataTableCard(
    dataRowMaxHeight: 70,
    columnSpacing: 20,
    columns: const [
      DataColumn(label: Text('Post ID')),
      DataColumn(label: Text('Booking ID')),
      DataColumn(label: Text('Apply Date')),
      DataColumn(label: Text('Customer Name')),
      DataColumn(label: Text('Passport No')),
      DataColumn(label: Text('From')),
      DataColumn(label: Text('To')),
      DataColumn(label: Text('Total Cost')),
      DataColumn(label: Text('Paid Amount')),
      DataColumn(label: Text('Actions')),
    ],
    rows: _filteredItems.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item.workPermitId)),
          DataCell(Text(item.id.toString())),
          DataCell(Text(_displayDate(item.createdAt))),
          DataCell(Text(item.name)),
          DataCell(Text(item.passportNo)),
          DataCell(Text(item.fromCountry)),
          DataCell(Text(item.toCountry)),
          DataCell(Text('৳ ${_money(item.agencyTotalCost)}')),
          DataCell(Text('৳ ${_money(item.paidAmount)}')),
          DataCell(
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppPalette.textMuted),
              onPressed: () => _openActionsSheet(context, item),
            ),
          ),
        ],
      );
    }).toList(),
  );

  Widget _buildCardList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ..._filteredItems.map((item) {
        return ReturnRequestCard(
          bookingId: item.id.toString(),
          postId: item.workPermitId,
          customerInitials: item.name.length > 1 ? item.name.substring(0, 2).toUpperCase() : item.name.toUpperCase(),
          customerName: item.name,
          passportNo: item.passportNo,
          applyDate: _displayDate(item.createdAt),
          fromCountry: item.fromCountry,
          toCountry: item.toCountry,
          totalCostText: '৳ ${_money(item.agencyTotalCost)}',
          paidAmountText: '৳ ${_money(item.paidAmount)}',
          onReasonTap: () => _openActionsSheet(context, item),
          onDocsTap: () => _openActionsSheet(context, item),
          onAcceptTap: () => _openActionsSheet(context, item),
        );
      }),
      if (_filteredItems.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No return requests found.'),
          ),
        ),
    ],
  );

  String _displayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[int.parse(parts[1]) - 1]} ${parts[2]}, ${parts[0]}';
  }

  String _money(int amount) {
    final s = amount.toString();
    final chars = s.split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < chars.length; i += 3) {
      chunks.add(chars.skip(i).take(3).join());
    }
    return chunks.map((c) => c.split('').reversed.join()).toList().reversed.join(',');
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  void _openActionsSheet(BuildContext context, ReturnRequestItem item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actions • Return Request',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('See Reason'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('View Documents'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Accept Return Passport'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReturnRequestItem {
  const ReturnRequestItem({
    required this.workPermitId,
    required this.id,
    required this.createdAt,
    required this.name,
    required this.passportNo,
    required this.fromCountry,
    required this.toCountry,
    required this.agencyTotalCost,
    required this.paidAmount,
    required this.isMyReturn,
  });

  final String workPermitId;
  final int id;
  final String createdAt;
  final String name;
  final String passportNo;
  final String fromCountry;
  final String toCountry;
  final int agencyTotalCost;
  final int paidAmount;
  final bool isMyReturn;
}
