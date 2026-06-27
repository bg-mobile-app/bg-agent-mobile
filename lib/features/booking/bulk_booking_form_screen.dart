import 'package:flutter/material.dart';

import '../../common/services/api_exception.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../home/models/home_models.dart';
import 'services/booking_service.dart';

const Color _brandBlue = Color(0xFF2563EB);
const Color _brandBlueLight = Color(0xFFEFF6FF);
const Color _background = Color(0xFFF5F7FC);
const Color _surface = Color(0xFFFFFFFF);
const Color _outline = Color(0xFFE5E7EB);
const Color _outlineLight = Color(0xFFF3F4F6);
const Color _text = Color(0xFF0B1C30);
const Color _mutedText = Color(0xFF6B7280);
const Color _success = Color(0xFF10B981);
const Color _premium = Color(0xFF7C3AED);

class BulkBookingFormScreen extends StatefulWidget {
  const BulkBookingFormScreen({super.key, required this.item});

  final WorkPermitItem item;

  @override
  State<BulkBookingFormScreen> createState() => _BulkBookingFormScreenState();
}

class _BulkBookingFormScreenState extends State<BulkBookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_BookingRowData> _rows = [_BookingRowData()];
  bool _agreedTerms = false;
  bool _isSubmitting = false;
  bool _isLoadingBranches = true;
  final BookingService _bookingService = BookingService();
  List<BranchItem> _branches = const [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_BookingRowData()));

  Future<void> _loadBranches() async {
    try {
      final branches = await _bookingService.getBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load application centers.')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final workPermitRef = widget.item.id != null && widget.item.id! > 0
        ? widget.item.id
        : widget.item.slug;
    if (workPermitRef == null ||
        (workPermitRef is String && workPermitRef.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid work permit data. Please try again from permit details.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_agreedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions.')),
      );
      return;
    }

    final payload = _rows
        .map(
          (row) => {
            'workPermit': workPermitRef,
            'name': row.name.text.trim(),
            'phone': row.phone.text.trim(),
            'email': row.email.text.trim(),
            'passportNo': row.passportNo.text.trim(),
            'gender': row.gender?.trim() ?? '',
            'fromCountry': 'BD',
            'toCountry': widget.item.countryName,
            'branch': row.branchId ?? 0,
            'appointmentDate': row.appointmentDate.text.trim(),
            'isPrivacyTerms': _agreedTerms,
          },
        )
        .toList();

    setState(() => _isSubmitting = true);
    debugPrint('Submitting bulk booking payload: $payload');
    try {
      await _bookingService.submitBulkWorkPermitBookings(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${payload.length} application(s) submitted successfully.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      debugPrint('Validation Error caught in submit: ${e.data}');
      if (!mounted) return;
      final message = _extractErrorMessage(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _extractErrorMessage(ApiException e) {
    final data = e.data;
    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return '${entry.key}: ${value.first}';
        }
        if (value is String && value.trim().isNotEmpty) {
          return '${entry.key}: $value';
        }
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Bulk Booking',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _surface,
        foregroundColor: _text,
        elevation: 2,
        shadowColor: _brandBlue.withOpacity(0.15),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _brandBlue.withOpacity(0.08),
                    _premium.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _brandBlue.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.item.title} Bulk Booking',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create multiple work permit applications at once with a single confirmation.',
                    style: TextStyle(
                      color: _mutedText.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._rows.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildRowCard(index, entry.value);
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addRow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _brandBlue.withOpacity(0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.add_circle_outline, size: 18, color: _brandBlue),
              label: const Text(
                'Add Another Application',
                style: TextStyle(
                  color: _brandBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: _success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreedTerms = !_agreedTerms),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreedTerms,
                            onChanged: (v) =>
                                setState(() => _agreedTerms = v ?? false),
                            side: BorderSide(
                              color: _brandBlue.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms and Conditions for all applications.',
                              style: TextStyle(
                                color: _text,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_brandBlue, _brandBlue.withOpacity(0.85)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _brandBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSubmitting ? null : _submit,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit ${_rows.length} Application${_rows.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRowCard(int index, _BookingRowData row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_surface, _surface.withOpacity(0.98)],
        ),
        boxShadow: [
          BoxShadow(
            color: _brandBlue.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: _outline.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _brandBlue.withOpacity(0.1),
                        _premium.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _brandBlue.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Application #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _brandBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (_rows.length > 1)
                  InkWell(
                    onTap: () => _removeRow(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _input(row.name, 'Full Name', required: true),
            _input(row.phone, 'Phone Number', required: true),
            _input(row.email, 'Email Address (optional)'),
            _input(row.passportNo, 'Passport Number', required: true),
            _genderDropdown(row),
            _readonlyInput('From Country', 'Bangladesh (BD)'),
            _readonlyInput('To Country', widget.item.countryName),
            _branchDropdown(row),
            _datePickerInput(row),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _outlineLight.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _outline.withOpacity(0.3), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _outline.withOpacity(0.2), width: 1),
      ),
      isDense: true,
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _genderDropdown(_BookingRowData row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: row.gender,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        decoration: _inputDecoration('Gender'),
        style: const TextStyle(
          fontSize: 14,
          color: _text,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
          DropdownMenuItem(value: 'MALE', child: Text('Male')),
        ],
        onChanged: (v) => setState(() => row.gender = v),
      ),
    );
  }

  Widget _readonlyInput(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: _inputDecoration(label),
        style: const TextStyle(
          fontSize: 14,
          color: _text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: (v) =>
            required && (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: _inputDecoration(label),
        style: const TextStyle(
          fontSize: 14,
          color: _text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _branchDropdown(_BookingRowData row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        value: row.branchId,
        validator: (v) => v == null || v <= 0 ? 'Required' : null,
        decoration: _inputDecoration('Application Center'),
        style: const TextStyle(
          fontSize: 14,
          color: _text,
          fontWeight: FontWeight.w500,
        ),
        items: _branches
            .map(
              (branch) => DropdownMenuItem<int>(
                value: branch.id,
                child: Text(branch.name),
              ),
            )
            .toList(),
        onChanged: _isLoadingBranches
            ? null
            : (v) => setState(() => row.branchId = v),
      ),
    );
  }

  Widget _datePickerInput(_BookingRowData row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: row.appointmentDate,
        readOnly: true,
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        decoration: _inputDecoration('Appointment Date').copyWith(
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: _brandBlue.withOpacity(0.6),
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: _text,
          fontWeight: FontWeight.w500,
        ),
        onTap: () async {
          final now = DateTime.now();
          final pickedDate = await showDatePicker(
            context: context,
            firstDate: DateTime(now.year - 1),
            lastDate: DateTime(now.year + 5),
            initialDate: now,
          );
          if (pickedDate == null) return;
          final month = pickedDate.month.toString().padLeft(2, '0');
          final day = pickedDate.day.toString().padLeft(2, '0');
          row.appointmentDate.text = '${pickedDate.year}-$month-$day';
        },
      ),
    );
  }
}

class _BookingRowData {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final passportNo = TextEditingController();
  String? gender;
  int? branchId;
  final appointmentDate = TextEditingController();

  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    passportNo.dispose();
    appointmentDate.dispose();
  }
}
