import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/services/auth_service.dart';
import '../../common/services/location_service.dart';
import '../../routes/app_routes.dart';

class AgentSignUpScreen extends StatefulWidget {
  const AgentSignUpScreen({super.key});

  @override
  State<AgentSignUpScreen> createState() => _AgentSignUpScreenState();
}

class _AgentSignUpScreenState extends State<AgentSignUpScreen> {
  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandNavy = Color(0xFF0F172A);

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _locationService = LocationService();
  final _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _agencyNameController = TextEditingController();
  final _agencyAddressController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  DistrictOption? _selectedDistrict;
  PoliceStationOption? _selectedPoliceStation;

  List<DistrictOption> _districts = const [];
  List<PoliceStationOption> _policeStations = const [];

  XFile? _profileImage;
  XFile? _nidImage;
  XFile? _tradeLicenseImage;

  bool _agreeTerms = false;
  bool _loading = false;
  bool _locationsLoading = false;

  final List<String> _genderOptions = const ['MALE', 'FEMALE', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _agencyNameController.dispose();
    _agencyAddressController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _refreshFormData() async {
    await _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() => _locationsLoading = true);
    final districts = await _locationService.getDistricts();
    if (!mounted) return;
    setState(() {
      _districts = districts;
      if (_selectedDistrict != null) {
        final exists = _districts.any((d) => d.id == _selectedDistrict!.id);
        if (!exists) {
          _selectedDistrict = null;
          _selectedPoliceStation = null;
          _policeStations = [];
        }
      }
      _locationsLoading = false;
    });
  }

  Future<void> _loadPoliceStations(int districtId) async {
    setState(() {
      _policeStations = [];
      _selectedPoliceStation = null;
      _locationsLoading = true;
    });
    final stations = await _locationService.getPoliceStations(districtId);
    if (!mounted) return;
    setState(() {
      _policeStations = stations;
      _locationsLoading = false;
    });
  }

