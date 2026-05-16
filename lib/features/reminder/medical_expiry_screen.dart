import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../home/dashboard_screen.dart';

class MedicalExpiryScreen extends StatefulWidget {
  const MedicalExpiryScreen({super.key});

  @override
  State<MedicalExpiryScreen> createState() => _MedicalExpiryScreenState();
}

class _MedicalExpiryScreenState extends State<MedicalExpiryScreen> {
  bool _isCardView = false;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _dummyData = [
    {
      'id': 1,
      'name': 'Rakib Hasan',
      'phone': '+880 1711223344',
      'passportNo': 'A12345678',
      'route': 'Bangladesh → Saudi Arabia',
      'branch': 'Dhaka Head Office',
      'status': 'Confirmed',
      'medicalExpiry': '2026-05-18',
      'policeExpiry': '2026-06-15',
      'visaExpiry': '2026-07-20',
    },
    {
      'id': 2,
      'name': 'Abdul Karim',
      'phone': '+880 1822334455',
      'passportNo': 'B98765432',
      'route': 'Bangladesh → Malaysia',
      'branch': 'Chittagong Branch',
      'status': 'Under Processing',
      'medicalExpiry': '2026-05-25',
      'policeExpiry': '2026-08-10',
      'visaExpiry': '2026-09-05',
    },
    {
      'id': 3,
      'name': 'Nusrat Jahan',
      'phone': '+880 1933445566',
      'passportNo': 'C45678912',
      'route': 'Bangladesh → Canada',
      'branch': 'Sylhet Branch',
      'status': 'Visa Approved',
      'medicalExpiry': '2026-06-01',
      'policeExpiry': '2026-07-01',
      'visaExpiry': '2026-08-01',
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedFilter == 'All') return _dummyData;
    
    final now = DateTime.now();
    int days = _selectedFilter == '3 days' ? 3 : 10;
    
    return _dummyData.where((item) {
      final expiryDate = DateTime.tryParse(item['medicalExpiry']);
      if (expiryDate == null) return false;
      final diff = expiryDate.difference(now).inDays;
      return diff >= 0 && diff <= days;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/reminder/medical',
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
                  'Medical Expiry Reminders',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _viewToggle(),
                    const SizedBox(width: 10),
                    Expanded(child: _filterDropdown()),
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
            'Dashboard',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Reminder List',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Medical Expiry',
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

  Widget _filterDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppPalette.textMuted),
          items: ['All', '10 days', '3 days']
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == 'All' ? 'Filter by Days: All' : 'Expiring in: $value',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedFilter = val);
          },
        ),
      ),
    );
  }

  Widget _buildTableList() {
    return StyledDataTableCard(
      dataRowMaxHeight: 70,
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Passport No')),
        DataColumn(label: Text('Route')),
        DataColumn(label: Text('Branch')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Medical Expiry')),
        DataColumn(label: Text('Police Expiry')),
        DataColumn(label: Text('Visa Expiry')),
      ],
      rows: _filteredData.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item['id'].toString())),
            DataCell(Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(item['phone'])),
            DataCell(Text(item['passportNo'])),
            DataCell(Text(item['route'])),
            DataCell(Text(item['branch'])),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPalette.brandBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status'],
                  style: const TextStyle(fontSize: 12, color: AppPalette.brandBlue, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataCell(
              Text(
                item['medicalExpiry'],
                style: const TextStyle(color: AppPalette.danger, fontWeight: FontWeight.w700),
              ),
            ),
            DataCell(Text(item['policeExpiry'])),
            DataCell(Text(item['visaExpiry'])),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCardList() {
    return Column(
      children: _filteredData.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.borderSoftBlue),
            boxShadow: AppPalette.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppPalette.brandBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['name'].substring(0, 1),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.brandBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppPalette.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['phone'],
                            style: const TextStyle(fontSize: 13, color: AppPalette.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppPalette.brandBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'],
                      style: const TextStyle(fontSize: 12, color: AppPalette.brandBlue, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppPalette.borderSoftBlue, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _infoColumn('PASSPORT NO', item['passportNo']),
                  ),
                  Expanded(
                    child: _infoColumn('ROUTE', item['route']),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoColumn('BRANCH', item['branch']),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.danger.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.danger.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppPalette.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Medical Expiry',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppPalette.danger),
                          ),
                          Text(
                            item['medicalExpiry'],
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _infoColumn('POLICE EXPIRY', item['policeExpiry']),
                  ),
                  Expanded(
                    child: _infoColumn('VISA EXPIRY', item['visaExpiry']),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppPalette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
