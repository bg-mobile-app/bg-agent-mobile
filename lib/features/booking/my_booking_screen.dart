import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import '../home/dashboard_screen.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
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
      currentHref: '/dashboard/booking/my',
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
                const Text(
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
                  onSearchTap: () => setState(() => _searchQuery = _searchController.text),
                ),
                const SizedBox(height: 14),
                _viewToggle(),
                const SizedBox(height: 16),
                _statsGrid(),
                const SizedBox(height: 16),
                if (_isCardView) _buildCardList() else _tableHeader(),
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
          content: const Text(
            'Recruitment Portal',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: const Text(
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
        onLongPress: () => _openActionsSheet(item),
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
          DataCell(Text(item.medicalExpiryDate == null ? '-' : _displayDate(item.medicalExpiryDate!))),
          DataCell(Text(item.policeClearanceExpiryDate == null ? '-' : _displayDate(item.policeClearanceExpiryDate!))),
          DataCell(Text(item.visaExpiryDate == null ? '-' : _displayDate(item.visaExpiryDate!))),
          DataCell(Text(item.appointmentDate == null ? '-' : _displayDate(item.appointmentDate!))),
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

  Widget _tableHeader() => Container(
    decoration: BoxDecoration(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppPalette.borderSoftBlue),
      boxShadow: AppPalette.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.table_chart_outlined,
                  color: AppPalette.brandBlue,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'All Booking Files',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredBookings.length} entries',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppPalette.borderNeutral),
        _buildTableList(),
      ],
    ),
  );

  Widget _buildCardList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Booking File • ${_filteredBookings.length} total entries',
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ..._filteredBookings.map((item) {
            final style = _styleFor(item.statusLabel);
            final dueAmount = item.agencyTotalCost - item.paidAmount;
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
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: style.iconBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(style.icon, color: style.iconColor, size: 34),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF191B24),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD8E6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.workPermitId,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF38485D),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                      color: Color(0xFF737687),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.serviceType,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF434655),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                                'BOOKING ID',
                                item.id.toString(),
                                Icons.confirmation_num_outlined,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _detailTile(
                                'STATUS',
                                item.statusLabel,
                                Icons.groups_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _detailTile(
                                'DATE',
                                _displayDate(item.createdAt),
                                Icons.calendar_today_outlined,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _detailTile(
                                'SERVICE TYPE',
                                item.serviceType,
                                Icons.article_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBBC1D6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flight,
                                color: Color(0xFF434655),
                                size: 30,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PASSPORT NUMBER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF737687),
                                      ),
                                    ),
                                    Text(
                                      item.passportNo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: style.badgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: style.badgeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Color(0xFFBBC1D6)),
                        const SizedBox(height: 12),
                        _amountRow(
                          'Package Price',
                                        '${_money(item.agencyTotalCost)} BDT',
                          const Color(0xFF191B24),
                          false,
                        ),
                        const SizedBox(height: 12),
                        _amountRow(
                          'Paid Amount',
                          '${_money(item.paidAmount)} BDT',
                          AppPalette.brandBlue,
                          true,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAD6D6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'DUE AMOUNT',
                                style: TextStyle(
                                  color: Color(0xFF9F0E0E),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_money(dueAmount)} BDT',
                                style: const TextStyle(
                                  color: Color(0xFF9F0E0E),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: Icon(style.ctaIcon, size: 18),
                            label: Text(
                              style.ctaLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: AppPalette.borderSoftBlue,
                              foregroundColor: AppPalette.textMuted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3FF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF737687),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'PLEASE ARRIVE 15 MINUTES BEFORE YOUR SCHEDULED TIME.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF434655),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
        Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF434655))),
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
    final actions = <String, List<String>>{
      'APPLIED_FILE': ['View Post', 'Reject'],
      'BG_COLLECT_PP': [],
      'BG_SENT_PP': ['Receive Passport'],
      'A_RECEIVE_PP': ['Sent to Processing', 'Payment Request', 'Add Reminder', 'View Documents', 'Reject'],
      'UNDER_PROCESSING': ['Visa Approved', 'Upload Documents', 'Add Reminder', 'Visa Reminder', 'View Documents', 'Reject'],
      'VISA_APPROVED': ['BMET Done', 'Upload Documents', 'Payment Request', 'View Documents', 'Reject'],
      'BMET_DONE': ['Ticket Done', 'Upload Documents', 'View Documents', 'Reject'],
      'TICKET_DONE': ['Payment Request', 'PP Send to BG', 'Upload Documents', 'View Documents', 'Reject'],
      'PP_SENT_TO_BG': ['View Documents'],
      'BG_RECEIVED_PP': ['View Documents'],
      'READY_FOR_FLIGHT': ['View Documents'],
      'SUCCESS_FLIGHT': ['View Documents'],
      'RETURN_PP_SENT_TO_BG': ['View Documents'],
      'BG_COLLECT_RETURN_PP': ['View Documents'],
      'BG_HANDOVER_PP_TO_CUSTOMER': ['View Documents'],
      'REJECT_FILE': [],
    }[row.status] ?? <String>[];
    return actions.where((action) {
      if (action == 'Sent to Processing' && row.status == 'A_RECEIVE_PP') {
        if (row.paymentStepCount == 3 && !row.hasAdvancePayout) return false;
      }
      if (action == 'BMET Done' && row.status == 'VISA_APPROVED' && !row.hasAfterVisaPayout) return false;
      if (action == 'Payment Request') {
        if (row.status == 'A_RECEIVE_PP' && (row.paymentStepCount != 3 || row.hasAdvancePayout)) return false;
        if (row.status == 'VISA_APPROVED' && row.hasAfterVisaPayout) return false;
        if (row.status == 'TICKET_DONE' && row.hasBeforeFlightPayout) return false;
      }
      if (action == 'PP Send to BG' && row.status == 'TICKET_DONE' && !row.hasBeforeFlightPayout) return false;
      return true;
    }).toList();
  }

  void _openActionsSheet(BookingItem row) {
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
              Text('Actions • ${row.statusLabel}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              if (actions.isEmpty) const Text('No actions available') else Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions.map((action) => OutlinedButton(
                  onPressed: row.isReturn ? null : () => Navigator.pop(context),
                  child: Text(action),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
