import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import 'widgets/return_pp_sent_to_bg_card.dart';
import '../home/dashboard_screen.dart';
import 'dart:async';
import 'services/booking_service.dart';

class PassportReturnPpSentToBgScreen extends StatefulWidget {
  const PassportReturnPpSentToBgScreen({super.key});

  @override
  State<PassportReturnPpSentToBgScreen> createState() =>
      _PassportReturnPpSentToBgScreenState();
}

class _PassportReturnPpSentToBgScreenState
    extends State<PassportReturnPpSentToBgScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  List<ReceiveBookingItemDto> _items = [];
  Timer? _searchDebounce;
  bool _isCardView = false;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _bookingService.getReceiveBookings(
        status: 'RETURN_PP_SENT_TO_BG',
        page: 1,
        search: _searchQuery,
        fromDate: _selectedDateRange != null
            ? _formatDate(_selectedDateRange!.start)
            : null,
        toDate: _selectedDateRange != null
            ? _formatDate(_selectedDateRange!.end)
            : null,
      );
      if (mounted) {
        setState(() {
          _items = res.results;
        });
      }
    } catch (e) {
      debugPrint('Error fetching return pp sent to bg requests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ReceiveBookingItemDto> get _filteredItems {
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/passport-return/pp-sent-to-bg',
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
                      hintText:
                          'Search by post ID, booking ID, name or passport',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 400),
                          _fetchData,
                        );
                      },
                      onSearchTap: () {
                        setState(() => _searchQuery = _searchController.text);
                        _fetchData();
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
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_isCardView)
                      _buildCardList()
                    else
                      _buildTableList(),
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
                Icons.assignment_return_outlined,
                size: 14,
                color: AppPalette.textMuted,
              ),
              const SizedBox(width: 4),
              const Text(
                'Passport Return List',
                style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        BreadCrumbItem(
          content: const Text(
            'Return PP Sent to BG',
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
      onChanged: (val) => setState(() => _isCardView = val),
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
                  setState(() => _selectedDateRange = picked);
                  _fetchData();
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
                setState(() => _selectedDateRange = null);
                _fetchData();
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

  Widget _buildTableList() => StyledDataTableCard(
    dataRowMaxHeight: 70,
    columnSpacing: 20,
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
      DataColumn(label: Text('Actions')),
    ],
    rows: _filteredItems.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item.workPermitId)),
          DataCell(Text(item.id.toString())),
          DataCell(Text(_displayDate(item.createdAt))),
          DataCell(Text(item.name)),
          DataCell(Text(item.passportNo ?? 'N/A')),
          DataCell(Text(item.fromCountry)),
          DataCell(Text(item.toCountry)),
          DataCell(Text('৳ ${_money(item.agencyTotalCost ?? 0)}')),
          DataCell(Text('৳ ${_money(item.paidAmount ?? 0)}')),
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
      ..._filteredItems.map((item) {
        return ReturnPPSentToBGCard(
          bookingId: item.id.toString(),
          postId: item.workPermitId,
          customerInitials: item.name.length > 1
              ? item.name.substring(0, 2).toUpperCase()
              : item.name.toUpperCase(),
          customerName: item.name,
          passportNo: item.passportNo ?? 'N/A',
          applyDate: _displayDate(item.createdAt),
          fromCountry: item.fromCountry,
          toCountry: item.toCountry,
          totalCostText: '৳ ${_money(item.agencyTotalCost ?? 0)}',
          paidAmountText: '৳ ${_money(item.paidAmount ?? 0)}',
          onReasonTap: () => _openActionsSheet(context, item),
          onDocsTap: () => _openActionsSheet(context, item),
          onTrackTap: () => _openActionsSheet(context, item),
        );
      }),
      if (_filteredItems.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No data available.'),
          ),
        ),
    ],
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

  void _openActionsSheet(BuildContext context, ReceiveBookingItemDto item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actions • Return PP Sent to BG',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reason for Return'),
                          content: Text(item.returnFileReason.isNotEmpty ? item.returnFileReason : 'No reason provided.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('See Reason'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('View Documents'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Track Package'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
