import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_palette.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../home/dashboard_screen.dart';
import 'appointment_ticket_screen.dart';
import 'services/booking_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  bool _isCardView = true;
  bool _isLoading = false;
  final BookingService _bookingService = BookingService();
  List<AppointmentBookingItem> _items = [];
  
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  int _totalPages = 1;

  final List<AppointmentBookingItem> _dummyItems = const [
    AppointmentBookingItem(
      postId: 'WP-7011',
      bookingId: 6701,
      fullName: 'Sabbir Hossain',
      country: 'Malaysia',
      visaCategory: 'Work Permit',
      meeting: 'Physical',
      date: 'May 01, 2026',
      time: '10:30 AM',
      passportNo: 'B12345678',
      packagePrice: 95000,
      paidAmount: 45000,
      avatarText: 'SH',
      avatarColor: Color(0xFF2563EB),
      actionLabel: 'Download Ticket',
    ),
    AppointmentBookingItem(
      postId: 'EP-8200',
      bookingId: 6702,
      fullName: 'Amara Ling',
      country: 'Singapore',
      visaCategory: 'Employment',
      meeting: 'Virtual',
      date: 'May 03, 2026',
      time: '02:15 PM',
      passportNo: 'A87654321',
      packagePrice: 125000,
      paidAmount: 125000,
      avatarText: 'AL',
      avatarColor: Color(0xFFC7D2FE),
      avatarTextColor: Color(0xFF475569),
      actionLabel: 'Join Meeting',
    ),
    AppointmentBookingItem(
      postId: 'SK-4412',
      bookingId: 6703,
      fullName: 'David Kim',
      country: 'South Korea',
      visaCategory: 'D-10 Visa',
      meeting: 'Physical',
      date: 'May 05, 2026',
      time: '09:00 AM',
      passportNo: 'C12673458',
      packagePrice: 110000,
      paidAmount: 60000,
      avatarText: 'DK',
      avatarColor: Color(0xFF6B7280),
      actionLabel: 'Download Ticket',
    ),
  ];

  List<AppointmentBookingItem> get _displayItems =>
      (_isLoading && _items.isEmpty) ? _dummyItems : _items;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      String? fromDate;
      String? toDate;
      if (_selectedDateRange != null) {
        fromDate = _formatDate(_selectedDateRange!.start);
        toDate = _formatDate(_selectedDateRange!.end);
      }

      final response = await _bookingService.getMyAppointments(
        page: _currentPage,
        search: _searchQuery,
        fromDate: fromDate,
        toDate: toDate,
      );

      final mapped = response.results.map((dto) {
        String dateStr = 'N/A';
        String timeStr = 'N/A';
        if ((dto.appointmentDate ?? '').isNotEmpty) {
          try {
            final dt = DateTime.parse(dto.appointmentDate!).toLocal();
            final months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            final month = months[dt.month - 1];
            final day = dt.day.toString().padLeft(2, '0');
            dateStr = '$month $day, ${dt.year}';
            
            final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
            final amPm = dt.hour >= 12 ? 'PM' : 'AM';
            final minute = dt.minute.toString().padLeft(2, '0');
            timeStr = '${hour.toString().padLeft(2, '0')}:$minute $amPm';
          } catch (e) {
            dateStr = dto.appointmentDate ?? 'N/A';
          }
        }

        final initials = dto.name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();
        
        final colors = [
          const Color(0xFF2563EB),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEF4444),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
        ];
        final color = colors[dto.id % colors.length];

        return AppointmentBookingItem(
          postId: dto.workPermitId > 0
              ? dto.workPermitId.toString()
              : (dto.workPermitSlug.isNotEmpty
                  ? dto.workPermitSlug.toUpperCase()
                  : 'N/A'),
          bookingId: dto.id,
          fullName: dto.name,
          country: dto.toCountry,
          visaCategory: dto.serviceType,
          meeting: dto.meeting ?? 'Physical',
          date: dateStr,
          time: timeStr,
          passportNo: dto.passportNo ?? 'Not Provided',
          avatarText: initials.isNotEmpty ? initials : 'AP',
          avatarColor: color,
          avatarTextColor: Colors.white,
          actionLabel: 'Download Ticket',
          packagePrice: dto.packagePrice ?? 0,
          paidAmount: dto.paidAmount ?? 0,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _items = mapped;
          _totalPages = response.totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/booking/appointment',
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(),
                const SizedBox(height: 8),
                const Text(
                  'Appointment Booking',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _searchBar(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ViewToggleButton(
                      isCardView: _isCardView,
                      onChanged: (isCardView) =>
                          setState(() => _isCardView = isCardView),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _dateRangeButton()),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Skeletonizer(
                    enabled: _isLoading && _items.isEmpty,
                    child: _displayItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No Appointments Found',
                              style: TextStyle(
                                color: AppPalette.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: _isCardView ? _buildCardView() : _buildListView(),
                              ),
                              _buildPagination(),
                            ],
                          ),
                  ),
                ),
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
            'Dashboard',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: const Text(
            'Appointment Booking',
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
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                    _currentPage = 1;
                  });
                  _fetchAppointments();
                }
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
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedDateRange != null)
            InkWell(
              onTap: () {
                setState(() {
                  _selectedDateRange = null;
                  _currentPage = 1;
                });
                _fetchAppointments();
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

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.borderSoftBlue),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppPalette.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
                _fetchAppointments();
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'Search in Appointment Booking',
                hintStyle: TextStyle(color: AppPalette.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _searchQuery = _searchController.text;
                _currentPage = 1;
              });
              _fetchAppointments();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.brandBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x402563EB),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.search, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchAppointments();
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary,
            ),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchAppointments();
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final itemsToUse = _displayItems;
    return StyledDataTableCard(
      columns: const [
        DataColumn(label: Text('Post ID')),
        DataColumn(label: Text('Booking ID')),
        DataColumn(label: Text('Full Name')),
        DataColumn(label: Text('Country')),
        DataColumn(label: Text('Visa Category')),
        DataColumn(label: Text('Meeting')),
        DataColumn(label: Text('Date & Time')),
        DataColumn(label: Text('Overview')),
      ],
      rows: itemsToUse
          .map(
            (item) => DataRow(
              cells: [
                DataCell(Text(item.postId)),
                DataCell(Text(item.bookingId.toString())),
                DataCell(Text(item.fullName)),
                DataCell(Text(item.country)),
                DataCell(Text(item.visaCategory)),
                DataCell(Text(item.meeting)),
                DataCell(Text('${item.date} ${item.time}')),
                DataCell(
                  IconButton(
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: AppPalette.brandBlue,
                    ),
                    onPressed: () => _openTicket(item),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildCardView() {
    final itemsToUse = _displayItems;
    return ListView.separated(
      itemCount: itemsToUse.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = itemsToUse[index];

        return Container(
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
                      topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                          color: item.avatarColor,
                          borderRadius: BorderRadius.circular(999)),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.fullName,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191B24))),
                            const SizedBox(height: 4),
                            Row(children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFD8E6FF),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(item.postId,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF38485D)))),
                              const SizedBox(width: 8),
                              const Text('•',
                                  style: TextStyle(
                                      color: Color(0xFF737687), fontSize: 12)),
                              const SizedBox(width: 8),
                              Text(item.country,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF434655))),
                            ]),
                          ]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: _detailTile(
                                'BOOKING ID',
                                item.bookingId.toString(),
                                Icons.confirmation_number_outlined)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: _detailTile('VISA CATEGORY',
                                item.visaCategory, Icons.article_outlined)),
                      ]),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                            child: _detailTile('MEETING', item.meeting,
                                Icons.groups_outlined)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: _detailTile('DATE & TIME',
                                '${item.date} ${item.time}', Icons.schedule)),
                      ]),
                      const SizedBox(height: 18),
                      _detailTile('COUNTRY', item.country, Icons.public_outlined),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openTicket(item),
                          icon: const Icon(Icons.download, size: 22),
                          label: const Text('Overview',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppPalette.brandBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailTile(String label, String value, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF737687))),
      const SizedBox(height: 6),
      Row(children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)))
      ]),
    ]);
  }

  void _openTicket(AppointmentBookingItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentTicketScreen(
          id: item.bookingId,
          name: item.fullName,
          passportNo: item.passportNo,
          appointmentDate: '${item.date} ${item.time}',
          toCountry: item.country,
        ),
      ),
    );
  }
}

class AppointmentBookingItem {
  final String postId;
  final int bookingId;
  final String fullName;
  final String country;
  final String visaCategory;
  final String meeting;
  final String date;
  final String time;
  final String passportNo;
  final String avatarText;
  final Color avatarColor;
  final Color avatarTextColor;
  final String actionLabel;
  final int packagePrice;
  final int paidAmount;

  const AppointmentBookingItem({
    required this.postId,
    required this.bookingId,
    required this.fullName,
    required this.country,
    required this.visaCategory,
    required this.meeting,
    required this.date,
    required this.time,
    required this.passportNo,
    required this.packagePrice,
    required this.paidAmount,
    required this.avatarText,
    required this.avatarColor,
    this.avatarTextColor = Colors.white,
    required this.actionLabel,
  });
}
