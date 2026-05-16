import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import '../home/dashboard_screen.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({
    super.key,
    this.currentHref = '/dashboard/booking/my',
    this.breadcrumbParent = 'Recruitment Portal',
    this.breadcrumbCurrent = 'All Booking',
  });

  final String currentHref;
  final String breadcrumbParent;
  final String breadcrumbCurrent;

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool _isCardView = false;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedStatus;

  final List<BookingItem> _bookings = const [
    BookingItem(
      workPermitId: 'WP-1201',
      id: 4571,
      serviceType: 'Work Permit',
      createdAt: '2026-04-12',
      name: 'Rakib Hasan',
      passportNo: 'B12345678',
      fromCountry: 'Bangladesh',
      toCountry: 'Romania',
      agencyTotalCost: 85000,
      paidAmount: 40000,
      status: 'APPLIED_FILE',
      statusLabel: 'Applied File',
    ),
    BookingItem(
      workPermitId: 'ST-2003',
      id: 4572,
      serviceType: 'Student Visa',
      createdAt: '2026-04-18',
      name: 'Nusrat Jahan',
      passportNo: 'A98765432',
      fromCountry: 'Bangladesh',
      toCountry: 'Canada',
      agencyTotalCost: 120000,
      paidAmount: 120000,
      status: 'VISA_APPROVED',
      statusLabel: 'Visa Approved',
      visaExpiryDate: '2027-03-28',
      paymentStepCount: 3,
      hasAfterVisaPayout: false,
    ),
    BookingItem(
      workPermitId: 'HJ-3098',
      id: 4573,
      serviceType: 'Hajj Package',
      createdAt: '2026-04-22',
      name: 'Abdul Karim',
      passportNo: 'E44112233',
      fromCountry: 'Bangladesh',
      toCountry: 'Saudi Arabia',
      agencyTotalCost: 230000,
      paidAmount: 80000,
      status: 'UNDER_PROCESSING',
      statusLabel: 'Under Processing',
      medicalExpiryDate: '2026-12-22',
      policeClearanceExpiryDate: '2026-11-11',
      isReturn: true,
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

  List<BookingItem> get _filteredBookings {
    final query = _searchQuery.trim().toLowerCase();
    return _bookings.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query) ||
          item.statusLabel.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == null || item.statusLabel == _selectedStatus;

      final createdAt = DateTime.tryParse(item.createdAt);
      final matchesDate =
          _selectedDateRange == null ||
          createdAt == null ||
          (!createdAt.isBefore(_selectedDateRange!.start) &&
              !createdAt.isAfter(
                _selectedDateRange!.end.add(const Duration(days: 1)),
              ));

      return matchesQuery && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: widget.currentHref,
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(),
                const SizedBox(height: 8),
                Text(
                  'All Booking',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search by booking ID, name, passport or status',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSearchTap: () =>
                      setState(() => _searchQuery = _searchController.text),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _viewToggle(),
                    const SizedBox(width: 10),
                    Expanded(child: _dateRangeButton()),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _statusFilter()),
                    const SizedBox(width: 10),
                    _statButton(),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isCardView) _buildCardList() else _buildTableList(),
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
        BreadCrumbItem(
          content: Text(
            'Recruitment Portal',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'All Booking',
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

  Widget _viewToggle() {
    return ViewToggleButton(
      isCardView: _isCardView,
      onChanged: (isCardView) => setState(() => _isCardView = isCardView),
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
                  const Icon(
                    Icons.date_range_rounded,
                    size: 18,
                    color: AppPalette.textStrongBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPalette.textStrongBlue,
                        fontWeight: FontWeight.w600,
                      ),
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
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppPalette.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  Widget _statusFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Filter by Status'),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppPalette.textStrongBlue,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('All Statuses')),
            DropdownMenuItem(
              value: 'Applied File',
              child: Text('Applied File'),
            ),
            DropdownMenuItem(
              value: 'Visa Approved',
              child: Text('Visa Approved'),
            ),
            DropdownMenuItem(
              value: 'Under Processing',
              child: Text('Under Processing'),
            ),
            DropdownMenuItem(
              value: 'Return Passport',
              child: Text('Return Passport'),
            ),
          ],
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
      ),
    );
  }

  Widget _statButton() {
    return InkWell(
      onTap: () => _showStatDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppPalette.brandBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'View Stats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showStatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Booking Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildStatCard(
                          icon: Icons.pending_actions,
                          iconBg: const Color(0xFFE8F0FF),
                          iconColor: AppPalette.brandBlue,
                          title: 'Total Pending',
                          value: '128 Bookings',
                        ),
                        _buildStatCard(
                          icon: Icons.flight_takeoff,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF15803D),
                          title: 'Flights This Month',
                          value: '42 Travelers',
                        ),
                        _buildStatCard(
                          icon: Icons.payments,
                          iconBg: const Color(0xFFF3E8FF),
                          iconColor: const Color(0xFF7E22CE),
                          title: 'Collected Revenue',
                          value: '৳ 12,45,000',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FAFC,
        ), // slightly off-white for surface-container-low
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.borderNeutral.withOpacity(0.5)),
        boxShadow: AppPalette.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: const [
        _StatCard(
          title: 'TOTAL BOOKINGS',
          value: '12',
          icon: Icons.inventory_2_outlined,
        ),
        _StatCard(
          title: 'ACTIVE FILES',
          value: '08',
          icon: Icons.work_history_outlined,
        ),
        _StatCard(
          title: 'SUCCESS RATE',
          value: '94%',
          icon: Icons.trending_up_rounded,
        ),
        _StatCard(
          title: 'PENDING DUES',
          value: '৳ 235k',
          icon: Icons.account_balance_wallet_outlined,
          error: true,
        ),
      ],
    );
  }

  Widget _buildTableList() => StyledDataTableCard(
    dataRowMaxHeight: 86,
    columnSpacing: 20,
    columns: const [
      DataColumn(label: Text('Post ID')),
      DataColumn(label: Text('Booking ID')),
      DataColumn(label: Text('Service Type')),
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Customer Info')),
      DataColumn(label: Text('Package Price')),
      DataColumn(label: Text('Paid Amount')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Actions')),
    ],
    rows: _filteredBookings.map((item) {
      final style = _styleFor(item.statusLabel);
      return DataRow(
        onLongPress: () => _openActionsSheet(context, item),
        cells: [
          DataCell(Text(item.workPermitId)),
          DataCell(Text(item.id.toString())),
          DataCell(Text(item.serviceType)),
          DataCell(Text(_displayDate(item.createdAt))),
          DataCell(
            Text(
              '${item.name}\n${item.passportNo}',
              style: const TextStyle(height: 1.35),
            ),
          ),
          DataCell(Text('৳ ${_money(item.agencyTotalCost)}')),
          DataCell(Text('৳ ${_money(item.paidAmount)}')),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: style.badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.statusLabel,
                style: TextStyle(
                  color: style.badgeText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppPalette.textMuted,
              ),
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
      ..._filteredBookings.map((item) {
        final style = _styleFor(item.statusLabel);
        final dueAmount = item.agencyTotalCost - item.paidAmount;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppPalette.borderSoftBlue),
            boxShadow: AppPalette.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.workPermitId,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppPalette.brandBlue,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: AppPalette.borderNeutral,
                                ),
                              ),
                            ),
                            Text(
                              'B-${item.id}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppPalette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: style.badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.statusLabel.toUpperCase(),
                            style: TextStyle(
                              color: style.badgeText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppPalette.textMuted,
                    ),
                    onPressed: () => _openActionsSheet(context, item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppPalette.brandBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: AppPalette.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Passport: ${item.passportNo}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppPalette.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppPalette.borderSoftBlue),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SERVICE TYPE',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.serviceType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CREATION DATE',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayDate(item.createdAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Package Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳ ${_money(item.agencyTotalCost)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.brandBlue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Paid Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳ ${_money(item.paidAmount)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text(
                        'View Documents',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.brandBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.danger,
                      side: const BorderSide(color: AppPalette.danger),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ],
  );

  Widget _detailTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: Color(0xFF737687),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 22, color: AppPalette.brandBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amountRow(String label, String value, Color color, bool bold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xFF434655)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 19,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _displayDate(String iso) {
    final parts = iso.split('-');
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
    return '${months[int.parse(parts[1]) - 1]} ${parts[2]}, ${parts[0]}';
  }

  String _money(int amount) {
    final s = amount.toString();
    final chars = s.split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < chars.length; i += 3) {
      chunks.add(chars.skip(i).take(3).join());
    }
    return chunks
        .map((c) => c.split('').reversed.join())
        .toList()
        .reversed
        .join(',');
  }

  _CardStyle _styleFor(String status) {
    switch (status) {
      case 'Success Flight':
        return const _CardStyle(
          icon: Icons.school_outlined,
          iconBg: Color(0xFFCCF3D9),
          iconColor: AppPalette.success,
          badgeBg: AppPalette.successBg,
          badgeText: AppPalette.success,
          progressBg: Color(0xFFEAF8EE),
          progressTrack: Color(0xFFBBF7D0),
          progressColor: Color(0xFF16A34A),
          progressText: AppPalette.success,
          progressLabel: 'Payment Completed',
          ctaLabel: 'View Receipt',
          ctaIcon: Icons.receipt_long,
        );
      case 'Under Processing':
        return const _CardStyle(
          icon: Icons.mosque_outlined,
          iconBg: AppPalette.warningBg,
          iconColor: AppPalette.warning,
          badgeBg: AppPalette.warningBg,
          badgeText: AppPalette.warning,
          progressBg: Color(0xFFF3F4F6),
          progressTrack: Color(0xFFE5E7EB),
          progressColor: Color(0xFFF59E0B),
          progressText: AppPalette.textPrimary,
          progressLabel: 'Payment Progress',
          ctaLabel: 'View Details',
          ctaIcon: Icons.arrow_forward,
        );
      default:
        return const _CardStyle(
          icon: Icons.work_outline,
          iconBg: Color(0xFFDBEAFE),
          iconColor: Color(0xFF1D4ED8),
          badgeBg: Color(0xFFDBEAFE),
          badgeText: Color(0xFF1D4ED8),
          progressBg: Color(0xFFF3F4F6),
          progressTrack: Color(0xFFE5E7EB),
          progressColor: AppPalette.textStrongBlue,
          progressText: AppPalette.textPrimary,
          progressLabel: 'Payment Progress',
          ctaLabel: 'View Details',
          ctaIcon: Icons.arrow_forward,
        );
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.error = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderSoftBlue),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppPalette.textMuted,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              color: error ? AppPalette.danger : AppPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStyle {
  const _CardStyle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeText,
    required this.progressBg,
    required this.progressTrack,
    required this.progressColor,
    required this.progressText,
    required this.progressLabel,
    required this.ctaLabel,
    required this.ctaIcon,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeText;
  final Color progressBg;
  final Color progressTrack;
  final Color progressColor;
  final Color progressText;
  final String progressLabel;
  final String ctaLabel;
  final IconData ctaIcon;
}

class BookingItem {
  const BookingItem({
    required this.workPermitId,
    required this.id,
    required this.serviceType,
    required this.createdAt,
    required this.name,
    required this.passportNo,
    required this.fromCountry,
    required this.toCountry,
    required this.agencyTotalCost,
    required this.paidAmount,
    required this.status,
    required this.statusLabel,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
    this.appointmentDate,
    this.isReturn = false,
    this.paymentStepCount = 0,
    this.hasAdvancePayout = false,
    this.hasAfterVisaPayout = false,
    this.hasBeforeFlightPayout = false,
  });

  final String workPermitId;
  final int id;
  final String serviceType;
  final String createdAt;
  final String name;
  final String passportNo;
  final String fromCountry;
  final String toCountry;
  final int agencyTotalCost;
  final int paidAmount;
  final String status;
  final String statusLabel;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;
  final String? appointmentDate;
  final bool isReturn;
  final int paymentStepCount;
  final bool hasAdvancePayout;
  final bool hasAfterVisaPayout;
  final bool hasBeforeFlightPayout;
}

List<String> _actionsFor(BookingItem row) {
  if (row.isReturn) return const ['File in Return'];
  final actions =
      <String, List<String>>{
        'APPLIED_FILE': ['View Post', 'Reject'],
        'BG_COLLECT_PP': [],
        'BG_SENT_PP': ['Receive Passport'],
        'A_RECEIVE_PP': [
          'Sent to Processing',
          'Payment Request',
          'Add Reminder',
          'View Documents',
          'Reject',
        ],
        'UNDER_PROCESSING': [
          'Visa Approved',
          'Upload Documents',
          'Add Reminder',
          'Visa Reminder',
          'View Documents',
          'Reject',
        ],
        'VISA_APPROVED': [
          'BMET Done',
          'Upload Documents',
          'Payment Request',
          'View Documents',
          'Reject',
        ],
        'BMET_DONE': [
          'Ticket Done',
          'Upload Documents',
          'View Documents',
          'Reject',
        ],
        'TICKET_DONE': [
          'Payment Request',
          'PP Send to BG',
          'Upload Documents',
          'View Documents',
          'Reject',
        ],
        'PP_SENT_TO_BG': ['View Documents'],
        'BG_RECEIVED_PP': ['View Documents'],
        'READY_FOR_FLIGHT': ['View Documents'],
        'SUCCESS_FLIGHT': ['View Documents'],
        'RETURN_PP_SENT_TO_BG': ['View Documents'],
        'BG_COLLECT_RETURN_PP': ['View Documents'],
        'BG_HANDOVER_PP_TO_CUSTOMER': ['View Documents'],
        'REJECT_FILE': [],
      }[row.status] ??
      <String>[];
  return actions.where((action) {
    if (action == 'Sent to Processing' && row.status == 'A_RECEIVE_PP') {
      if (row.paymentStepCount == 3 && !row.hasAdvancePayout) return false;
    }
    if (action == 'BMET Done' &&
        row.status == 'VISA_APPROVED' &&
        !row.hasAfterVisaPayout)
      return false;
    if (action == 'Payment Request') {
      if (row.status == 'A_RECEIVE_PP' &&
          (row.paymentStepCount != 3 || row.hasAdvancePayout))
        return false;
      if (row.status == 'VISA_APPROVED' && row.hasAfterVisaPayout) return false;
      if (row.status == 'TICKET_DONE' && row.hasBeforeFlightPayout)
        return false;
    }
    if (action == 'PP Send to BG' &&
        row.status == 'TICKET_DONE' &&
        !row.hasBeforeFlightPayout)
      return false;
    return true;
  }).toList();
}

void _openActionsSheet(BuildContext context, BookingItem row) {
  final actions = _actionsFor(row);
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions • ${row.statusLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (actions.isEmpty)
              const Text('No actions available')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions
                    .map(
                      (action) => OutlinedButton(
                        onPressed: row.isReturn
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(action),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    ),
  );
}
