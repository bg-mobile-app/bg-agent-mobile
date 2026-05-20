import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';
import 'services/staff_accounts_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key, this.userId});

  final String? userId;

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _staffAccountsService = StaffAccountsService();

  final _fullNameController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _designationController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER'];
  String _selectedGender = 'MALE';

  bool _isSubmitting = false;
  bool _isLoadingUser = false;

  bool get _isEditMode => widget.userId != null && widget.userId!.isNotEmpty;

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
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNoController.dispose();
    _designationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: _isEditMode ? '/dashboard/user/manage-user' : '/dashboard/user/create-user',
      child: Container(
        color: const Color(0xFFD5E1F2),
        child: SafeArea(
          child: Form(
            key: _formKey,
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_isEditMode ? 'Update Staff Account' : 'Onboard New Talent', style: AppTextStyles.headline2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isEditMode
                              ? 'Update the existing user details below.'
                              : 'Fill in the details below to grant system access\nto a new team member.',
                          textAlign: TextAlign.left,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 18),
                        _formCard(
                          icon: Icons.badge_outlined,
                          title: 'Basic Information',
                          child: Column(
                            children: [
                              _input('Full Name', 'John Doe', controller: _fullNameController, requiredField: true),
                              _input('Contact Number', '+1 234 567 8900', controller: _contactNoController, requiredField: true),
                              Row(
                                children: [
                                  Expanded(child: _genderInput()),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _input(
                                      'Designation',
                                      'Sales Executive',
                                      controller: _designationController,
                                      requiredField: true,
                                    ),
                                  ),
                                ],
                              ),
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
                              _input('Username (Optional)', 'john_doe', controller: _usernameController),
                              _input(
                                'Email Address',
                                'john@example.com',
                                controller: _emailController,
                                requiredField: true,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              _input('Password', 'Demo@123', controller: _passwordController, eye: true),
                              _input(
                                'Confirm Password',
                                'Demo@123',
                                controller: _confirmPasswordController,
                                eye: true,
                                validator: _validateConfirmPassword,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_isSubmitting || _isLoadingUser) ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C4ACD),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: (_isSubmitting || _isLoadingUser)
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    _isEditMode ? 'Update Staff Account' : 'Create Staff Account',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: (_isSubmitting || _isLoadingUser) ? null : _resetForm,
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
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_selectedPermissions.isEmpty) {
      _showMessage('Please select at least one permission.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEditMode) {
        await _staffAccountsService.updateRecruitingAgencyStaff(
          userId: widget.userId!,
          fullName: _fullNameController.text.trim(),
            contactNo: _contactNoController.text.trim(),
            gender: _selectedGender,
            designation: _designationController.text.trim(),
            permissions: _selectedPermissions.toList(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
        );
      } else {
        await _staffAccountsService.createRecruitingAgencyStaff(
          fullName: _fullNameController.text.trim(),
          contactNo: _contactNoController.text.trim(),
          gender: _selectedGender,
          designation: _designationController.text.trim(),
          permissions: _selectedPermissions.toList(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      }

      _showMessage(_isEditMode ? 'Staff account updated successfully.' : 'Staff account created successfully.');
      if (mounted) Navigator.of(context).maybePop();
    } catch (e, st) {
      debugPrint('CreateUserScreen submit error: $e\n$st');
      _showMessage(_isEditMode ? 'Failed to update staff account: $e' : 'Failed to create staff account: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }



  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);
    try {
      final data = await _staffAccountsService.getStaffDetails(widget.userId!);
      _fullNameController.text = (data['fullName'] ?? '').toString();
      _contactNoController.text = (data['contactNo'] ?? '').toString();
      _designationController.text = (data['designation'] ?? '').toString();
      _usernameController.text = (data['username'] ?? '').toString();
      _emailController.text = (data['email'] ?? '').toString();
      final gender = (data['gender'] ?? '').toString().toUpperCase();
      if (_genders.contains(gender)) _selectedGender = gender;
      final permissions = data['permissions'];
      if (permissions is List) {
        _selectedPermissions
          ..clear()
          ..addAll(permissions.map((e) => e.toString()));
      }
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('CreateUserScreen load user error for userId=${widget.userId}: $e\n$st');
      _showMessage('Failed to load user details: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _contactNoController.clear();
    _designationController.clear();
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedGender = 'MALE';
      _selectedPermissions.clear();
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email address';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_passwordController.text.isEmpty) return null;
    if ((value ?? '').isEmpty) return 'Please confirm password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
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
        BreadCrumbItem(content: Text('Dashboard', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
        BreadCrumbItem(content: Text('Manage User', style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted))),
        BreadCrumbItem(
          content: Text(
            _isEditMode ? 'Update User' : 'Create User',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textStrongBlue, fontWeight: FontWeight.w700),
          ),
        ),
      ],
      divider: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
    );
  }

  Widget _genderInput() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Gender', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDBEAFE)),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedGender,
                style: AppTextStyles.body2.copyWith(color: const Color(0xFF667085)),
                icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
                items: _genders.map((gender) => DropdownMenuItem<String>(value: gender, child: Text(gender))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedGender = value);
                },
              ),
            ),
          ),
        ]),
      );

  Widget _permissionsInput() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Permissions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDBEAFE)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  _selectedPermissions.isEmpty ? 'Select permissions...' : '${_selectedPermissions.length} permission(s) selected',
                  style: AppTextStyles.body2.copyWith(color: const Color(0xFF667085)),
                ),
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
        ]),
      );

  Widget _input(
    String label,
    String placeholder, {
    required TextEditingController controller,
    bool eye = false,
    bool requiredField = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3E4A5F))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: eye,
            validator: validator ??
                (requiredField
                    ? (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null
                    : null),
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0C4ACD))),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
              suffixIcon: eye ? const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280)) : null,
            ),
          ),
        ]),
      );
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, this.selected = false, this.onTap});

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
            Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: selected ? const Color(0xFF0C4ACD) : const Color(0xFFC7CDD8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: selected ? const Color(0xFF0C4ACD) : const Color(0xFF222938), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
