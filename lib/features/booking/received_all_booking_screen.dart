import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import '../home/dashboard_screen.dart';

class ReceivedAllBookingScreen extends StatefulWidget {
  const ReceivedAllBookingScreen({super.key});

  @override
  State<ReceivedAllBookingScreen> createState() =>
      _ReceivedAllBookingScreenState();
}

class _ReceivedAllBookingScreenState extends State<ReceivedAllBookingScreen> {
  bool _isCardView = false;
  late final TextEditingController _searchController;
  String _searchQuery = '';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingItem> get _filteredBookings {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _bookings;
    return _bookings.where((item) {
      return item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query) ||
          item.statusLabel.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/receive-booking/all-booking',
      child: Container(
        color: const Color(0xFFF4F8FF),
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
                _viewToggle(),

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
            'Receive Booking List',
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
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x334B5D7A), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x122563EB),
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(item),
              const SizedBox(height: 20),
              _profileSection(item),
              const SizedBox(height: 20),
              _detailsGrid(item),
              const SizedBox(height: 16),
              _financialBar(item),
              const SizedBox(height: 12),
              _buildPayoutIndicators(item),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppPalette.textStrongBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Visa Approved',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _openActionsSheet(context, item),
                      icon: const Icon(Icons.more_vert, color: AppPalette.textStrongBlue),
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

  Widget _cardHeader(BookingItem item) {
    final style = _styleFor(item.statusLabel);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking ID: #${item.id}',
                style: const TextStyle(
                  color: AppPalette.textStrongBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Post ID: ${item.workPermitId}',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [style.badgeBg, style.badgeBg.withValues(alpha: 0.72)],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            item.status.toUpperCase(),
            style: TextStyle(
              color: style.badgeText,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileSection(BookingItem item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDCE9FF), Color(0xFFB4C5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              item.name.isEmpty ? '?' : item.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppPalette.textStrongBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Passport: ${item.passportNo}',
                style: const TextStyle(color: AppPalette.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailsGrid(BookingItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x334B5D7A)),
          bottom: BorderSide(color: Color(0x334B5D7A)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _detailBlock('Route', '${item.fromCountry} → ${item.toCountry}'),
              ),
              Expanded(child: _detailBlock('Created At', _displayDate(item.createdAt))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _detailBlock(
                  'Medical Expiry',
                  item.medicalExpiryDate == null ? '22/08/2026' : _displayDate(item.medicalExpiryDate!),
                ),
              ),
              Expanded(
                child: _detailBlock(
                  'Police Expiry',
                  item.policeClearanceExpiryDate == null
                      ? '22/08/2026'
                      : _displayDate(item.policeClearanceExpiryDate!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _detailBlock(
                  'Visa Expiry',
                  item.visaExpiryDate == null ? '22/08/2026' : _displayDate(item.visaExpiryDate!),
                ),
              ),
              Expanded(
                child: _detailBlock(
                  'Police Clear.',
                  item.policeClearanceExpiryDate == null
                      ? '22/08/2026'
                      : _displayDate(item.policeClearanceExpiryDate!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildPayoutIndicators(BookingItem item) {
    return Row(
      children: [
        Expanded(child: _buildPayoutChip('ADVANCE', item.hasAdvancePayout, Icons.check_circle)),
        const SizedBox(width: 8),
        Expanded(child: _buildPayoutChip('PRE-VISA', item.hasAfterVisaPayout, Icons.pending)),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPayoutChip(
            'PRE-FLIGHT',
            item.hasBeforeFlightPayout,
            Icons.flight,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutChip(String label, bool done, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF0FDF4) : const Color(0xFFE1E8FD),
        borderRadius: BorderRadius.circular(8),
        border: done ? Border.all(color: const Color(0xFFD1FAE5)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: done ? const Color(0xFF15803D) : const Color(0xFF737686),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: done ? const Color(0xFF15803D) : const Color(0xFF737686),
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialBar(BookingItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _moneyBlock('Total Cost', '৳ ${_money(item.agencyTotalCost)}', true),
          ),
          Expanded(
            child: _moneyBlock('Paid Amount', '৳ ${_money(item.paidAmount)}', false),
          ),
        ],
      ),
    );
  }

  Widget _moneyBlock(String label, String value, bool primary) {
    return Column(
      crossAxisAlignment: primary ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppPalette.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: primary ? AppPalette.textStrongBlue : AppPalette.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _payoutIndicators(BookingItem item) {
    return Row(
      children: [
        _payoutChip('Advance', item.hasAdvancePayout),
        const SizedBox(width: 8),
        _payoutChip('After Visa', item.hasAfterVisaPayout),
        const SizedBox(width: 8),
        _payoutChip('Before Flight', item.hasBeforeFlightPayout),
      ],
    );
  }

  Widget _payoutChip(String label, bool done) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFE8F8EE) : const Color(0xFFFFF4E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle : Icons.pending,
              size: 15,
              color: done ? AppPalette.success : AppPalette.warning,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
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
