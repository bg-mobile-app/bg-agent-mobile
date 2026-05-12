import 'package:flutter/material.dart';

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
              _topBar(),
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
                            _input('Full Name', 'e.g. Tanvir Ahmed'),
                            _input('Contact Number', '+880 1XXX XXXXXX'),
                            Row(children: [Expanded(child: _input('Gender', 'Select Gender', isDrop: true)), const SizedBox(width: 10), Expanded(child: _input('Designation', 'e.g. Sales Executive'))]),
                            const SizedBox(height: 4),
                            const Align(alignment: Alignment.centerLeft, child: Text('Permissions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F)))),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _PermissionChip(label: 'Ads Create'),
                                _PermissionChip(label: 'Booking List'),
                                _PermissionChip(label: 'User Management', selected: true),
                                _PermissionChip(label: 'Billing Access'),
                                _PermissionChip(label: 'Support'),
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
                            _input('Phone Number (Login ID)', '01XXX XXXXXX'),
                            _input('Email Address', 'staff@agency.com'),
                            _input('Password', '••••••••', eye: true),
                            _input('Confirm Password', '••••••••', eye: true),
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
              _bottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: const BoxDecoration(color: Color(0xFFF8FAFF), border: Border(bottom: BorderSide(color: Color(0xFFC3CBD8)))),
    child: Row(children: const [Icon(Icons.arrow_back, color: Color(0xFF0C4ACD)), SizedBox(width: 12), Expanded(child: Text('Create Staff Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0C4ACD)))), CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB4C_yfcbuUkHE1nowmxJuGZdInPZQlkq_zjFa7ZzmzezaQGvThG9oX4RhQI2Gxv-uo1t_CnZDcd7192BS1MS98SPYKCj7C-jEB4127cPkjXDMi4Jd0B4q4RmtH1sOwUFjRl5GbFmpfZW77V_MgU70AVhHmA92O074NiPtALV3ANXrp2prlkALWBVA5KKn7Vh2LaLuYn8bgSwlefcMGz3X1kkZltTs0_60KBD2aHvkFdi8aPgmTtgZ4Sq1XKreHWNiJPaqllDIwv_o'))]),
  );

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
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFD), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFB5BECF))),
        child: Row(children: [Expanded(child: Text(placeholder, style: TextStyle(fontSize: 16, color: placeholder.contains('•') ? const Color(0xFF6B7280) : const Color(0xFFA3A8B3)))), if (isDrop) const Icon(Icons.expand_more, color: Color(0xFF6B7280)), if (eye) const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280))]),
      ),
    ]),
  );

  Widget _bottomNav() => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: const BoxDecoration(color: Color(0xFFF8FAFF), border: Border(top: BorderSide(color: Color(0xFFC3CBD8)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
      _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
      _NavItem(icon: Icons.add_circle, label: 'Create', active: true),
      _NavItem(icon: Icons.payments_outlined, label: 'Payments'),
      _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
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

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.active = false});
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: active ? 14 : 8, vertical: 2),
      decoration: active ? BoxDecoration(color: const Color(0xFFDBE7FF), borderRadius: BorderRadius.circular(999)) : null,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF2E3547), size: 25), const SizedBox(height: 1), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF232B3A)))]),
    );
  }
}
