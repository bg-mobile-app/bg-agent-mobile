import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/services/auth_service.dart';
import '../../common/services/location_service.dart';
import '../../routes/app_routes.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({super.key});

  @override
  State<CustomerSignUpScreen> createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  // ─── Theme ────────────────────────────────────────────────────────────────
  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandNavy = Color(0xFF0F172A);

  // ─── Services ─────────────────────────────────────────────────────────────
  final _authService = AuthService();
  final _locationService = LocationService();

  // ─── Form ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes for error-scroll
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _addressFocus = FocusNode();

  // ─── State ────────────────────────────────────────────────────────────────
  String? _selectedGender;
  DistrictOption? _selectedDistrict;
  PoliceStationOption? _selectedPoliceStation;
  bool _agreeTerms = false;
  bool _loading = false;
  bool _locationsLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  List<DistrictOption> _districts = [];
  List<PoliceStationOption> _policeStations = [];

  Map<String, String> _fieldErrors = {};

  final List<String> _genderOptions = const ['MALE', 'FEMALE', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  // ─── Location loading ─────────────────────────────────────────────────────

  Future<void> _loadDistricts() async {
    setState(() => _locationsLoading = true);
    try {
      final districts = await _locationService.getDistricts();
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _locationsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _locationsLoading = false);
    }
  }

  Future<void> _loadPoliceStations(int districtId) async {
    setState(() {
      _policeStations = [];
      _selectedPoliceStation = null;
      _locationsLoading = true;
    });
    try {
      final stations =
          await _locationService.getPoliceStations(districtId);
      if (!mounted) return;
      setState(() {
        _policeStations = stations;
        _locationsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _locationsLoading = false);
    }
  }

  // ─── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _brandBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      _birthDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Clear previous field errors
    setState(() => _fieldErrors.clear());

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      _showSnack('Please agree to Privacy Policy and Terms.');
      return;
    }

    if (_selectedGender == null) {
      _showSnack('Please select your gender.');
      return;
    }

    if (_selectedDistrict == null || _selectedPoliceStation == null) {
      _showSnack('Please select district and police station.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Password and confirm password do not match.');
      return;
    }

    setState(() => _loading = true);

    try {
      final payload = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'gender': _selectedGender,
        'dob': _birthDateController.text.trim(),
        'address': _addressController.text.trim(),
        'district': _selectedDistrict!.id,
        'policeStation': _selectedPoliceStation!.id,
        'isPrivacyTerms': true,
      };

      await _authService.registerCustomer(payload);
      if (!mounted) return;

      _showSnack('Registration successful. Please verify your OTP.');

      // Navigate → OTP → Thank You
      context.go(
        '${AppRoutes.otpVerify}'
        '?username=${Uri.encodeComponent(_emailController.text.trim())}'
        '&next=${Uri.encodeComponent(AppRoutes.customerSignUpThankYou)}',
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;

      if (data is Map) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          setState(() {
            errors.forEach((key, value) {
              final msg =
                  value is List ? value.join(', ') : value.toString();
              _fieldErrors[key.toString()] = msg;
            });
          });
          // Scroll to first error field
          if (_fieldErrors.containsKey('fullName')) {
            _fullNameFocus.requestFocus();
          } else if (_fieldErrors.containsKey('email')) {
            _emailFocus.requestFocus();
          } else if (_fieldErrors.containsKey('phone')) {
            _phoneFocus.requestFocus();
          } else if (_fieldErrors.containsKey('password')) {
            _passwordFocus.requestFocus();
          } else if (_fieldErrors.containsKey('address')) {
            _addressFocus.requestFocus();
          } else {
            _showSnack(_fieldErrors.values.first);
          }
          // Trigger re-validate so TextFormField inline errors appear
          _formKey.currentState!.validate();
          setState(() => _loading = false);
          return;
        }

        final msg = data['detail']?.toString() ??
            data['message']?.toString() ??
            data.toString();
        _showSnack(msg);
      } else if (data is String && data.isNotEmpty) {
        _showSnack(data);
      } else {
        _showSnack('Registration failed. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFEEF4FF)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDistricts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────
                        Center(
                          child: Image.asset(
                            'assets/img/logo/logo_black.png',
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Create a New Account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: _brandNavy,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Center(
                                  child: Text(
                                    'Welcome to Bideshgami — be our wonderful customer.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // ── Basic Information ────────────────────
                                _SectionHeading(
                                  icon: Icons.person_outline,
                                  label: 'Basic Information',
                                ),
                                const SizedBox(height: 14),
                                _ResponsiveGrid(children: [
                                  _buildTextField(
                                    label: 'Full Name',
                                    controller: _fullNameController,
                                    focusNode: _fullNameFocus,
                                    hint: 'John Doe',
                                    fieldKey: 'fullName',
                                  ),
                                  _buildDropdown(
                                    label: 'Gender',
                                    value: _selectedGender,
                                    items: _genderOptions
                                        .map((g) => DropdownMenuItem(
                                              value: g,
                                              child: Text(
                                                g[0] +
                                                    g.substring(1)
                                                        .toLowerCase(),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _selectedGender = v),
                                    validator: (_) =>
                                        _selectedGender == null
                                            ? 'Required'
                                            : null,
                                  ),
                                  _buildDateField(),
                                  _buildDistrictDropdown(),
                                  _buildPoliceStationDropdown(),
                                  _buildAddressField(),
                                ]),

                                const SizedBox(height: 28),

                                // ── Login Information ────────────────────
                                _SectionHeading(
                                  icon: Icons.lock_outline,
                                  label: 'Login Information',
                                ),
                                const SizedBox(height: 14),
                                _ResponsiveGrid(children: [
                                  _buildTextField(
                                    label: 'Email Address',
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    hint: 'you@example.com',
                                    fieldKey: 'email',
                                    keyboardType:
                                        TextInputType.emailAddress,
                                  ),
                                  _buildTextField(
                                    label: 'Phone Number',
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    hint: '01XXXXXXXXX',
                                    fieldKey: 'phone',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  _buildPasswordField(
                                    label: 'Password',
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    fieldKey: 'password',
                                    show: _showPassword,
                                    onToggle: () => setState(
                                        () => _showPassword = !_showPassword),
                                  ),
                                  _buildPasswordField(
                                    label: 'Confirm Password',
                                    controller: _confirmPasswordController,
                                    hint: 'Re-enter password',
                                    show: _showConfirmPassword,
                                    onToggle: () => setState(() =>
                                        _showConfirmPassword =
                                            !_showConfirmPassword),
                                    extraValidator: (v) {
                                      if (v != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ]),

                                const SizedBox(height: 28),

                                // ── Agreement + Submit ───────────────────
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 560),
                                    child: Column(
                                      children: [
                                        _TermsCheckbox(
                                          value: _agreeTerms,
                                          onChanged: (v) => setState(
                                              () => _agreeTerms =
                                                  v ?? false),
                                        ),
                                        const SizedBox(height: 18),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed:
                                                _loading ? null : _submit,
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor: _brandBlue,
                                              foregroundColor:
                                                  Colors.white,
                                              elevation: 0,
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                              ),
                                            ),
                                            child: _loading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Create Account',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Already have an account? ',
                                              style: TextStyle(
                                                  color:
                                                      Color(0xFF64748B)),
                                            ),
                                            GestureDetector(
                                              onTap: () => context
                                                  .go(AppRoutes.login),
                                              child: const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  color: _brandBlue,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
            ),
          ),
        ),
      ),
    );
  }

  // ─── Field builders ────────────────────────────────────────────────────────

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    String? fieldKey,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    final apiError =
        fieldKey != null ? _fieldErrors[fieldKey] : null;

    return _FieldWrapper(
      label: label,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (apiError != null) return apiError;
          return null;
        },
        decoration: _inputDeco(
          hint: hint,
          errorText: apiError,
        ),
        onChanged: (_) {
          if (apiError != null) {
            setState(() => _fieldErrors.remove(fieldKey));
          }
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? fieldKey,
    String hint = 'Enter password',
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? extraValidator,
  }) {
    final apiError =
        fieldKey != null ? _fieldErrors[fieldKey] : null;

    return _FieldWrapper(
      label: label,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !show,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (v.length < 8) return 'At least 8 characters';
          if (apiError != null) return apiError;
          return extraValidator?.call(v);
        },
        decoration: _inputDeco(
          hint: hint,
          errorText: apiError,
          suffixIcon: IconButton(
            icon: Icon(
              show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF94A3B8),
            ),
            onPressed: onToggle,
          ),
        ),
        onChanged: (_) {
          if (apiError != null && fieldKey != null) {
            setState(() => _fieldErrors.remove(fieldKey));
          }
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return _FieldWrapper(
      label: label,
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        validator: validator,
        decoration: _inputDeco(),
        items: items,
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return _FieldWrapper(
      label: 'District',
      child: DropdownButtonFormField<DistrictOption>(
        value: _selectedDistrict,
        hint: _locationsLoading
            ? const Text('Loading...')
            : const Text('Select District'),
        validator: (_) =>
            _selectedDistrict == null ? 'Required' : null,
        decoration: _inputDeco(),
        items: _districts
            .map(
              (d) => DropdownMenuItem(
                value: d,
                child: Text(d.name),
              ),
            )
            .toList(),
        onChanged: _locationsLoading
            ? null
            : (d) {
                setState(() => _selectedDistrict = d);
                if (d != null) _loadPoliceStations(d.id);
              },
      ),
    );
  }

  Widget _buildPoliceStationDropdown() {
    final disabled = _selectedDistrict == null || _locationsLoading;
    return _FieldWrapper(
      label: 'Police Station',
      child: DropdownButtonFormField<PoliceStationOption>(
        value: _selectedPoliceStation,
        hint: Text(
          disabled
              ? (_locationsLoading ? 'Loading...' : 'Select District first')
              : 'Select Police Station',
        ),
        validator: (_) =>
            _selectedPoliceStation == null ? 'Required' : null,
        decoration: _inputDeco(),
        items: _policeStations
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text(p.name),
              ),
            )
            .toList(),
        onChanged: disabled
            ? null
            : (p) => setState(() => _selectedPoliceStation = p),
      ),
    );
  }

  Widget _buildDateField() {
    return _FieldWrapper(
      label: 'Date of Birth',
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        onTap: _pickBirthDate,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: _inputDeco(
          hint: 'Select date of birth',
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    final apiError = _fieldErrors['address'];
    return _FieldWrapper(
      label: 'Full Address',
      child: TextFormField(
        controller: _addressController,
        focusNode: _addressFocus,
        maxLines: 3,
        maxLength: 500,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (apiError != null) return apiError;
          return null;
        },
        decoration: _inputDeco(
          hint: 'Enter your full address...',
          errorText: apiError,
        ),
        onChanged: (_) {
          if (apiError != null) {
            setState(() => _fieldErrors.remove('address'));
          }
        },
      ),
    );
  }

  InputDecoration _inputDeco({
    String? hint,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0BAC9), fontSize: 14),
      errorText: errorText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brandBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFFEF4444), width: 1.6),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}

class _FieldWrapper extends StatelessWidget {
  const _FieldWrapper({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          activeColor: _blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: onChanged,
        ),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree with Bideshgami ',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Terms & Conditions.',
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 640;

        if (!twoCol) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 16),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox(),
                ),
              ],
            ),
          );
          if (i + 2 < children.length) rows.add(const SizedBox(height: 14));
        }

        return Column(children: rows);
      },
    );
  }
}
