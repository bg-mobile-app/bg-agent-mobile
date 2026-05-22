import 'package:flutter/material.dart';

import '../../common/services/api_exception.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../home/models/home_models.dart';
import 'services/booking_service.dart';

const Color _brandBlue = Color(0xFF2563EB);
const Color _background = Color(0xFFF8F9FF);
const Color _surface = Color(0xFFFFFFFF);
const Color _outline = Color(0xFFC3C6D7);
const Color _text = Color(0xFF0B1C30);
const Color _mutedText = Color(0xFF434655);

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
  final BookingService _bookingService = BookingService();

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_BookingRowData()));

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _submit() async {
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
            'workPermit': widget.item.id,
            'name': row.name.text.trim(),
            'phone': row.phone.text.trim(),
            'email': row.email.text.trim(),
            'passportNo': row.passportNo.text.trim(),
            'gender': row.gender.text.trim(),
            'fromCountry': 'BD',
            'toCountry': widget.item.country,
            'branch': int.tryParse(row.branch.text.trim()) ?? 0,
            'appointmentDate': row.appointmentDate.text.trim(),
            'isPrivacyTerms': _agreedTerms,
          },
        )
        .toList();

    setState(() => _isSubmitting = true);
    try {
      await _bookingService.submitBulkWorkPermitBookings(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${payload.length} application(s) submitted successfully.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = _extractErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
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
        title: const Text('Bulk Booking Form'),
        backgroundColor: _surface,
        foregroundColor: _text,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$title Bulk Booking Form',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _text),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create multiple work permit applications at once with a single confirmation.',
              style: TextStyle(color: _mutedText),
            ),
            const SizedBox(height: 16),
            ..._rows.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildRowCard(index, entry.value);
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
              label: const Text('Add Another Application'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _agreedTerms,
              onChanged: (v) => setState(() => _agreedTerms = v ?? false),
              contentPadding: EdgeInsets.zero,
              title: const Text('I agree to the Terms and Conditions for all applications.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Submit ${_rows.length} Application${_rows.length > 1 ? 's' : ''}'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRowCard(int index, _BookingRowData row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Application #${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                if (_rows.length > 1)
                  TextButton(
                    onPressed: () => _removeRow(index),
                    child: const Text('Remove'),
                  ),
              ],
            ),
            _input(row.name, 'Full Name', required: true),
            _input(row.phone, 'Phone Number', required: true),
            _input(row.email, 'Email Address (optional)'),
            _input(row.passportNo, 'Passport Number', required: true),
            _input(row.gender, 'Gender', required: true),
            _input(row.branch, 'Application Center', required: true),
            _input(row.appointmentDate, 'Appointment Date (YYYY-MM-DD)', required: true),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: (v) => required && (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }
}

class _BookingRowData {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final passportNo = TextEditingController();
  final gender = TextEditingController();
  final branch = TextEditingController();
  final appointmentDate = TextEditingController();

  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    passportNo.dispose();
    gender.dispose();
    branch.dispose();
    appointmentDate.dispose();
  }
}
