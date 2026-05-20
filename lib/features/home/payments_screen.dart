import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/widgets/styled_data_table_card.dart';
import 'dashboard_screen.dart';
import 'services/payment_service.dart';
import '../../common/services/api_client.dart';

const List<String> bookingStatus = [
  'ADVANCE',
  'AFTER_VISA',
  'BEFORE_FLIGHT',
  'RETURN',
  'COMPLETED',
];

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _status = '';
  String _debouncedSearch = '';
  bool _cardView = true;

  final PaymentService _paymentService = PaymentService();
  bool _isInitialLoading = true;
  String? _error;
  List<PaymentsHistory> _payments = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPayments(isInitial: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      if (_debouncedSearch != query) {
        setState(() {
          _debouncedSearch = query;
        });
        _loadPayments(isInitial: true);
      }
    });
  }

  Future<void> _loadPayments({bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });
    }

    try {
      final cookies = await ApiClient().tokenStorage.getCookies();
      if (cookies == null || cookies.isEmpty) {
        if (!mounted) return;
        var list = _skeletonPayments;
        if (_status.isNotEmpty) {
          list = list.where((p) => p.step == _status).toList();
        }
        if (_debouncedSearch.isNotEmpty) {
          list = list.where((p) => p.passportNo.toLowerCase().contains(_debouncedSearch.toLowerCase()) || p.bookingId.toLowerCase().contains(_debouncedSearch.toLowerCase())).toList();
        }
        setState(() {
          _payments = list;
          _error = null;
          _isInitialLoading = false;
        });
        return;
      }

      final response = await _paymentService.getPaymentsHistory(
        step: _status,
        search: _debouncedSearch,
      );

      if (!mounted) return;

      setState(() {
        _payments = response.results;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      var list = _skeletonPayments;
      if (_status.isNotEmpty) {
        list = list.where((p) => p.step == _status).toList();
      }
      if (_debouncedSearch.isNotEmpty) {
        list = list.where((p) => p.passportNo.toLowerCase().contains(_debouncedSearch.toLowerCase()) || p.bookingId.toLowerCase().contains(_debouncedSearch.toLowerCase())).toList();
      }
      setState(() {
        _payments = list;
        _error = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _isInitialLoading ? _skeletonPayments : _payments;

    return DashboardPageScaffold(
      currentHref: '/dashboard/my-payments',
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
                  'Payments History',
                  style: AppTextStyles.headline2.copyWith(fontSize: 25, fontWeight: FontWeight.w800, color: AppPalette.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  _isInitialLoading
                      ? 'Loading your payment history...'
                      : 'See history of your payment plan invoice (${_payments.length})',
                  style: AppTextStyles.body2.copyWith(color: AppPalette.textMuted),
                ),
                const SizedBox(height: 14),
                _topControls(),
                const SizedBox(height: 12),
                _searchBox(),
                const SizedBox(height: 16),
                if (_error != null)
                  _errorState()
                else
                  Skeletonizer(
                    enabled: _isInitialLoading,
                    child: _cardView ? _cardContent(displayItems) : _tableContent(displayItems),
                  ),
                const SizedBox(height: 16),
                Skeletonizer(
                  enabled: _isInitialLoading,
                  child: _statsSection(displayItems),
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
          content: Text('Dashboard', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted)),
        ),
        BreadCrumbItem(
          content: Text(
            'Payments',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700),
          ),
        ),
      ],
      divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
    );
  }

  Widget _topControls() {
    return Row(
      children: [
        ViewToggleButton(
          isCardView: _cardView,
          onChanged: (value) => setState(() => _cardView = value),
        ),
        const SizedBox(width: 12),
        Expanded(child: _statusDropdown()),
      ],
    );
  }

  Widget _searchBox() {
    return AppSearchBar(
      controller: _searchController,
      hintText: 'Search by Passport No...',
      onChanged: (value) {
        // Debounce handles this via listener
      },
      onSearchTap: () {
        _debounce?.cancel();
        final query = _searchController.text.trim();
        if (_debouncedSearch != query) {
          setState(() {
            _debouncedSearch = query;
          });
          _loadPayments(isInitial: true);
        }
      },
    );
  }

  Widget _statusDropdown() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.borderSoftBlue),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2563EB),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DropdownButtonFormField<String>(
          initialValue: _status.isEmpty ? null : _status,
          isExpanded: true,
          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
          dropdownColor: Colors.white,
          iconEnabledColor: AppPalette.brandBlue,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'All Status',
            hintStyle: TextStyle(color: AppPalette.textMuted, fontSize: 13),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('All Status')),
            ...bookingStatus.map((e) => DropdownMenuItem(value: e, child: Text(e))),
          ],
          onChanged: (value) {
            setState(() {
              _status = value ?? '';
            });
            _loadPayments(isInitial: true);
          },
        ),
      ),
    );
  }

  Widget _tableContent(List<PaymentsHistory> items) {
    if (items.isEmpty) {
      return _emptyState();
    }

    return StyledDataTableCard(
      columns: const [
        DataColumn(label: Text('Payment Invoice')),
        DataColumn(label: Text('Booking ID')),
        DataColumn(label: Text('Post ID')),
        DataColumn(label: Text('Payment Date')),
        DataColumn(label: Text('Passport No')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Status')),
      ],
      rows: items
          .map(
            (item) => DataRow(
              cells: [
                DataCell(Text('#INV-${item.id}', style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(item.bookingId)),
                DataCell(Text(item.postId)),
                DataCell(Text(_formatListDate(item.collectedAt))),
                DataCell(Text(item.passportNo)),
                DataCell(Text('৳ ${_money(item.amount)}', style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(_statusChip(item.step)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _cardContent(List<PaymentsHistory> items) {
    if (items.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: items.map(_paymentCard).toList(),
    );
  }

  Widget _paymentCard(PaymentsHistory item) {
    final isReturn = item.step == 'RETURN';
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
                    color: isReturn ? const Color(0xFFFAD6D6) : const Color(0xFFD8E6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    isReturn ? Icons.keyboard_return_rounded : Icons.payments_outlined,
                    color: isReturn ? const Color(0xFF9F0E0E) : AppPalette.brandBlue,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#INV-${item.id}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF191B24)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFD8E6FF), borderRadius: BorderRadius.circular(8)),
                            child: Text(item.postId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF38485D))),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Color(0xFF737687), fontSize: 12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item.bookingId, style: const TextStyle(fontSize: 15, color: Color(0xFF434655))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusChip(item.step),
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
                    Expanded(child: _detailTile('PAYMENT DATE', _formatListDate(item.collectedAt), Icons.calendar_today_outlined)),
                    const SizedBox(width: 14),
                    Expanded(child: _detailTile('PAYMENT TIME', _formatTime(item.collectedAt), Icons.schedule)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _detailTile('PASSPORT NO', item.passportNo, Icons.badge_outlined)),
                    const SizedBox(width: 14),
                    Expanded(child: _detailTile('PAYMENT TYPE', item.step, Icons.article_outlined)),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBC1D6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF434655), size: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AMOUNT', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700, color: Color(0xFF737687))),
                            Text('৳ ${_money(item.amount)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isReturn ? const Color(0xFF9F0E0E) : AppPalette.textPrimary)),
                          ],
                        ),
                      ),
                      Icon(isReturn ? Icons.trending_down_rounded : Icons.trending_up_rounded, color: isReturn ? const Color(0xFF9F0E0E) : const Color(0xFF166534), size: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection(List<PaymentsHistory> items) {
    final totalProcessed = items.fold<int>(0, (sum, i) => sum + i.amount);
    final pendingCount = items.where((i) => i.step != 'COMPLETED').length;
    final totalCount = items.isEmpty ? 1 : items.length;
    final completedCount = items.where((i) => i.step == 'COMPLETED').length;
    final completionProgress = (completedCount / totalCount).clamp(0.0, 1.0);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppPalette.brandBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppPalette.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL PROCESSED', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('৳ ${_money(totalProcessed)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.borderSoftBlue),
            boxShadow: AppPalette.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PENDING CLAIMS', style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                '$pendingCount',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppPalette.textPrimary),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: completionProgress,
                  minHeight: 5,
                  color: AppPalette.brandBlue,
                  backgroundColor: const Color(0xFFE7EAF3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.borderSoftBlue),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.payments_outlined, size: 60, color: AppPalette.textMuted),
          const SizedBox(height: 16),
          Text(
            'No payments history found',
            style: AppTextStyles.subtitle1.copyWith(color: AppPalette.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search query or status filter.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: AppPalette.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 14),
          Text(
            _error ?? 'Failed to load payments',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadPayments(isInitial: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.brandBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w700, color: Color(0xFF737687))),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 22, color: AppPalette.brandBlue),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final isReturn = status == 'RETURN';
    final isCompleted = status == 'COMPLETED';

    Color bg = const Color(0xFFD8F3DE);
    Color fg = const Color(0xFF1C7A3B);

    if (isReturn) {
      bg = const Color(0xFFF8D8D7);
      fg = const Color(0xFFB3261E);
    } else if (!isCompleted && status != 'ADVANCE') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    final meridiem = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $meridiem';
  }

  String _formatListDate(DateTime date) {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${monthNames[date.month - 1]}, ${date.year}';
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
}

final List<PaymentsHistory> _skeletonPayments = [
  PaymentsHistory(
    id: 1000,
    bookingId: 'B-99821',
    postId: 'P-5541',
    collectedAt: DateTime(2026, 1, 27, 10, 20),
    passportNo: 'A12345678',
    amount: 50000,
    step: 'ADVANCE',
    sequence: '1',
    terminal: 'BKASH',
    transactionType: 'CREDIT',
  ),
  PaymentsHistory(
    id: 999,
    bookingId: 'B-99750',
    postId: 'P-5420',
    collectedAt: DateTime(2026, 1, 20, 14, 45),
    passportNo: 'A12345678',
    amount: 50000,
    step: 'RETURN',
    sequence: '2',
    terminal: 'BKASH',
    transactionType: 'DEBIT',
  ),
  PaymentsHistory(
    id: 998,
    bookingId: 'B-99740',
    postId: 'P-5380',
    collectedAt: DateTime(2026, 1, 15, 9, 30),
    passportNo: 'B87654321',
    amount: 75000,
    step: 'COMPLETED',
    sequence: '3',
    terminal: 'NAGAD',
    transactionType: 'CREDIT',
  ),
  PaymentsHistory(
    id: 997,
    bookingId: 'B-99722',
    postId: 'P-5301',
    collectedAt: DateTime(2026, 1, 10, 11, 0),
    passportNo: 'C11223344',
    amount: 42000,
    step: 'ADVANCE',
    sequence: '1',
    terminal: 'ROCKET',
    transactionType: 'CREDIT',
  ),
];
