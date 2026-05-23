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

  Future<void> _loadDistricts() async {
    setState(() => _locationsLoading = true);
    final districts = await _locationService.getDistricts();
    if (!mounted) return;
    setState(() {
      _districts = districts;
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Agent Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Become A Bideshgami Agent',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Fill out the basic info. and get a chance to grow your business with us.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Basic Information'),
                      const SizedBox(height: 12),
                      _grid(
                        children: [
                          _textField(
                            'Full Name',
                            _fullNameController,
                            hint: 'John Doe',
                          ),
                          _dropdownField(
                            label: 'Select Your Gender',
                            value: _gender,
                            items: _genderOptions,
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                          _textField(
                            'Agency Name',
                            _agencyNameController,
                            hint: 'Enter Your Agency Name',
                          ),
                          _textField(
                            'Agency Address',
                            _agencyAddressController,
                            hint: 'Enter Your Agency Address',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle('Permanent Address'),
                      const SizedBox(height: 12),
                      _grid(
                        children: [
                          _districtDropdown(),
                          _policeStationDropdown(),
                          _textField(
                            'Enter Your Full Address',
                            _addressController,
                            hint: 'type agency address here...',
                            maxLines: 5,
                            helperText: 'Max 500 characters',
                            spanTwoColumns: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle('Login Information'),
                      const SizedBox(height: 12),
                      _grid(
                        children: [
                          _textField(
                            'Email Address',
                            _emailController,
                            hint: 'you@example.com',
                          ),
                          _textField(
                            'Phone Number',
                            _phoneController,
                            hint: '01XXXXXXXXX',
                          ),
                          _textField(
                            'Password',
                            _passwordController,
                            hint: 'Enter password',
                            obscure: true,
                          ),
                          _textField(
                            'Confirm Password',
                            _confirmPasswordController,
                            hint: 'Confirm password',
                            obscure: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _grid(
                        children: [
                          _UploadBox(
                            label: 'Upload Your Photo',
                            fileName: _profileImage?.name,
                            onTap: () => _pickFile((f) => _profileImage = f),
                          ),
                          _UploadBox(
                            label: 'Upload NID (With Both Side)',
                            fileName: _nidImage?.name,
                            onTap: () => _pickFile((f) => _nidImage = f),
                          ),
                          _UploadBox(
                            label: 'Upload Trade License',
                            fileName: _tradeLicenseImage?.name,
                            onTap: () =>
                                _pickFile((f) => _tradeLicenseImage = f),
                          ),
                        ],
                        columnsOverride: 3,
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        value: _agreeTerms,
                        onChanged: (v) =>
                            setState(() => _agreeTerms = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'By continue, I agree to the website Privacy Policy and Terms & Conditions.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            _loading ? 'Creating...' : 'Create Account',
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
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: Color(0xCC2563EB),
    ),
  );

  Widget _grid({required List<Widget> children, int? columnsOverride}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            columnsOverride ?? (constraints.maxWidth >= 700 ? 2 : 1);
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

  Widget _textField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool obscure = false,
    int maxLines = 1,
    String? helperText,
    bool spanTwoColumns = false,
  }) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
    return spanTwoColumns ? _SpanTwoColumn(field) : field;
  }

  Widget _districtDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('District *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<DistrictOption>(
          initialValue: _selectedDistrict,
          items: _districts
              .map(
                (d) => DropdownMenuItem<DistrictOption>(
                  value: d,
                  child: Text(d.name),
                ),
              )
              .toList(),
          onChanged: _locationsLoading
              ? null
              : (v) {
                  if (v == null) return;
                  setState(() => _selectedDistrict = v);
                  _loadPoliceStations(v.id);
                },
          decoration: const InputDecoration(
            hintText: 'Select district',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _policeStationDropdown() {
    final enabled = _policeStations.isNotEmpty && !_locationsLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Police Station *',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<PoliceStationOption>(
          initialValue: _selectedPoliceStation,
          items: _policeStations
              .map(
                (ps) => DropdownMenuItem<PoliceStationOption>(
                  value: ps,
                  child: Text(ps.name),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (v) => setState(() => _selectedPoliceStation = v)
              : null,
          decoration: InputDecoration(
            hintText: enabled
                ? 'Select police station'
                : 'Select district first',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String hint = 'Select an option',
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.label,
    required this.fileName,
    required this.onTap,
  });

  final String label;
  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFFF8FAFC),
            ),
            child: Text(fileName == null ? 'Choose file' : fileName!),
          ),
        ),
      ],
    );
  }
}

class _SpanTwoColumn extends StatelessWidget {
  const _SpanTwoColumn(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}
