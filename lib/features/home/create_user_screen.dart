import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_custom_input_field.dart';
import 'dashboard_screen.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _fullNameController = TextEditingController(text: 'John Doe');
  final _contactNoController = TextEditingController(text: '+1 234 567 8900');
  final _designationController = TextEditingController(text: 'Sales Executive');
  final _phoneController = TextEditingController(text: '017XXXXXXXX');
  final _emailController = TextEditingController(text: 'john@example.com');
  final _passwordController = TextEditingController(text: 'Demo@123');
  final _confirmPasswordController = TextEditingController(text: 'Demo@123');

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];
  String _selectedGender = 'MALE';

  final List<String> _allPermissions = [
    'ADS_CREATE',
    'ADS_LIST',
    'BOOKING_LIST',
    'RETURN_LIST',
    'OUR_BOOKING',
    'APPOINTMENT_LIST',
    'USER',
    'REMINDER_LIST',
    'CHECK_STATUS',
    'COMMISSION',
    'PAYMENT_LIST',
    'RECEIVE_PAYMENT_LIST',
    'REFUND_PAYMENT',
  ];
  final Set<String> _selectedPermissions = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNoController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                      _breadcrumb(),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Onboard New Talent',
                          style: AppTextStyles.headline2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Fill in the details below to grant system access\nto a new team member.',
                        textAlign: TextAlign.left,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 18),
                      _formCard(
                        icon: Icons.badge_outlined,
                        title: 'Basic Information',
                        child: Column(
                          children: [
                            _input('Full Name', 'John Doe', controller: _fullNameController),
                            _input('Contact Number', '+1 234 567 8900', controller: _contactNoController),
                            Row(
                              children: [
                                Expanded(child: _genderInput()),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _input(
                                    'Designation',
                                    'Sales Executive',
                                    controller: _designationController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(height: 4),
                            _permissionsInput(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _formCard(
                        icon: Icons.lock_outline,
                        title: 'Login Information',
                        child: Column(
                          children: [
                            _input('Phone Number (Login ID)', '017XXXXXXXX', controller: _phoneController),
                            _input('Email Address', 'john@example.com', controller: _emailController),
                            _input('Password', 'Demo@123', controller: _passwordController, eye: true),
                            _input('Confirm Password', 'Demo@123', controller: _confirmPasswordController, eye: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final payload = {
                              'fullName': _fullNameController.text,
                              'contactNo': _contactNoController.text,
                              'gender': _selectedGender,
                              'designation': _designationController.text,
                              'permissions': _selectedPermissions.toList(),
                              'phone': _phoneController.text,
                              'email': _emailController.text,
                              'password': _passwordController.text,
                              'password2': _confirmPasswordController.text,
                            };
                            debugPrint('Create User Payload: $payload');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C4ACD),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Create Staff Account',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            _fullNameController.text = 'John Doe';
                            _contactNoController.text = '+1 234 567 8900';
                            _designationController.text = 'Sales Executive';
                            _phoneController.text = '017XXXXXXXX';
                            _emailController.text = 'john@example.com';
                            _passwordController.text = 'Demo@123';
                            _confirmPasswordController.text = 'Demo@123';
                            setState(() {
                              _selectedGender = 'MALE';
                              _selectedPermissions
                                ..clear()
                                ..addAll(_allPermissions);
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF9EB7E3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0C4ACD)),
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
      ),
    );
  }

  Widget _formCard({required IconData icon, required String title, required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFDCE2F7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0C4ACD), size: 23),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: Text(
            'Dashboard',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Manage User',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Create User',
            style: AppTextStyles.caption.copyWith(
              color: AppPalette.textStrongBlue,
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

  Widget _genderInput() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gender',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F)),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBEAFE)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D2563EB),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedGender,
                  style: AppTextStyles.body2.copyWith(color: const Color(0xFF667085)),
                  icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                  items: _genders
                      .map(
                        (gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedGender = value);
                  },
                ),
              ),
            ),
          ],
        ),
      );

  Widget _permissionsInput() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F)),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBEAFE)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D2563EB),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    _selectedPermissions.isEmpty
                        ? 'Select permissions...'
                        : '${_selectedPermissions.length} permission(s) selected',
                    style: AppTextStyles.body2.copyWith(color: const Color(0xFF667085)),
                  ),
                  iconColor: const Color(0xFF6B7280),
                  collapsedIconColor: const Color(0xFF6B7280),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allPermissions
                            .map(
                              (permission) => _PermissionChip(
                                label: permission,
                                selected: _selectedPermissions.contains(permission),
                                onTap: () {
                                  setState(() {
                                    if (_selectedPermissions.contains(permission)) {
                                      _selectedPermissions.remove(permission);
                                    } else {
                                      _selectedPermissions.add(permission);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _input(
    String label,
    String placeholder, {
    required TextEditingController controller,
    bool eye = false,
  }) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F))),
          const SizedBox(height: 6),
          AppCustomInputField(
            hintText: placeholder,
            controller: controller,
            obscureText: eye,
            suffixIcon: eye ? const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280)) : null,
          ),
        ]),
      );
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9F0FF) : const Color(0xFFE6EBF6),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? const Color(0xFF0C4ACD) : const Color(0xFFB9C2D3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: selected ? const Color(0xFF0C4ACD) : const Color(0xFFC7CDD8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: selected ? const Color(0xFF0C4ACD) : const Color(0xFF222938),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
