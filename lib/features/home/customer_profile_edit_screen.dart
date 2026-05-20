import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/services/location_service.dart';
import '../../common/services/profile_service.dart';
import '../../common/theme/app_palette.dart';

class CustomerProfileEditScreen extends StatefulWidget {
  const CustomerProfileEditScreen({super.key});

  @override
  State<CustomerProfileEditScreen> createState() => _CustomerProfileEditScreenState();
}

class _CustomerProfileEditScreenState extends State<CustomerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final LocationService _locationService = LocationService();
  final ImagePicker _imagePicker = ImagePicker();

  final _agencyNameController = TextEditingController();
  final _agencyPhoneController = TextEditingController();
  final _agencyAddressController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _routingNoController = TextEditingController();
  final _rlNoController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  List<DistrictOption> _districts = [];
  List<PoliceStationOption> _policeStations = [];
  int? _selectedDistrictId;
  int? _selectedPoliceStationId;

  String? _existingProfileImageUrl;
  String? _existingNidImageUrl;
  String? _existingTradeLicenseUrl;
  String? _existingRlLicenseUrl;
  String? _existingCivilAviationLicenseUrl;

  XFile? _profileImage;
  XFile? _nidImage;
  XFile? _nidBackImage; // Local mock storage for back NID
  XFile? _tradeLicenseImage;
  XFile? _rlLicenseImage;
  XFile? _civilAviationLicenseImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final districts = await _locationService.getDistricts();
      if (!mounted) return;
      _districts = districts;

      final profile = await _profileService.getAgencyProfile();
      if (!mounted) return;
      if (profile == null) {
        setState(() {
          _error = 'Failed to load profile data.';
          _isLoading = false;
        });
        return;
      }

      final bank = profile.bankInformation.isNotEmpty ? profile.bankInformation.first : null;
      final doc = profile.documents.isNotEmpty ? profile.documents.first : null;

      setState(() {
        _existingProfileImageUrl = profile.image;
        _existingNidImageUrl = doc?.nidImage;
        _existingTradeLicenseUrl = doc?.tradeLicenseImage;
        _existingRlLicenseUrl = doc?.rlLicenseImage;
        _existingCivilAviationLicenseUrl = doc?.civilAviationLicenseImage;

        _agencyNameController.text = profile.agencyName;
        _agencyPhoneController.text = profile.agencyPhone ?? profile.owner?.phone ?? '';
        _agencyAddressController.text = profile.agencyAddress ?? '';
        _bankNameController.text = bank?.bankName ?? '';
        _branchNameController.text = bank?.branchName ?? '';
        _accountNameController.text = bank?.accountName ?? '';
        _accountNoController.text = bank?.accountNo ?? '';
        _routingNoController.text = bank?.routingNo ?? '';
        _rlNoController.text = doc?.rlNo ?? '';
      });

      if (profile.district != null) {
        final matchedDistrict = districts.where((d) =>
          (profile.district!.id != null && d.id == int.tryParse(profile.district!.id.toString())) ||
          (d.name.toLowerCase() == profile.district!.name.toLowerCase())
        ).toList();

        if (matchedDistrict.isNotEmpty) {
          _selectedDistrictId = matchedDistrict.first.id;
          _policeStations = await _locationService.getPoliceStations(_selectedDistrictId!);

          if (profile.policeStation != null) {
            final matchedPs = _policeStations.where((p) =>
              (profile.policeStation!.id != null && p.id == int.tryParse(profile.policeStation!.id.toString())) ||
              (p.name.toLowerCase() == profile.policeStation!.name.toLowerCase())
            ).toList();
            if (matchedPs.isNotEmpty) {
              _selectedPoliceStationId = matchedPs.first.id;
            }
          }
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred while loading details.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onDistrictChanged(int? districtId) async {
    setState(() {
      _selectedDistrictId = districtId;
      _selectedPoliceStationId = null;
      _policeStations = [];
    });
    if (districtId == null) return;
    final stations = await _locationService.getPoliceStations(districtId);
    if (!mounted) return;
    setState(() => _policeStations = stations);
  }

  Future<void> _pickImage(ValueChanged<XFile?> onPicked) async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted || file == null) return;
    onPicked(file);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final map = <String, dynamic>{
        'agencyName': _agencyNameController.text.trim(),
        'agencyPhone': _agencyPhoneController.text.trim(),
        'agencyAddress': _agencyAddressController.text.trim(),
        if (_selectedDistrictId != null) 'district': _selectedDistrictId,
        if (_selectedPoliceStationId != null) 'policeStation': _selectedPoliceStationId,
        'bankInformation.bankName': _bankNameController.text.trim(),
        'bankInformation.branchName': _branchNameController.text.trim(),
        'bankInformation.accountName': _accountNameController.text.trim(),
        'bankInformation.accountNo': _accountNoController.text.trim(),
        'bankInformation.routingNo': _routingNoController.text.trim(),
        'documents.rlNo': _rlNoController.text.trim(),
      };

      if (_profileImage != null) map['image'] = await MultipartFile.fromFile(_profileImage!.path);
      if (_nidImage != null) map['documents.nidImage'] = await MultipartFile.fromFile(_nidImage!.path);
      if (_tradeLicenseImage != null) map['documents.tradeLicenseImage'] = await MultipartFile.fromFile(_tradeLicenseImage!.path);
      if (_rlLicenseImage != null) map['documents.rlLicenseImage'] = await MultipartFile.fromFile(_rlLicenseImage!.path);
      if (_civilAviationLicenseImage != null) map['documents.civilAviationLicenseImage'] = await MultipartFile.fromFile(_civilAviationLicenseImage!.path);

      final updated = await _profileService.updateAgencyProfile(FormData.fromMap(map));
      if (!mounted) return;
      setState(() => _isSaving = false);

      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _agencyPhoneController.dispose();
    _agencyAddressController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _accountNameController.dispose();
    _accountNoController.dispose();
    _routingNoController.dispose();
    _rlNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _error != null && !_isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppPalette.danger, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(backgroundColor: AppPalette.brandBlue, foregroundColor: Colors.white),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              )
            : Skeletonizer(
                enabled: _isLoading,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfilePhotoHeader(),
                        
                        // Card 1: Agency Details
                        _buildSectionCard(
                          title: 'Agency Details',
                          icon: Icons.business_center,
                          children: [
                            _buildCustomTextField(
                              label: 'Agency Name',
                              controller: _agencyNameController,
                              icon: Icons.business,
                            ),
                            _buildCustomTextField(
                              label: 'Agency Phone',
                              controller: _agencyPhoneController,
                              icon: Icons.phone_android,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildCustomTextField(
                              label: 'Agency Address',
                              controller: _agencyAddressController,
                              icon: Icons.map,
                            ),
                          ],
                        ),

                        // Card 3: Location
                        _buildSectionCard(
                          title: 'Location',
                          icon: Icons.location_on,
                          children: [
                            _buildCustomDropdown<int>(
                              label: 'District',
                              value: _selectedDistrictId,
                              icon: Icons.my_location,
                              items: _districts.map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name))).toList(),
                              onChanged: _isLoading ? null : _onDistrictChanged,
                            ),
                            _buildCustomDropdown<int>(
                              label: 'Police Station',
                              value: _selectedPoliceStationId,
                              icon: Icons.local_police_outlined,
                              items: _policeStations.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name))).toList(),
                              onChanged: _isLoading ? null : (v) => setState(() => _selectedPoliceStationId = v),
                            ),
                          ],
                        ),

                        // Card 4: Bank Information
                        _buildSectionCard(
                          title: 'Bank Information',
                          icon: Icons.account_balance,
                          children: [
                            _buildCustomTextField(
                              label: 'Bank Name',
                              controller: _bankNameController,
                              icon: Icons.account_balance_outlined,
                            ),
                            _buildCustomTextField(
                              label: 'Branch Name',
                              controller: _branchNameController,
                              icon: Icons.door_sliding_outlined,
                            ),
                            _buildCustomTextField(
                              label: 'Account Name',
                              controller: _accountNameController,
                              icon: Icons.account_box_outlined,
                            ),
                            _buildCustomTextField(
                              label: 'Account Number',
                              controller: _accountNoController,
                              icon: Icons.numbers_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            _buildCustomTextField(
                              label: 'Routing Number',
                              controller: _routingNoController,
                              icon: Icons.alt_route_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),

                        // Card 5: Documents
                        _buildSectionCard(
                          title: 'Documents',
                          icon: Icons.description,
                          children: [
                            _buildCustomTextField(
                              label: 'RL Number',
                              controller: _rlNoController,
                              icon: Icons.gavel_outlined,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'NID Verification',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.textMuted),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildNidCard(
                                  label: 'NID Front Side',
                                  localFile: _nidImage,
                                  existingUrl: _existingNidImageUrl,
                                  onTap: () => _pickImage((v) => setState(() => _nidImage = v)),
                                ),
                                const SizedBox(width: 12),
                                _buildNidCard(
                                  label: 'NID Back Side',
                                  localFile: _nidBackImage,
                                  existingUrl: null,
                                  onTap: () => _pickImage((v) => setState(() => _nidBackImage = v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Licenses & Certificates',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.textMuted),
                            ),
                            const SizedBox(height: 10),
                            _buildLicenseGrid(),
                            const SizedBox(height: 10),
                          ],
                        ),

                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfilePhotoHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: AppPalette.cardShadow,
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color(0xFFEFF6FF),
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : (_existingProfileImageUrl != null && _existingProfileImageUrl!.isNotEmpty
                            ? NetworkImage(_existingProfileImageUrl!)
                            : const AssetImage('assets/img/sign-in/login.jpg')) as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pickImage((v) => setState(() => _profileImage = v)),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppPalette.brandBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.brandBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _pickImage((v) => setState(() => _profileImage = v)),
              child: const Text(
                'Change Photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.brandBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppPalette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppPalette.brandBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppPalette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.textMuted),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ?? (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppPalette.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppPalette.textMuted, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.borderNeutral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.brandBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.danger, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required IconData icon,
    required ValueChanged<T?>? onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.textMuted),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator ?? (v) => v == null ? '$label is required' : null,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppPalette.textPrimary),
          icon: const Icon(Icons.arrow_drop_down, color: AppPalette.textMuted),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppPalette.textMuted, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.borderNeutral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.brandBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.danger, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNidCard({
    required String label,
    required XFile? localFile,
    required String? existingUrl,
    required VoidCallback onTap,
  }) {
    final hasFile = localFile != null || (existingUrl != null && existingUrl.isNotEmpty);
    final fileName = localFile != null 
        ? localFile.name 
        : (existingUrl != null ? existingUrl.split('/').last : '');

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: hasFile ? const Color(0xFFECFDF5) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFile ? const Color(0xFF10B981) : AppPalette.borderNeutral,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFile ? Icons.check_circle : Icons.upload_file,
                color: hasFile ? const Color(0xFF10B981) : AppPalette.textMuted,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasFile ? const Color(0xFF065F46) : AppPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  hasFile ? fileName : 'PNG, JPG (Max 5MB)',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: hasFile ? const Color(0xFF047857) : AppPalette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        if (isWide) {
          return Row(
            children: [
              _buildLicenseCard(
                label: 'Trade License',
                icon: Icons.verified_user,
                localFile: _tradeLicenseImage,
                existingUrl: _existingTradeLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _tradeLicenseImage = v)),
              ),
              const SizedBox(width: 12),
              _buildLicenseCard(
                label: 'RL License',
                icon: Icons.badge,
                localFile: _rlLicenseImage,
                existingUrl: _existingRlLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _rlLicenseImage = v)),
              ),
              const SizedBox(width: 12),
              _buildLicenseCard(
                label: 'Civil Aviation',
                icon: Icons.flight,
                localFile: _civilAviationLicenseImage,
                existingUrl: _existingCivilAviationLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _civilAviationLicenseImage = v)),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLicenseCardWide(
                label: 'Trade License',
                icon: Icons.verified_user,
                localFile: _tradeLicenseImage,
                existingUrl: _existingTradeLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _tradeLicenseImage = v)),
              ),
              const SizedBox(height: 10),
              _buildLicenseCardWide(
                label: 'RL License',
                icon: Icons.badge,
                localFile: _rlLicenseImage,
                existingUrl: _existingRlLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _rlLicenseImage = v)),
              ),
              const SizedBox(height: 10),
              _buildLicenseCardWide(
                label: 'Civil Aviation License',
                icon: Icons.flight,
                localFile: _civilAviationLicenseImage,
                existingUrl: _existingCivilAviationLicenseUrl,
                onTap: () => _pickImage((v) => setState(() => _civilAviationLicenseImage = v)),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildLicenseCard({
    required String label,
    required IconData icon,
    required XFile? localFile,
    required String? existingUrl,
    required VoidCallback onTap,
  }) {
    final hasFile = localFile != null || (existingUrl != null && existingUrl.isNotEmpty);
    final fileName = localFile != null 
        ? localFile.name 
        : (existingUrl != null ? existingUrl.split('/').last : 'Not Uploaded');

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 95,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFile ? const Color(0xFF3B82F6).withOpacity(0.3) : AppPalette.borderNeutral,
              width: 1.2,
            ),
            boxShadow: AppPalette.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: AppPalette.brandBlue, size: 18),
                  const Icon(Icons.edit, color: AppPalette.textMuted, size: 13),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseCardWide({
    required String label,
    required IconData icon,
    required XFile? localFile,
    required String? existingUrl,
    required VoidCallback onTap,
  }) {
    final hasFile = localFile != null || (existingUrl != null && existingUrl.isNotEmpty);
    final fileName = localFile != null 
        ? localFile.name 
        : (existingUrl != null ? existingUrl.split('/').last : 'Not Uploaded');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF3B82F6).withOpacity(0.3) : AppPalette.borderNeutral,
            width: 1.2,
          ),
          boxShadow: AppPalette.softShadow,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppPalette.brandBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: AppPalette.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 32),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.brandBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppPalette.brandBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
