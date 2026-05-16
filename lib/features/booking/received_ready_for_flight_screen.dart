import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import 'widgets/received_booking_card.dart';
import '../home/dashboard_screen.dart';

class ReceivedReadyForFlightScreen extends StatefulWidget {
  const ReceivedReadyForFlightScreen({super.key});

  @override
  State<ReceivedReadyForFlightScreen> createState() =>
      _ReceivedReadyForFlightScreenState();
}

class _ReceivedReadyForFlightScreenState extends State<ReceivedReadyForFlightScreen> {
  bool _isCardView = false;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  final List<BookingItem> _bookings = const [
    BookingItem(
      workPermitId: 'HJ-3110',
      id: 4577,
      serviceType: 'Hajj Package',
      createdAt: '2026-05-03',
      name: 'Farida Begum',
      passportNo: 'L99001122',
      fromCountry: 'Bangladesh',
      toCountry: 'Saudi Arabia',
      agencyTotalCost: 245000,
      paidAmount: 245000,
      status: 'READY_FOR_FLIGHT',
      statusLabel: 'Ready for Flight',
      visaExpiryDate: '2027-02-10',
      hasBeforeFlightPayout: true,
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
    final readyForFlightOnly = _bookings
        .where((item) => item.status == 'READY_FOR_FLIGHT')
        .toList();
        
    final query = _searchQuery.trim().toLowerCase();
    
    final seeded = readyForFlightOnly.isEmpty
        ? const [
            BookingItem(
              workPermitId: 'WP-RFF-1001',
              id: 7906,
              serviceType: 'Work Permit',
              createdAt: '2026-05-01',
              name: 'Demo Applicant',
              passportNo: 'D00000006',
              fromCountry: 'Bangladesh',
              toCountry: 'Oman',
              agencyTotalCost: 95000,
              paidAmount: 50000,
              status: 'READY_FOR_FLIGHT',
              statusLabel: 'Ready for Flight',
            ),
          ]
        : readyForFlightOnly;
        
    return seeded.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query) ||
          item.statusLabel.toLowerCase().contains(query);
      final createdAt = DateTime.parse(item.createdAt);
      final matchesDate =
          _selectedDateRange == null ||
          (!createdAt.isBefore(_selectedDateRange!.start) &&
              !createdAt.isAfter(_selectedDateRange!.end));
      return matchesQuery && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/receive-booking/ready-for-flight',
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
              const Icon(
                Icons.view_list_rounded,
                size: 14,
                color: AppPalette.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Receive Booking List',
                style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Ready For Flight',
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
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 3, 12, 31),
                initialDateRange: _selectedDateRange,
              );
              if (picked == null) return;
              setState(() => _selectedDateRange = picked);
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.textStrongBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
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

  Widget _buildTableList() => StyledDataTableCard(
    dataRowMaxHeight: 86,
    columnSpacing: 20,
    columns: const [
      DataColumn(label: Text('Post ID')),
      DataColumn(label: Text('Booking ID')),
      DataColumn(label: Text('Apply Date')),
      DataColumn(label: Text('Customer Info')),
      DataColumn(label: Text('From & To')),
      DataColumn(label: Text('Total Cost')),
      DataColumn(label: Text('Medical Expiry')),
      DataColumn(label: Text('Police Expiry')),
      DataColumn(label: Text('Visa Expiry')),
      DataColumn(label: Text('Appointment')),
      DataColumn(label: Text('Status')),
    ],
    rows: _filteredBookings.map((item) {
      final style = _styleFor(item.statusLabel);
      return DataRow(
        onLongPress: () => _openActionsSheet(context, item),
        cells: [
          DataCell(Text(item.workPermitId)),
          DataCell(Text(item.id.toString())),
          DataCell(Text(_displayDate(item.createdAt))),
          DataCell(
            Text(
              '${item.name}\n${item.passportNo}',
              style: const TextStyle(height: 1.35),
            ),
          ),
          DataCell(Text('${item.fromCountry} → ${item.toCountry}')),
          DataCell(Text('৳ ${_money(item.agencyTotalCost)}')),
          DataCell(
            Text(
              item.medicalExpiryDate == null
                  ? '-'
                  : _displayDate(item.medicalExpiryDate!),
            ),
          ),
          DataCell(
            Text(
              item.policeClearanceExpiryDate == null
                  ? '-'
                  : _displayDate(item.policeClearanceExpiryDate!),
            ),
          ),
          DataCell(
            Text(
              item.visaExpiryDate == null
                  ? '-'
                  : _displayDate(item.visaExpiryDate!),
            ),
          ),
          DataCell(
            Text(
              item.appointmentDate == null
                  ? '-'
                  : _displayDate(item.appointmentDate!),
            ),
          ),
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
        ],
      );
    }).toList(),
  );

  Widget _buildCardList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ..._filteredBookings.map((item) {
        return ReceivedBookingCard(
          bookingId: item.id,
          postId: item.workPermitId,
          statusText: item.statusLabel,
          name: item.name,
          passportNo: item.passportNo,
          createdAtText: _displayDate(item.createdAt),
          fromCountry: item.fromCountry,
          toCountry: item.toCountry,
          medicalText: item.medicalExpiryDate == null ? '22/08/2026' : _displayDate(item.medicalExpiryDate!),
          visaText: item.visaExpiryDate == null ? '22/08/2026' : _displayDate(item.visaExpiryDate!),
          policeClearText: item.policeClearanceExpiryDate == null ? '22/08/2026' : _displayDate(item.policeClearanceExpiryDate!),
          totalCostText: '৳ ${_money(item.agencyTotalCost)}',
          hasAdvancePayout: item.hasAdvancePayout,
          hasAfterVisaPayout: item.hasAfterVisaPayout,
          hasBeforeFlightPayout: item.hasBeforeFlightPayout,
          style: _styleFor(item.statusLabel),
          onMoreTap: () => _openActionsSheet(context, item),
        );
      }),
    ],
  );

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

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  ReceivedBookingCardStyle _styleFor(String status) {
    switch (status) {
      case 'Ready for Flight':
      case 'READY_FOR_FLIGHT':
        return const ReceivedBookingCardStyle(
          badgeBg: AppPalette.successBg,
          badgeText: AppPalette.success,
          ctaLabel: 'View Details',
        );
      default:
        return const ReceivedBookingCardStyle(
          badgeBg: Color(0xFFDBEAFE),
          badgeText: Color(0xFF1D4ED8),
          ctaLabel: 'View Details',
        );
    }
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
