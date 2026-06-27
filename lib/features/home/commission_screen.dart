import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/widgets/styled_data_table_card.dart';
import 'dashboard_screen.dart';
import 'services/commission_service.dart';
import '../../common/services/api_client.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _debouncedSearch = '';
  DateTimeRange? _selectedDateRange;
  bool _cardView = true;

  final CommissionService _commissionService = CommissionService();
  bool _isInitialLoading = true;
  String? _error;
  List<WPMyBookingGETProps> _commissions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCommissions(isInitial: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      if (_debouncedSearch != query) {
        setState(() {
          _debouncedSearch = query;
        });
        _loadCommissions(isInitial: true);
      }
    });
  }

  Future<void> _loadCommissions({bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      String? fromDateStr = _selectedDateRange == null
          ? null
          : '${_selectedDateRange!.start.year}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}';
      String? toDateStr = _selectedDateRange == null
          ? null
          : '${_selectedDateRange!.end.year}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}';

      final response = await _commissionService.getCommissions(
        search: _debouncedSearch,
        fromDate: fromDateStr,
        toDate: toDateStr,
        page: _currentPage,
      );

      if (!mounted) return;

      final ps = response.pageSize > 0 ? response.pageSize : 10;
      setState(() {
        _commissions = response.results;
        _totalCount = response.count;
        _totalPages = (response.count / ps).ceil();
        if (_totalPages < 1) _totalPages = 1;
        _error = null;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load commissions. Please try again.';
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPalette.brandBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadCommissions(isInitial: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _isInitialLoading
        ? _skeletonCommissions
        : _commissions;

    return DashboardPageScaffold(
      currentHref: '/dashboard/commission',
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
                  'Commission List',
                  style: AppTextStyles.headline2.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isInitialLoading
                      ? 'Loading your commission details...'
                      : 'Showing $_totalCount commission record(s)',
                  style: AppTextStyles.body2.copyWith(
                    color: AppPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                _topControls(),
                const SizedBox(height: 12),
                _searchBox(),
                const SizedBox(height: 16),
                if (_error != null)
                  _errorState()
                else
                  Skeletonizer(
                    enabled: _isInitialLoading,
                    child: _cardView
                        ? _cardContent(displayItems)
                        : _tableContent(displayItems),
                  ),
                const SizedBox(height: 16),
                if (!_isInitialLoading && _error == null)
                  Skeletonizer(
                    enabled: _isInitialLoading,
                    child: _statsSection(displayItems),
                  ),
                if (_totalPages > 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _loadCommissions();
                              }
                            : null,
                      ),
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() => _currentPage++);
                                _loadCommissions();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
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
            'Dashboard',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Commission',
            style: AppTextStyles.caption.copyWith(
              color: AppPalette.textStrongBlue,
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

  Widget _topControls() {
    return Row(
      children: [
        ViewToggleButton(
          isCardView: _cardView,
          onChanged: (value) => setState(() => _cardView = value),
        ),
        const SizedBox(width: 12),
        Expanded(child: _dateRangeButton()),
      ],
    );
  }

  Widget _dateRangeButton() {
    final label = _selectedDateRange == null
        ? 'Filter by Date Range'
        : '${_formatListDate(_selectedDateRange!.start)} - ${_formatListDate(_selectedDateRange!.end)}';

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.borderSoftBlue),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2563EB),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _pickDateRange,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppPalette.brandBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _selectedDateRange == null
                          ? AppPalette.textMuted
                          : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedDateRange != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                      _loadCommissions(isInitial: true);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppPalette.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return AppSearchBar(
      controller: _searchController,
      hintText: 'Search by Name, Passport or WP ID...',
      onChanged: (value) {},
      onSearchTap: () {
        _debounce?.cancel();
        final query = _searchController.text.trim();
        if (_debouncedSearch != query) {
          setState(() {
            _debouncedSearch = query;
          });
          _loadCommissions(isInitial: true);
        }
      },
    );
  }

  Widget _tableContent(List<WPMyBookingGETProps> items) {
    if (items.isEmpty) return _emptyState();
    return StyledDataTableCard(
      columns: const [
        DataColumn(label: Text('Post ID')),
        DataColumn(label: Text('Booking ID')),
        DataColumn(label: Text('From / To / Service')),
        DataColumn(label: Text('Apply Date & Status')),
        DataColumn(label: Text('Customer Info')),
        DataColumn(label: Text('Package Price')),
        DataColumn(label: Text('Paid Amount')),
        DataColumn(label: Text('Commission')),
      ],
      rows: items
          .map(
            (item) => DataRow(
              cells: [
                DataCell(
                  Text(
                    item.workPermitId,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DataCell(Text(item.id.toString())),
                DataCell(
                  Text(
                    '${item.fromCountry} → ${item.toCountry}\n${item.serviceType}',
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_formatListDate(item.createdAt),
                          style: const TextStyle(fontSize: 12)),
                      _statusChip(item.statusLabel),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name),
                      Text(item.passportNo,
                          style: const TextStyle(
                              fontSize: 11, color: AppPalette.textMuted)),
                    ],
                  ),
                ),
                DataCell(Text('৳ ${_money(item.customerTotal)}')),
                DataCell(Text('৳ ${_money(item.paidAmount)}')),
                DataCell(
                  Text(
                    '৳ ${_money(item.commission)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _cardContent(List<WPMyBookingGETProps> items) {
    if (items.isEmpty) {
      return _emptyState();
    }

    return Column(children: items.map(_commissionCard).toList());
  }

  Widget _commissionCard(WPMyBookingGETProps item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBC1D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: AppPalette.brandBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.workPermitId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191B24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.fromCountry} ➔ ${item.toCountry}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF434655),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusChip(item.statusLabel),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _detailTile(
                        'CANDIDATE NAME',
                        item.name,
                        Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _detailTile(
                        'PASSPORT NO',
                        item.passportNo,
                        Icons.badge_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _detailTile(
                        'SERVICE TYPE',
                        item.serviceType,
                        Icons.card_membership_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _detailTile(
                        'DATE CREATED',
                        _formatListDate(item.createdAt),
                        Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFBBC1D6), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CUSTOMER BUDGET',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF737687),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${_money(item.customerTotal)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          Text(
                            'Paid: ৳ ${_money(item.paidAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F3DE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x4D1C7A3B),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COMMISSION',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C7A3B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳ ${_money(item.commission)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C7A3B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection(List<WPMyBookingGETProps> items) {
    final totalCommission = items.fold<int>(0, (sum, i) => sum + i.commission);
    final totalRevenue = items.fold<int>(0, (sum, i) => sum + i.customerTotal);
    final totalPaid = items.fold<int>(0, (sum, i) => sum + i.paidAmount);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF166534), // Rich Green
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppPalette.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL EARNED COMMISSION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '৳ ${_money(totalCommission)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderSoftBlue),
                  boxShadow: AppPalette.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL BOOKINGS',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${items.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderSoftBlue),
                  boxShadow: AppPalette.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REVENUE COLLECTED',
                      style: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '৳ ${_money(totalPaid)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.borderSoftBlue),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: AppPalette.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No commissions found',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search filters or selected date range.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: AppPalette.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 14),
          Text(
            _error ?? 'Failed to load commissions',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadCommissions(isInitial: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
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
    );
  }

  Widget _detailTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: Color(0xFF737687),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 20, color: AppPalette.brandBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color bg = const Color(0xFFD8F3DE);
    Color fg = const Color(0xFF1C7A3B);

    if (status == 'UNDER PROCESSING' || status == 'BMET DONE') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    } else if (status.contains('REJECT') || status.contains('CANCEL')) {
      bg = const Color(0xFFF8D8D7);
      fg = const Color(0xFFB3261E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  String _formatListDate(DateTime date) {
    const monthNames = [
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
    return '${date.day.toString().padLeft(2, '0')} ${monthNames[date.month - 1]}, ${date.year}';
  }

  String _money(int amount) {
    final s = amount.toString();
    final chars = s.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < chars.length; i += 3) {
      parts.add(chars.sublist(i, (i + 3).clamp(0, chars.length)).join());
    }
    return parts.join(',').split('').reversed.join();
  }
}

final List<WPMyBookingGETProps> _skeletonCommissions = [
  WPMyBookingGETProps(
    id: 101,
    workPermitId: 'WP-99210',
    workPermitSlug: 'wp-malaysia-factory-worker',
    fromCountry: 'Bangladesh',
    toCountry: 'Malaysia',
    serviceType: 'Factory Worker',
    createdAt: DateTime(2026, 2, 14, 10, 30),
    statusLabel: 'VISA APPROVED',
    name: 'Abdur Rahman',
    passportNo: 'A12345678',
    customerTotal: 350000,
    paidAmount: 200000,
    commission: 25000,
  ),
  WPMyBookingGETProps(
    id: 102,
    workPermitId: 'WP-99150',
    workPermitSlug: 'wp-romania-construction-worker',
    fromCountry: 'Bangladesh',
    toCountry: 'Romania',
    serviceType: 'Construction',
    createdAt: DateTime(2026, 2, 10, 11, 45),
    statusLabel: 'BMET DONE',
    name: 'Kamal Hossain',
    passportNo: 'B87654321',
    customerTotal: 450000,
    paidAmount: 300000,
    commission: 35000,
  ),
  WPMyBookingGETProps(
    id: 103,
    workPermitId: 'WP-99080',
    workPermitSlug: 'wp-saudi-driver',
    fromCountry: 'Bangladesh',
    toCountry: 'Saudi Arabia',
    serviceType: 'Heavy Driver',
    createdAt: DateTime(2026, 1, 28, 9, 15),
    statusLabel: 'COMPLETED',
    name: 'Mohammad Ali',
    passportNo: 'C11223344',
    customerTotal: 280000,
    paidAmount: 280000,
    commission: 20000,
  ),
];
