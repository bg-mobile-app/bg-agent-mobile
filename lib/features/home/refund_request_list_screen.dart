import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../booking/services/booking_service.dart';
import 'dashboard_screen.dart';
import 'services/payout_request_service.dart';

const List<String> refundRequestStatuses = [
  'PENDING',
  'APPROVE',
  'REJECT',
  'PAID',
  'CANCELLED',
];

class RefundRequestListScreen extends StatefulWidget {
  const RefundRequestListScreen({super.key});

  static const route = '/dashboard/refund-payment/request-list';

  @override
  State<RefundRequestListScreen> createState() => _RefundRequestListScreenState();
}

class _RefundRequestListScreenState extends State<RefundRequestListScreen> {
  final _searchController = TextEditingController();
  final _service = PayoutRequestService();
  final _bookingService = BookingService();
  Timer? _debounce;

  bool _cardView = false;
  bool _loading = true;
  bool _branchesLoading = true;
  String _search = '';
  String _status = '';
  String _branch = '';
  int _currentPage = 1;
  int _count = 0;
  int _pageSize = 20;
  List<BranchItem> _branches = const [];
  List<PayoutRequestItem> _items = const [];

  int get _totalPages {
    if (_pageSize <= 0) return 1;
    final pages = (_count / _pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
    _loadBranches();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final next = _searchController.text.trim();
      if (_search != next) {
        setState(() {
          _search = next;
          _currentPage = 1;
        });
        _load();
      }
    });
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _bookingService.getBranches();
      if (!mounted) return;
      setState(() => _branches = branches);
    } finally {
      if (mounted) setState(() => _branchesLoading = false);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final page = await _service.getRequests(
        status: _status,
        branch: _branch,
        search: _search,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _items = page.results;
        _count = page.count;
        _pageSize = page.pageSize;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _count = 0;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: RefundRequestListScreen.route,
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(),
                const SizedBox(height: 10),
                Text(
                  'Request List',
                  style: AppTextStyles.headline2.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ViewToggleButton(
                      isCardView: _cardView,
                      onChanged: (v) => setState(() => _cardView = v),
                    ),
                    SizedBox(width: 220, child: _statusFilter()),
                    SizedBox(width: 260, child: _branchFilter()),
                  ],
                ),
                const SizedBox(height: 12),
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search by post ID, booking ID or passport...',
                ),
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: _loading,
                  child: _cardView ? _cardViewList() : _tableView(),
                ),
                _pagination(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() => BreadCrumb(
    items: [
      BreadCrumbItem(content: Text('Dashboard', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
      BreadCrumbItem(content: Text('Refund Payment', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
      BreadCrumbItem(
        content: Text('Request List', style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700)),
      ),
    ],
    divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
  );

  Widget _statusFilter() => DropdownButtonFormField<String>(
    initialValue: _status.isEmpty ? null : _status,
    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
    items: [
      const DropdownMenuItem(value: '', child: Text('All Status')),
      ...refundRequestStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
    ],
    onChanged: (value) {
      setState(() {
        _status = value ?? '';
        _currentPage = 1;
      });
      _load();
    },
  );

  Widget _branchFilter() => DropdownButtonFormField<String>(
    initialValue: _branch.isEmpty ? null : _branch,
    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
    items: [
      DropdownMenuItem(value: '', child: Text(_branchesLoading ? 'Loading branches...' : 'All Branches')),
      ..._branches.map((b) => DropdownMenuItem(value: b.id.toString(), child: Text(b.name))),
    ],
    onChanged: _branchesLoading
        ? null
        : (value) {
            setState(() {
              _branch = value ?? '';
              _currentPage = 1;
            });
            _load();
          },
  );

  Widget _tableView() {
    if (_items.isEmpty && !_loading) return _emptyState();
    return StyledDataTableCard(
      columns: const [
        DataColumn(label: Text('Post & Booking ID')),
        DataColumn(label: Text('Customer Info')),
        DataColumn(label: Text('Processing By')),
        DataColumn(label: Text('Reference By')),
        DataColumn(label: Text('Step & Status')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Paid Amount')),
        DataColumn(label: Text('Current Request')),
        DataColumn(label: Text('Actions')),
      ],
      rows: _items.map((e) => DataRow(cells: [
        DataCell(Text('${e.postId}\n#${e.bookingId}')),
        DataCell(Text('${e.customerName}\n${e.passportNo}')),
        DataCell(Text('${e.processingBy}\n${e.rlNo}')),
        DataCell(Text(e.referenceBy)),
        DataCell(Text('${e.step}\n${e.status}')),
        DataCell(Text('৳ ${e.totalAmount}')),
        DataCell(Text('৳ ${e.paidAmount}')),
        DataCell(Text(e.currentRequest)),
        DataCell(_actions(e)),
      ])).toList(),
    );
  }

  Widget _cardViewList() {
    if (_items.isEmpty && !_loading) return _emptyState();
    return Column(children: _items.map((e) => _card(e)).toList());
  }

  Widget _card(PayoutRequestItem e) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppPalette.borderSoftBlue)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${e.postId} / #${e.bookingId}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Customer: ${e.customerName} (${e.passportNo})'),
      Text('Processing By: ${e.processingBy} (${e.rlNo})'),
      Text('Reference By: ${e.referenceBy}'),
      Text('Step & Status: ${e.step} / ${e.status}'),
      Text('Total Amount: ৳ ${e.totalAmount}'),
      Text('Paid Amount: ৳ ${e.paidAmount}'),
      Text('Current Request: ${e.currentRequest}'),
      const SizedBox(height: 10),
      _actions(e),
    ]),
  );

  Widget _actions(PayoutRequestItem item) => OutlinedButton.icon(
    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request #${item.id} selected'))),
    icon: const Icon(Icons.visibility_outlined, size: 18),
    label: const Text('View'),
  );

  Widget _emptyState() => const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No refund request found')));

  Widget _pagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: _currentPage > 1 ? () { setState(() => _currentPage--); _load(); } : null, icon: const Icon(Icons.chevron_left_rounded)),
        Text('Page $_currentPage of $_totalPages', style: const TextStyle(fontWeight: FontWeight.w600, color: AppPalette.textPrimary)),
        IconButton(onPressed: _currentPage < _totalPages ? () { setState(() => _currentPage++); _load(); } : null, icon: const Icon(Icons.chevron_right_rounded)),
      ]),
    );
  }
}
