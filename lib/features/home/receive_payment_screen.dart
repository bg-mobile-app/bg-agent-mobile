import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import 'dashboard_screen.dart';
import 'services/payout_request_service.dart';

const List<String> receivePaymentStatuses = ['PENDING', 'APPROVED', 'PAID', 'CANCELLED'];

class ReceivePaymentScreen extends StatefulWidget {
  const ReceivePaymentScreen({super.key, this.initialStatus = '', required this.currentHref, required this.title});

  final String initialStatus;
  final String currentHref;
  final String title;

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  final _searchController = TextEditingController();
  final _service = PayoutRequestService();
  Timer? _debounce;

  bool _cardView = false;
  bool _loading = true;
  String _search = '';
  String _status = '';
  List<PayoutRequestItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _searchController.addListener(_onSearchChange);
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
        setState(() => _search = next);
        _load();
      }
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final page = await _service.getRequests(status: _status, search: _search, page: 1);
      if (!mounted) return;
      setState(() => _items = page.results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = const []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: widget.currentHref,
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
                Text(widget.title, style: AppTextStyles.headline2.copyWith(fontWeight: FontWeight.w800, fontSize: 24)),
                const SizedBox(height: 12),
                Row(children: [
                  ViewToggleButton(isCardView: _cardView, onChanged: (v) => setState(() => _cardView = v)),
                  const SizedBox(width: 12),
                  Expanded(child: _statusFilter()),
                ]),
                const SizedBox(height: 12),
                AppSearchBar(controller: _searchController, hintText: 'Search by post ID, booking ID or passport...'),
                const SizedBox(height: 16),
                Skeletonizer(enabled: _loading, child: _cardView ? _cardViewList() : _tableView()),
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
      BreadCrumbItem(content: Text('Receive Payment', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
      BreadCrumbItem(content: Text(widget.title, style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700))),
    ],
    divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
  );

  Widget _statusFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _status.isEmpty ? null : _status,
      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Status')),
        ...receivePaymentStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
      ],
      onChanged: (value) {
        setState(() => _status = value ?? '');
        _load();
      },
    );
  }

  Widget _tableView() {
    if (_items.isEmpty && !_loading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No payout request found')));
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
      ],
      rows: _items
          .map(
            (e) => DataRow(cells: [
              DataCell(Text('${e.postId}\n#${e.bookingId}')),
              DataCell(Text('${e.customerName}\n${e.passportNo}')),
              DataCell(Text('${e.processingBy}\n${e.rlNo}')),
              DataCell(Text(e.referenceBy)),
              DataCell(Text('${e.step}\n${e.status}')),
              DataCell(Text('৳ ${e.totalAmount}')),
              DataCell(Text('৳ ${e.paidAmount}')),
              DataCell(Text('৳ ${e.currentRequest}')),
            ]),
          )
          .toList(),
    );
  }

  Widget _cardViewList() {
    if (_items.isEmpty && !_loading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No payout request found')));
    return Column(children: _items.map((e) => _card(e)).toList());
  }

  Widget _card(PayoutRequestItem e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppPalette.borderSoftBlue)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${e.postId} / #${e.bookingId}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Customer: ${e.customerName} (${e.passportNo})'),
        Text('Processing: ${e.processingBy} (${e.rlNo})'),
        Text('Reference: ${e.referenceBy}'),
        Text('Step & Status: ${e.step} / ${e.status}'),
        Text('Total: ৳ ${e.totalAmount} | Paid: ৳ ${e.paidAmount}'),
        Text('Current Request: ৳ ${e.currentRequest}'),
      ]),
    );
  }

}
