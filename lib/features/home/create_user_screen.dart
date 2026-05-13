import 'package:flutter/material.dart';

import '../../common/widgets/app_custom_input_field.dart';
import 'dashboard_screen.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/user/create-user',
      child: Container(
        color: const Color(0xFFD5E1F2),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Onboard New Talent',
                          style: TextStyle(fontSize: 58 / 2, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.15),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Fill in the details below to grant system access\nto a new team member.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Color(0xFF3F4A5F), height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _formCard(
                        icon: Icons.badge_outlined,
                        title: 'Basic Information',
                        child: Column(
                          children: [
                            _input('Full Name', 'John Doe'),
                            _input('Contact Number', '+1 234 567 8900'),
                            Row(children: [Expanded(child: _input('Gender', 'MALE', isDrop: true)), const SizedBox(width: 10), Expanded(child: _input('Designation', 'Sales Executive'))]),
                            const SizedBox(height: 4),
                            const Align(alignment: Alignment.centerLeft, child: Text('Permissions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F)))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _PermissionChip(label: 'ADS_CREATE', selected: true),
                                _PermissionChip(label: 'BOOKING_LIST', selected: true),
                                _PermissionChip(label: 'PAYMENT_LIST', selected: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _formCard(
                        icon: Icons.lock_outline,
                        title: 'Login Information',
                        child: Column(
                          children: [
                            _input('Phone Number (Login ID)', '017XXXXXXXX'),
                            _input('Email Address', 'john@example.com'),
                            _input('Password', 'Demo@123', eye: true),
                            _input('Confirm Password', 'Demo@123', eye: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4ACD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Create Staff Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF9EB7E3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0C4ACD))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _formCard({required IconData icon, required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFDCE2F7))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: const Color(0xFF0C4ACD), size: 23), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))]), const SizedBox(height: 16), child]),
  );

  Widget _input(String label, String placeholder, {bool isDrop = false, bool eye = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F))),
      const SizedBox(height: 6),
      AppCustomInputField(
        hintText: placeholder,
        readOnly: true,
        obscureText: eye,
        suffixIcon: isDrop
            ? const Icon(Icons.expand_more, color: Color(0xFF6B7280))
            : eye
                ? const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280))
                : null,
      ),
    ]),
  );

}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE9F0FF) : const Color(0xFFE6EBF6),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: selected ? const Color(0xFF0C4ACD) : const Color(0xFFB9C2D3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: selected ? const Color(0xFF0C4ACD) : const Color(0xFFC7CDD8)), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 15, color: selected ? const Color(0xFF0C4ACD) : const Color(0xFF222938), fontWeight: FontWeight.w500))]),
    );
  }
}

