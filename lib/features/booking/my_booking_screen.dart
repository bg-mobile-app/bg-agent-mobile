import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../home/dashboard_screen.dart';
import 'services/booking_service.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({
    super.key,
    this.currentHref = '/dashboard/booking/my',
    this.breadcrumbCurrent = 'All Booking',
    this.pageTitle = 'All Booking',
    this.initialStatus = '',
    this.availableStatuses = _allStatuses,
  });

  final String currentHref;
  final String breadcrumbCurrent;
  final String pageTitle;
  final String initialStatus;
  final List<String> availableStatuses;

  static const List<String> _allStatuses = [
    '',
    'APPLIED_FILE',
    'BG_COLLECT_PP',
    'BG_SENT_PP',
    'A_RECEIVE_PP',
    'UNDER_PROCESSING',
    'VISA_APPROVED',
    'BMET_DONE',
    'TICKET_DONE',
    'PP_SENT_TO_BG',
    'BG_RECEIVED_PP',
    'READY_FOR_FLIGHT',
    'SUCCESS_FLIGHT',
    'RETURN_REQUEST',
    'RETURN_ACCEPTED',
    'RETURN_PP_SENT_TO_BG',
    'BG_COLLECT_RETURN_PP',
    'CLEAR_FOR_HANDOVER',
    'BG_HANDOVER_PP_TO_CUSTOMER',
    'REJECT_FILE',
  ];

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final BookingService _bookingService = BookingService();
  bool _isCardView = false;
  bool _isLoading = false;
  String? _error;
  String _search = '';
  DateTimeRange? _dateRange;
  late String _status;
  late final TextEditingController _searchController;
  List<_BookingItem> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _searchController = TextEditingController();
    _loadBookings();
  }

  @override
  void didUpdateWidget(covariant MyBookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentHref != widget.currentHref || oldWidget.initialStatus != widget.initialStatus) {
      _status = widget.initialStatus;
      _searchController.clear();
      _search = '';
      _dateRange = null;
      _loadBookings();
    }
  }

  List<_BookingItem> get _filtered => _bookings.where((item) {
        final q = _search.trim().toLowerCase();
        final matchesQuery = q.isEmpty ||
            item.postId.toLowerCase().contains(q) ||
            item.bookingId.toString().contains(q) ||
            item.serviceType.toLowerCase().contains(q) ||
            item.customerInfo.toLowerCase().contains(q) ||
            item.statusLabel.toLowerCase().contains(q);
        final createdAt = DateTime.tryParse(item.date);
        final matchesDate = _dateRange == null ||
            (createdAt != null &&
                !createdAt.isBefore(_dateRange!.start) &&
                !createdAt.isAfter(_dateRange!.end.add(const Duration(days: 1))));
        return matchesQuery && matchesDate;
      }).toList();

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _bookingService.getMyBookings(
        status: _status,
        search: _search,
        page: 1,
        fromDate: _dateRange == null ? null : _apiDate(_dateRange!.start),
        toDate: _dateRange == null ? null : _apiDate(_dateRange!.end),
      );
      if (!mounted) return;
      setState(() => _bookings = response.results.map(_BookingItem.fromDto).toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load bookings. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _isLoading && _bookings.isEmpty ? List.generate(6, (i) => _BookingItem.skeleton(i, _status)) : _filtered;
    return DashboardPageScaffold(
      currentHref: widget.currentHref,
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BreadCrumb(items: [
                BreadCrumbItem(content: const Text('Recruitment Portal', style: TextStyle(color: AppPalette.textMuted, fontSize: 12))),
                BreadCrumbItem(content: Text(widget.breadcrumbCurrent, style: const TextStyle(color: AppPalette.textStrongBlue, fontSize: 12, fontWeight: FontWeight.w700))),
              ], divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8))),
              const SizedBox(height: 8),
              Text(widget.pageTitle, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppPalette.textPrimary)),
              const SizedBox(height: 14),
              AppSearchBar(controller: _searchController, hintText: 'Search by booking ID, name, passport or status', onChanged: (v)=>setState(()=>_search=v), onSearchTap: _loadBookings),
              const SizedBox(height: 14),
              Row(children: [
                ViewToggleButton(isCardView: _isCardView, onChanged: (v)=>setState(()=>_isCardView=v)),
                const SizedBox(width: 10),
                Expanded(child: _dateBtn()),
              ]),
              const SizedBox(height: 14),
              _statusDropdown(),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)) else Skeletonizer(enabled: _isLoading, child: _isCardView ? _card(items) : _table(items)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD8E3FA)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: _status,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppPalette.textMuted,
        ),
        style: const TextStyle(
          color: AppPalette.textStrongBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        items: widget.availableStatuses
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s.isEmpty ? 'All Status' : s.replaceAll('_', ' ')),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _status = v);
          _loadBookings();
        },
      ),
    ),
  );

  Widget _dateBtn() {
    final label = _dateRange == null
        ? 'Select Date Range'
        : '${_apiDate(_dateRange!.start)} - ${_apiDate(_dateRange!.end)}';
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
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 3, 12, 31),
                initialDateRange: _dateRange,
              );
              if (picked == null) return;
              setState(() => _dateRange = picked);
              _loadBookings();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: AppPalette.textStrongBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppPalette.textStrongBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_dateRange != null)
            InkWell(
              onTap: () {
                setState(() => _dateRange = null);
                _loadBookings();
              },
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

  Widget _table(List<_BookingItem> items) => StyledDataTableCard(columns: const [
    DataColumn(label: Text('Post ID')), DataColumn(label: Text('Booking ID')), DataColumn(label: Text('Service Type')), DataColumn(label: Text('Date')), DataColumn(label: Text('Customer Info')), DataColumn(label: Text('Package Price')), DataColumn(label: Text('Paid Amount')), DataColumn(label: Text('Status')), DataColumn(label: Text('Actions')),
  ], rows: items.map((e)=>DataRow(cells: [
    DataCell(Text(e.postId)), DataCell(Text(e.bookingId.toString())), DataCell(Text(e.serviceType)), DataCell(Text(e.date.split('T').first)), DataCell(Text(e.customerInfo)), DataCell(Text('৳ ${e.packagePrice}')), DataCell(Text('৳ ${e.paidAmount}')), DataCell(Text(e.statusLabel)), const DataCell(Icon(Icons.more_horiz)),
  ])).toList());

  Widget _card(List<_BookingItem> items) => Column(children: items.map((e)=>Card(child: ListTile(
    title: Text('${e.postId} • ${e.bookingId}'), subtitle: Text('${e.serviceType}\n${e.customerInfo}\nPackage: ৳ ${e.packagePrice} | Paid: ৳ ${e.paidAmount}\nStatus: ${e.statusLabel}'), isThreeLine: true, trailing: const Icon(Icons.more_vert),
  ))).toList());

  String _apiDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
}

class _BookingItem {
  const _BookingItem({required this.postId, required this.bookingId, required this.serviceType, required this.date, required this.customerInfo, required this.packagePrice, required this.paidAmount, required this.statusLabel});
  final String postId; final int bookingId; final String serviceType; final String date; final String customerInfo; final int packagePrice; final int paidAmount; final String statusLabel;
  factory _BookingItem.fromDto(ReceiveBookingItemDto dto) => _BookingItem(postId: dto.workPermitId, bookingId: dto.id, serviceType: dto.serviceType, date: dto.createdAt, customerInfo: '${dto.name} (${dto.passportNo ?? '-'})', packagePrice: dto.agencyTotalCost ?? 0, paidAmount: dto.paidAmount ?? 0, statusLabel: dto.statusLabel);
  factory _BookingItem.skeleton(int i, String status) => _BookingItem(postId: 'WP-XXXX', bookingId: 1000+i, serviceType: 'Work Permit', date: '2026-01-01', customerInfo: 'Loading (P000)', packagePrice: 0, paidAmount: 0, statusLabel: status.isEmpty ? 'Loading' : status);
}
