import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'services/check_status_service.dart';
import 'dashboard_screen.dart';

class CheckStatusScreen extends StatefulWidget {
  const CheckStatusScreen({super.key});

  @override
  State<CheckStatusScreen> createState() => _CheckStatusScreenState();
}

class _CheckStatusScreenState extends State<CheckStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passportController = TextEditingController();
  final _bookingIdController = TextEditingController();
  final CheckStatusService _checkStatusService = CheckStatusService();

  List<BookingStatusItem> _data = [];
  bool _submitted = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passportController.dispose();
    _bookingIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final passport = _passportController.text.trim();
    final bookingId = _bookingIdController.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _submitted = false;
    });

    try {
      final result = await _checkStatusService.getMyBookingStatus(
        passportNo: passport,
        bookingId: bookingId,
      );

      if (!mounted) return;
      setState(() {
        _data = result.map(BookingStatusItem.fromDto).toList();
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _data = [];
        _errorMessage = 'Failed to fetch booking status. Please try again.';
        _submitted = true;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clear() {
    _formKey.currentState?.reset();
    _passportController.clear();
    _bookingIdController.clear();
    setState(() {
      _data = [];
      _submitted = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/customer/check-status',
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
                Text('Check Status', style: AppTextStyles.headline2.copyWith(fontSize: 25, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Track your file status using passport and booking ID.', style: AppTextStyles.body2.copyWith(color: AppPalette.textMuted)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.borderSoftBlue),
                    boxShadow: AppPalette.cardShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 700;
                            if (isNarrow) {
                              return Column(
                                children: [
                                  _inputField(label: 'Passport Number', controller: _passportController, autofocus: true),
                                  const SizedBox(height: 12),
                                  _inputField(label: 'Booking ID', controller: _bookingIdController),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: _inputField(label: 'Passport Number', controller: _passportController, autofocus: true)),
                                const SizedBox(width: 12),
                                Expanded(child: _inputField(label: 'Booking ID', controller: _bookingIdController)),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          children: [
                            FilledButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: FilledButton.styleFrom(backgroundColor: AppPalette.brandBlue),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Submit'),
                            ),
                            OutlinedButton(
                              onPressed: _clear,
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppPalette.borderSoftBlue)),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_submitted) ...[
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.borderSoftBlue),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  else if (_data.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.borderSoftBlue),
                      ),
                      child: const Text(
                        'No application found for given Passport Number and Booking ID.',
                        style: TextStyle(color: AppPalette.textMuted),
                      ),
                    )
                  else
                    Column(
                      children: _data
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _statusCard(item: item),
                              ))
                          .toList(),
                    ),
                ],
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
        BreadCrumbItem(content: Text('Dashboard', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
        BreadCrumbItem(
          content: Text('Check Status', style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700)),
        ),
      ],
      divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
    );
  }

  Widget _inputField({required String label, required TextEditingController controller, bool autofocus = false}) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: AppPalette.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppPalette.borderSoftBlue)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppPalette.borderSoftBlue)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _statusCard({required BookingStatusItem item}) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: AppPalette.borderSoftBlue),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0x1A2563EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Text('Booking ID #${item.id}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.textStrongBlue)),
          ),
          _tableRow('Full Name', item.name),
          _tableRow('Passport Number', item.passportNo),
          _tableRow('Country', item.toCountry),
          _tableRow('Visa Category', item.serviceType),
          _tableRow('Meeting Type', 'Physical'),
          _tableRow('File Process Branch', item.branch),
          _tableRow('Status', item.statusLabel),
          if (item.medicalExpiryDate != null) _tableRow('Medical Expiry Date', item.medicalExpiryDate!),
          if (item.policeClearanceExpiryDate != null) _tableRow('Police Clearance Expiry Date', item.policeClearanceExpiryDate!),
          if (item.visaExpiryDate != null) _tableRow('Visa Expiry Date', item.visaExpiryDate!),
          _tableRow('Appointment Date', item.appointmentDate, isLast: true),
        ],
      ),
    );
  }

  Widget _tableRow(String label, String value, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppPalette.borderNeutral)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.textMuted)),
            ),
            Expanded(
              flex: 7,
              child: Text(value, style: const TextStyle(color: AppPalette.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingStatusItem {
  const BookingStatusItem({
    required this.id,
    required this.name,
    required this.passportNo,
    required this.toCountry,
    required this.serviceType,
    required this.branch,
    required this.statusLabel,
    required this.appointmentDate,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
  });

  final String id;
  final String name;
  final String passportNo;
  final String toCountry;
  final String serviceType;
  final String branch;
  final String statusLabel;
  final String appointmentDate;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;

  factory BookingStatusItem.fromDto(BookingStatusDto dto) {
    return BookingStatusItem(
      id: dto.id.toString(),
      name: dto.name,
      passportNo: dto.passportNo,
      toCountry: dto.toCountry,
      serviceType: dto.serviceType,
      branch: dto.branch,
      statusLabel: dto.statusLabel,
      appointmentDate: dto.appointmentDate,
      medicalExpiryDate: dto.medicalExpiryDate,
      policeClearanceExpiryDate: dto.policeClearanceExpiryDate,
      visaExpiryDate: dto.visaExpiryDate,
    );
  }
}
