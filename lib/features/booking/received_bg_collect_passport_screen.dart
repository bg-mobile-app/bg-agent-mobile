import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import '../../common/services/api_client.dart';
import 'widgets/received_booking_card.dart';
import '../home/dashboard_screen.dart';

class ReceivedBgCollectPassportScreen extends StatefulWidget {
  const ReceivedBgCollectPassportScreen({super.key});

  @override
  State<ReceivedBgCollectPassportScreen> createState() =>
      _ReceivedBgCollectPassportScreenState();
}

class _ReceivedBgCollectPassportScreenState
    extends State<ReceivedBgCollectPassportScreen> {
  bool _isCardView = false;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  List<BookingItem> _collectedBookings = const [];
  Timer? _searchDebounce;

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
    BookingItem(
      workPermitId: 'WP-1204',
      id: 4574,
      serviceType: 'Work Permit',
      createdAt: '2026-04-25',
      name: 'Sadia Akter',
      passportNo: 'B66778899',
      fromCountry: 'Bangladesh',
      toCountry: 'Italy',
      agencyTotalCost: 98000,
      paidAmount: 50000,
      status: 'A_RECEIVE_PP',
      statusLabel: 'Passport Received',
      medicalExpiryDate: '2026-10-30',
      paymentStepCount: 3,
      hasAdvancePayout: false,
    ),
    BookingItem(
      workPermitId: 'WP-1208',
      id: 4575,
      serviceType: 'Work Permit',
      createdAt: '2026-04-28',
      name: 'Mehedi Rahman',
      passportNo: 'K11223344',
      fromCountry: 'Bangladesh',
      toCountry: 'Poland',
      agencyTotalCost: 91000,
      paidAmount: 91000,
      status: 'BMET_DONE',
      statusLabel: 'BMET Done',
      medicalExpiryDate: '2026-12-19',
      policeClearanceExpiryDate: '2026-11-05',
      visaExpiryDate: '2027-01-15',
      hasAfterVisaPayout: true,
    ),
    BookingItem(
      workPermitId: 'ST-2011',
      id: 4576,
      serviceType: 'Student Visa',
      createdAt: '2026-05-01',
      name: 'Tahmid Chowdhury',
      passportNo: 'P55667788',
      fromCountry: 'Bangladesh',
      toCountry: 'Australia',
      agencyTotalCost: 165000,
      paidAmount: 120000,
      status: 'UNDER_PROCESSING',
      statusLabel: 'Under Processing',
      appointmentDate: '2026-06-12',
      medicalExpiryDate: '2026-11-22',
      policeClearanceExpiryDate: '2026-10-18',
    ),
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
      status: 'SUCCESS_FLIGHT',
      statusLabel: 'Success Flight',
      visaExpiryDate: '2027-02-10',
      hasBeforeFlightPayout: true,
    ),
    BookingItem(
      workPermitId: 'WP-1216',
      id: 4578,
      serviceType: 'Work Permit',
      createdAt: '2026-05-05',
      name: 'Shuvo Sarker',
      passportNo: 'M30313233',
      fromCountry: 'Bangladesh',
      toCountry: 'Greece',
      agencyTotalCost: 102000,
      paidAmount: 70000,
      status: 'TICKET_DONE',
      statusLabel: 'Ticket Done',
      appointmentDate: '2026-05-27',
      visaExpiryDate: '2026-12-31',
      hasBeforeFlightPayout: false,
    ),
    BookingItem(
      workPermitId: 'ST-2020',
      id: 4579,
      serviceType: 'Student Visa',
      createdAt: '2026-05-07',
      name: 'Nabila Islam',
      passportNo: 'Q77889900',
      fromCountry: 'Bangladesh',
      toCountry: 'United Kingdom',
      agencyTotalCost: 175000,
      paidAmount: 85000,
      status: 'APPLIED_FILE',
      statusLabel: 'Applied File',
      appointmentDate: '2026-06-20',
    ),
    BookingItem(
      workPermitId: 'WP-1222',
      id: 4580,
      serviceType: 'Work Permit',
      createdAt: '2026-05-09',
      name: 'Rafiul Alam',
      passportNo: 'S12121212',
      fromCountry: 'Bangladesh',
      toCountry: 'Portugal',
      agencyTotalCost: 108000,
      paidAmount: 108000,
      status: 'VISA_APPROVED',
      statusLabel: 'Visa Approved',
      visaExpiryDate: '2027-04-01',
      paymentStepCount: 3,
      hasAfterVisaPayout: false,
    ),
    BookingItem(
      workPermitId: 'WP-1229',
      id: 4581,
      serviceType: 'Work Permit',
      createdAt: '2026-05-11',
      name: 'Jahidul Islam',
      passportNo: 'T45454545',
      fromCountry: 'Bangladesh',
      toCountry: 'Croatia',
      agencyTotalCost: 94000,
      paidAmount: 64000,
      status: 'PP_SENT_TO_BG',
      statusLabel: 'Passport Sent',
      medicalExpiryDate: '2026-12-12',
      policeClearanceExpiryDate: '2026-10-29',
      appointmentDate: '2026-06-03',
    ),
    BookingItem(
      workPermitId: 'WP-1233',
      id: 4582,
      serviceType: 'Work Permit',
      createdAt: '2026-05-12',
      name: 'Arman Hossain',
      passportNo: 'U56565656',
      fromCountry: 'Bangladesh',
      toCountry: 'Serbia',
      agencyTotalCost: 96000,
      paidAmount: 35000,
      status: 'BG_COLLECT_PP',
      statusLabel: 'BG Collect Passport',
      medicalExpiryDate: '2026-11-26',
      policeClearanceExpiryDate: '2026-10-21',
    ),
    BookingItem(
      workPermitId: 'ST-2026',
      id: 4583,
      serviceType: 'Student Visa',
      createdAt: '2026-05-13',
      name: 'Maliha Noor',
      passportNo: 'V98989898',
      fromCountry: 'Bangladesh',
      toCountry: 'Ireland',
      agencyTotalCost: 158000,
      paidAmount: 60000,
      status: 'BG_COLLECT_PP',
      statusLabel: 'BG Collect Passport',
      appointmentDate: '2026-06-18',
      medicalExpiryDate: '2026-12-08',
    ),
    BookingItem(
      workPermitId: 'WP-1240',
      id: 4584,
      serviceType: 'Work Permit',
      createdAt: '2026-05-14',
      name: 'Siam Ahmed',
      passportNo: 'W11112222',
      fromCountry: 'Bangladesh',
      toCountry: 'Malta',
      agencyTotalCost: 99500,
      paidAmount: 99500,
      status: 'BG_SENT_PP',
      statusLabel: 'BG Sent Passport',
      visaExpiryDate: '2027-03-20',
    ),
    BookingItem(
      workPermitId: 'HJ-3122',
      id: 4585,
      serviceType: 'Hajj Package',
      createdAt: '2026-05-15',
      name: 'Hasina Khatun',
      passportNo: 'X33334444',
      fromCountry: 'Bangladesh',
      toCountry: 'Saudi Arabia',
      agencyTotalCost: 238000,
      paidAmount: 110000,
      status: 'A_RECEIVE_PP',
      statusLabel: 'Passport Received',
      appointmentDate: '2026-06-07',
      medicalExpiryDate: '2026-12-30',
      paymentStepCount: 3,
      hasAdvancePayout: true,
    ),
    BookingItem(
      workPermitId: 'WP-1248',
      id: 4586,
      serviceType: 'Work Permit',
      createdAt: '2026-05-16',
      name: 'Imran Kabir',
      passportNo: 'Y77778888',
      fromCountry: 'Bangladesh',
      toCountry: 'Lithuania',
      agencyTotalCost: 93000,
      paidAmount: 45000,
      status: 'BG_COLLECT_PP',
      statusLabel: 'BG Collect Passport',
      policeClearanceExpiryDate: '2026-11-09',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _collectedBookings =
        _bookings.where((item) => item.status == 'BG_COLLECT_PP').toList();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<BookingItem> get _filteredBookings {
    final bgCollectPassportOnly = _collectedBookings
        .where((item) => item.status == 'BG_COLLECT_PP')
        .toList();
    final query = _searchQuery.trim().toLowerCase();
    return bgCollectPassportOnly.where((item) {
      final createdAt = DateTime.parse(item.createdAt);
      final matchesDate =
          _selectedDateRange == null ||
          (!createdAt.isBefore(_selectedDateRange!.start) &&
              !createdAt.isAfter(_selectedDateRange!.end));
      final matchesQuery =
          query.isEmpty ||
          item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query) ||
          item.statusLabel.toLowerCase().contains(query);
      return matchesQuery && matchesDate;
    }).toList();
  }


  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(
        '/booking/wp/',
        queryParameters: {
          'status': 'BG_COLLECT_PP',
          'search': _searchQuery.trim(),
          'from_date': _selectedDateRange != null ? _formatApiDate(_selectedDateRange!.start) : '',
          'to_date': _selectedDateRange != null ? _formatApiDate(_selectedDateRange!.end) : '',
          'page': 1,
        },
      );
      final data = response.data;
      final results = data is Map<String, dynamic> ? (data['results'] as List? ?? const []) : const [];
      final mapped = results.whereType<Map>().map((item) => _fromApi(Map<String, dynamic>.from(item))).toList();
      if (!mounted) return;
      setState(() {
        _collectedBookings = mapped;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _collectedBookings = _bookings.where((item) => item.status == 'BG_COLLECT_PP').toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  BookingItem _fromApi(Map<String, dynamic> json) {
    return BookingItem(
      workPermitId: json['workPermitId']?.toString() ?? json['work_permit_id']?.toString() ?? '-',
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      serviceType: json['serviceType']?.toString() ?? json['service_type']?.toString() ?? 'Work Permit',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String().split('T').first,
      name: json['name']?.toString() ?? json['customer_name']?.toString() ?? 'Unknown',
      passportNo: json['passportNo']?.toString() ?? json['passport_no']?.toString() ?? '-',
      fromCountry: json['fromCountry']?.toString() ?? json['from_country']?.toString() ?? 'Bangladesh',
      toCountry: json['toCountry']?.toString() ?? json['to_country']?.toString() ?? '-',
      agencyTotalCost: int.tryParse(json['agencyTotalCost']?.toString() ?? json['agency_total_cost']?.toString() ?? '') ?? 0,
      paidAmount: int.tryParse(json['paidAmount']?.toString() ?? json['paid_amount']?.toString() ?? '') ?? 0,
      status: 'BG_COLLECT_PP',
      statusLabel: 'BG Collect Passport',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/receive-booking/bg-collect-passport',
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
                    const SizedBox(height: 8),
                    Text(
                      'BG Collect Passport',
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
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _searchDebounce?.cancel();
                        _searchDebounce =
                            Timer(const Duration(milliseconds: 400), _loadBookings);
                      },
                      onSearchTap: () {
                        setState(() => _searchQuery = _searchController.text);
                        _loadBookings();
                      },
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
                    if (_isLoading) const Center(child: CircularProgressIndicator()),
                    if (!_isLoading)
                      (_isCardView ? _buildCardList() : _buildTableList()),
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
          content: Text(
            'Receive Booking List',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'BG Collect Passport',
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
              _loadBookings();
            },
            child: Row(children: [
              const Icon(Icons.date_range_rounded, size: 18, color: AppPalette.textStrongBlue),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w600)),
            ]),
          ),
          const Spacer(),
          if (_selectedDateRange != null)
            InkWell(onTap: () {
              setState(() => _selectedDateRange = null);
              _loadBookings();
            }, child: const Icon(Icons.close_rounded, size: 18, color: AppPalette.textMuted)),
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
      Text(
        'BG Collect Passport File • ${_filteredBookings.length} total entries',
        style: const TextStyle(color: AppPalette.textMuted, fontSize: 14),
      ),
      const SizedBox(height: 10),
      ..._filteredBookings.map((item) {
        final style = _styleFor(item.statusLabel);
        return ReceivedBookingCard(
          bookingId: item.id,
          postId: item.workPermitId,
          statusText: item.statusLabel,
          name: item.name,
          fromCountry: item.fromCountry,
          toCountry: item.toCountry,
          totalCostText: '৳ ${_money(item.agencyTotalCost)}',
          hasAdvancePayout: item.hasAdvancePayout,
          hasAfterVisaPayout: item.hasAfterVisaPayout,
          hasBeforeFlightPayout: item.hasBeforeFlightPayout,
          createdAtText: _displayDate(item.createdAt),
          passportNo: item.passportNo,
          medicalText: item.medicalExpiryDate == null ? '22/08/2026' : _displayDate(item.medicalExpiryDate!),
          visaText: item.visaExpiryDate == null ? '22/08/2026' : _displayDate(item.visaExpiryDate!),
          policeClearText: item.policeClearanceExpiryDate == null ? '22/08/2026' : _displayDate(item.policeClearanceExpiryDate!),
          style: ReceivedBookingCardStyle(
            badgeBg: style.badgeBg,
            badgeText: style.badgeText,
            ctaLabel: style.ctaLabel,
          ),
          onMoreTap: () => _openActionsSheet(context, item),
        );
      }),
    ],
  );

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

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
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


  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(
        '/booking/wp/',
        queryParameters: {
          'status': 'BG_COLLECT_PP',
          'search': _searchQuery.trim(),
          'from_date': _selectedDateRange != null ? _formatApiDate(_selectedDateRange!.start) : '',
          'to_date': _selectedDateRange != null ? _formatApiDate(_selectedDateRange!.end) : '',
          'page': 1,
        },
      );
      final data = response.data;
      final results = data is Map<String, dynamic> ? (data['results'] as List? ?? const []) : const [];
      final mapped = results.whereType<Map>().map((item) => _fromApi(Map<String, dynamic>.from(item))).toList();
      if (!mounted) return;
      setState(() {
        _collectedBookings = mapped;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _collectedBookings = _bookings.where((item) => item.status == 'BG_COLLECT_PP').toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  BookingItem _fromApi(Map<String, dynamic> json) {
    return BookingItem(
      workPermitId: json['workPermitId']?.toString() ?? json['work_permit_id']?.toString() ?? '-',
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      serviceType: json['serviceType']?.toString() ?? json['service_type']?.toString() ?? 'Work Permit',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String().split('T').first,
      name: json['name']?.toString() ?? json['customer_name']?.toString() ?? 'Unknown',
      passportNo: json['passportNo']?.toString() ?? json['passport_no']?.toString() ?? '-',
      fromCountry: json['fromCountry']?.toString() ?? json['from_country']?.toString() ?? 'Bangladesh',
      toCountry: json['toCountry']?.toString() ?? json['to_country']?.toString() ?? '-',
      agencyTotalCost: int.tryParse(json['agencyTotalCost']?.toString() ?? json['agency_total_cost']?.toString() ?? '') ?? 0,
      paidAmount: int.tryParse(json['paidAmount']?.toString() ?? json['paid_amount']?.toString() ?? '') ?? 0,
      status: 'BG_COLLECT_PP',
      statusLabel: 'BG Collect Passport',
    );
  }

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

String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
