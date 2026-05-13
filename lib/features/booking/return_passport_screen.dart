import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../home/dashboard_screen.dart';

class ReturnPassportScreen extends StatefulWidget {
  const ReturnPassportScreen({super.key});

  @override
  State<ReturnPassportScreen> createState() => _ReturnPassportScreenState();
}

class _ReturnPassportScreenState extends State<ReturnPassportScreen> {
  bool _isCardView = true;

  final List<ReturnPassportItem> _items = const [
    ReturnPassportItem(
      workPermitId: 'WP-5001',
      id: 5601,
      serviceType: 'Work Permit',
      createdAt: '2026-04-10',
      name: 'Shafiq Islam',
      passportNo: 'B99887766',
      fromCountry: 'Bangladesh',
      toCountry: 'Romania',
      agencyTotalCost: 90000,
      paidAmount: 50000,
      status: 'UNDER_PROCESSING',
      statusLabel: 'Return Requested',
      medicalExpiryDate: '2026-11-20',
      policeClearanceExpiryDate: '2026-10-16',
    ),
    ReturnPassportItem(
      workPermitId: 'WP-5002',
      id: 5602,
      serviceType: 'Student Visa',
      createdAt: '2026-04-16',
      name: 'Jannat Akter',
      passportNo: 'A44556677',
      fromCountry: 'Bangladesh',
      toCountry: 'Canada',
      agencyTotalCost: 140000,
      paidAmount: 140000,
      status: 'VISA_APPROVED',
      statusLabel: 'Return Accepted',
      visaExpiryDate: '2027-03-28',
    ),
    ReturnPassportItem(
      workPermitId: 'WP-5003',
      id: 5603,
      serviceType: 'Work Permit',
      createdAt: '2026-04-20',
      name: 'Nayeem Hasan',
      passportNo: 'C12349876',
      fromCountry: 'Bangladesh',
      toCountry: 'Poland',
      agencyTotalCost: 110000,
      paidAmount: 80000,
      status: 'BMET_DONE',
      statusLabel: 'Return Requested',
      appointmentDate: '2026-05-25',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/booking/my/return-passport',
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
                  'Return Passport',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _viewToggle(),
                const SizedBox(height: 16),
                _statsGrid(),
                const SizedBox(height: 16),
                if (_isCardView) _buildCardView() else _buildListView(),
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
            'Return Passport',
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderSoftBlue),
        boxShadow: AppPalette.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(
            'List View',
            Icons.format_list_bulleted,
            !_isCardView,
            () => setState(() => _isCardView = false),
          ),
          _toggleButton(
            'Card View',
            Icons.grid_view_rounded,
            _isCardView,
            () => setState(() => _isCardView = true),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: active ? AppPalette.brandBlue : Colors.transparent,
        foregroundColor: active ? Colors.white : AppPalette.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _statsGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.5,
    children: const [
      _StatCard(
        title: 'RETURN REQUESTS',
        value: '02',
        icon: Icons.assignment_return_outlined,
      ),
      _StatCard(
        title: 'COMPLETED RETURNS',
        value: '01',
        icon: Icons.task_alt_outlined,
      ),
    ],
  );

  Widget _buildListView() => Container(
    decoration: BoxDecoration(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppPalette.borderSoftBlue),
      boxShadow: AppPalette.cardShadow,
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF6FF)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppPalette.textStrongBlue,
          fontSize: 12.5,
        ),
        dataTextStyle: const TextStyle(
          color: AppPalette.textPrimary,
          fontSize: 13,
        ),
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
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Medical Expiry Date')),
          DataColumn(label: Text('Police Clearance Expiry Date')),
          DataColumn(label: Text('Visa Expiry Date')),
          DataColumn(label: Text('Appointment Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _items
            .map(
              (item) => DataRow(
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
                    _statusPill(
                      item.statusLabel,
                      item.statusLabel == 'Return Accepted'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF3C7),
                      item.statusLabel == 'Return Accepted'
                          ? const Color(0xFF166534)
                          : const Color(0xFF92400E),
                    ),
                  ),
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
                    PopupMenuButton<String>(
                      onSelected: (_) {},
                      itemBuilder: (context) => _actionsFor(item)
                          .map(
                            (action) => PopupMenuItem<String>(
                              value: action,
                              child: Text(action),
                            ),
                          )
                          .toList(),
                      child: const Icon(
                        Icons.more_vert,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _buildCardView() => Column(
    children: _items.map((item) {
      final accepted = item.statusLabel == 'Return Accepted';
      final dueAmount = item.agencyTotalCost - item.paidAmount;

      return Container(
        width: double.infinity,
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
                      color: accepted
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      Icons.assignment_return_outlined,
                      color: accepted
                          ? const Color(0xFF166534)
                          : const Color(0xFF92400E),
                      size: 34,
                    ),
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
                  _statusPill(
                    item.statusLabel,
                    accepted
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    accepted
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
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
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF737687),
                          size: 28,
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
                      color: accepted
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFAD6D6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DUE AMOUNT',
                          style: TextStyle(
                            color: accepted
                                ? const Color(0xFF166534)
                                : const Color(0xFF9F0E0E),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_money(dueAmount)} BDT',
                          style: TextStyle(
                            color: accepted
                                ? const Color(0xFF166534)
                                : const Color(0xFF9F0E0E),
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
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

  Widget _statusPill(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  String _displayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
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
    final parts = <String>[];
    for (int i = 0; i < chars.length; i += 3) {
      parts.add(chars.sublist(i, (i + 3).clamp(0, chars.length)).join());
    }
    return parts.join(',').split('').reversed.join();
  }

  List<String> _actionsFor(ReturnPassportItem row) {
    switch (row.status) {
      case 'UNDER_PROCESSING':
        return const ['See Reason', 'View Documents', 'Accept Return Passport'];
      case 'VISA_APPROVED':
        return const ['See Reason', 'View Documents'];
      case 'BMET_DONE':
        return const ['See Reason', 'View Documents', 'Accept Return Passport'];
      default:
        return const ['See Reason', 'View Documents'];
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(icon, size: 16, color: AppPalette.brandBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ReturnPassportItem {
  const ReturnPassportItem({
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
}