  Future<void> _pickFile(ValueSetter<XFile?> setter) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => setter(picked));
  }

  Future<MultipartFile> _toMultipart(XFile file) async {
    return MultipartFile.fromFile(file.path, filename: file.name);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Privacy Policy and Terms.'),
        ),
      );
      return;
    }
    if (_selectedDistrict == null || _selectedPoliceStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select district and police station.'),
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and confirm password do not match.'),
        ),
      );
      return;
    }
    if (_profileImage == null ||
        _nidImage == null ||
        _tradeLicenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload photo, NID and trade license.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final formData = FormData.fromMap({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'isPrivacyTerms': _agreeTerms ? 'true' : 'false',
        'gender': _gender,
        'agencyName': _agencyNameController.text.trim(),
        'agencyAddress': _agencyAddressController.text.trim(),
        'address': _addressController.text.trim(),
        'district': _selectedDistrict!.id.toString(),
        'policeStation': _selectedPoliceStation!.id.toString(),
        'image': await _toMultipart(_profileImage!),
        'nid_image': await _toMultipart(_nidImage!),
        'trade_license_image': await _toMultipart(_tradeLicenseImage!),
      });

      await _authService.registerAgent(formData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful. Please verify OTP.'),
        ),
      );
      context.go(
        '${AppRoutes.otpVerify}?username=${Uri.encodeComponent(_emailController.text.trim())}&next=${Uri.encodeComponent(AppRoutes.agentSignUpThankYou)}',
      );
    } on DioException catch (e) {
      if (!mounted) return;
      String message = 'Registration failed. Please try again.';
      final data = e.response?.data;
      if (data is Map) {
        if (data['detail'] != null) {
          message = data['detail'].toString();
        } else if (data['message'] != null) {
          message = data['message'].toString();
        } else if (data['errors'] != null) {
          message = data['errors'].toString();
        }
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onRefresh: _refreshFormData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 980;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: _brandNavy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Create your agent account to continue.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Flex(
                              direction: isDesktop ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    children: [
                                      _sectionCard(
                                        icon: Icons.badge_outlined,
                                        title: 'Basic Information',
                                        subtitle: 'Personal and agency details',
                                        child: _grid(
                                          children: [
                                            _textField('Full Name', _fullNameController, hint: 'Enter your full name'),
                                            _dropdownField(
                                              label: 'Gender',
                                              value: _gender,
                                              items: _genderOptions,
                                              hint: 'Select gender',
                                              onChanged: (v) => setState(() => _gender = v),
                                            ),
                                            _textField('Agency Name', _agencyNameController, hint: 'Your registered business name', spanTwoColumns: true),
                                            _textField('Agency Address', _agencyAddressController, hint: 'Business location details...', maxLines: 2, spanTwoColumns: true),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _sectionCard(
                                        icon: Icons.location_on_outlined,
                                        title: 'Permanent Address',
                                        subtitle: 'Where you are permanently located',
                                        child: _grid(children: [
                                          _districtDropdown(),
                                          _policeStationDropdown(),
                                          _textField('Full Address', _addressController, hint: 'Street name, house number, etc.', maxLines: 3, spanTwoColumns: true),
                                        ]),
                                      ),
                                      const SizedBox(height: 20),
                                      _sectionCard(
                                        icon: Icons.lock_open_outlined,
                                        title: 'Login Information',
                                        subtitle: 'Credentials for your agent portal',
                                        child: _grid(children: [
                                          _textField('Email Address', _emailController, hint: 'agent@company.com'),
                                          _textField('Phone Number', _phoneController, hint: '+880 1XXX XXXXXX'),
                                          _textField('Password', _passwordController, hint: '••••••••', obscure: true),
                                          _textField('Confirm Password', _confirmPasswordController, hint: '••••••••', obscure: true),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 20 : 0, height: isDesktop ? 0 : 20),
                                SizedBox(
                                  width: isDesktop ? 360 : double.infinity,
                                  child: _documentCard(),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
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

  Widget _sectionCard({required IconData icon, required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x140F172A), blurRadius: 26, offset: Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _brandBlue.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _brandBlue),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _brandNavy)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ]),
        ]),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }

  Widget _documentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 26, offset: Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create Agent Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _brandNavy)),
        const SizedBox(height: 6),
        const Text('Upload required documents and submit your registration.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        const SizedBox(height: 22),
        _UploadBox(label: 'Profile Photo', fileName: _profileImage?.name, icon: Icons.add_a_photo_outlined, onTap: () => _pickFile((f) => _profileImage = f)),
        const SizedBox(height: 14),
        _UploadBox(label: 'NID (Both Sides)', fileName: _nidImage?.name, icon: Icons.badge_outlined, onTap: () => _pickFile((f) => _nidImage = f)),
        const SizedBox(height: 14),
        _UploadBox(label: 'Trade License', fileName: _tradeLicenseImage?.name, icon: Icons.verified_user_outlined, onTap: () => _pickFile((f) => _tradeLicenseImage = f)),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: _agreeTerms,
          onChanged: (v) => setState(() => _agreeTerms = v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('By signing up, I agree to the Privacy Policy and Terms & Conditions.', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(_loading ? 'Creating...' : 'Create Agent Account'),
          ),
        ),
      ]),
    );
  }

  Widget _grid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 2 : 1;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children.map((w) {
            final spanTwo = w is _SpanTwoColumn;
            if (spanTwo && columns > 1) {
              return SizedBox(width: constraints.maxWidth, child: w.child);
            }
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return SizedBox(width: width, child: w);
          }).toList(),
        );
      },
    );
  }

  Widget _textField(String label, TextEditingController controller, {String? hint, bool obscure = false, int maxLines = 1, bool spanTwoColumns = false}) {
    final field = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
      ),
    ]);
    return spanTwoColumns ? _SpanTwoColumn(field) : field;
  }

  Widget _districtDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('District', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 6),
      DropdownButtonFormField<DistrictOption>(
        value: _selectedDistrict,
        items: _districts.map((d) => DropdownMenuItem<DistrictOption>(value: d, child: Text(d.name))).toList(),
        onChanged: _locationsLoading ? null : (v) {
          if (v == null) return;
          setState(() => _selectedDistrict = v);
          _loadPoliceStations(v.id);
        },
        decoration: _dropdownDecoration('Select district'),
        validator: (v) => v == null ? 'Required' : null,
      ),
    ]);
  }

  Widget _policeStationDropdown() {
    final enabled = _policeStations.isNotEmpty && !_locationsLoading;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Police Station', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 6),
      DropdownButtonFormField<PoliceStationOption>(
        value: _selectedPoliceStation,
        items: _policeStations.map((ps) => DropdownMenuItem<PoliceStationOption>(value: ps, child: Text(ps.name))).toList(),
        onChanged: enabled ? (v) => setState(() => _selectedPoliceStation = v) : null,
        decoration: _dropdownDecoration(enabled ? 'Select police station' : 'Select district first'),
        validator: (v) => v == null ? 'Required' : null,
      ),
    ]);
  }

  Widget _dropdownField({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged, String hint = 'Select an option'}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: _dropdownDecoration(hint),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    ]);
  }

  InputDecoration _dropdownDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.label, required this.fileName, required this.icon, required this.onTap});

  final String label;
  final String? fileName;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      const SizedBox(height: 6),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid, width: 1.4),
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFF8FAFC),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(fileName ?? 'Tap to upload', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fileName == null ? const Color(0xFF64748B) : const Color(0xFF0F172A))),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _SpanTwoColumn extends StatelessWidget {
  const _SpanTwoColumn(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}
