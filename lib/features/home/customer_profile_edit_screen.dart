import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/services/location_service.dart';
import '../../common/services/profile_service.dart';

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
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
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

  XFile? _profileImage;
  XFile? _nidImage;
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
        _agencyNameController.text = profile.agencyName;
        _agencyPhoneController.text = profile.owner?.phone ?? '';
        _agencyAddressController.text = profile.agencyAddress ?? '';
        _ownerNameController.text = profile.owner?.fullName ?? '';
        _ownerPhoneController.text = profile.owner?.phone ?? '';
        _ownerEmailController.text = profile.owner?.email ?? '';
        _bankNameController.text = bank?.bankName ?? '';
        _branchNameController.text = bank?.branchName ?? '';
        _accountNameController.text = bank?.accountName ?? '';
        _accountNoController.text = bank?.accountNo ?? '';
        _routingNoController.text = bank?.routingNo ?? '';
        _rlNoController.text = doc?.rlNo ?? '';
      });

      final matchedDistrict = districts.where((d) => d.name == profile.district?.name).toList();
      if (matchedDistrict.isNotEmpty) {
        _selectedDistrictId = matchedDistrict.first.id;
        _policeStations = await _locationService.getPoliceStations(_selectedDistrictId!);
        final matchedPs = _policeStations.where((p) => p.name == profile.policeStation?.name).toList();
        if (matchedPs.isNotEmpty) {
          _selectedPoliceStationId = matchedPs.first.id;
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
        'owner.fullName': _ownerNameController.text.trim(),
        'owner.phone': _ownerPhoneController.text.trim(),
        'owner.email': _ownerEmailController.text.trim(),
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
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: _error != null && !_isLoading
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)), const SizedBox(height: 12), ElevatedButton(onPressed: _loadData, child: const Text('Retry'))]))
            : Skeletonizer(
                enabled: _isLoading,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _field('Agency Name', _agencyNameController),
                      _field('Agency Phone', _agencyPhoneController),
                      _field('Agency Address', _agencyAddressController),
                      const SizedBox(height: 8),
                      const Text('Owner Information', style: TextStyle(fontWeight: FontWeight.bold)),
                      _field('Owner Full Name', _ownerNameController),
                      _field('Owner Phone', _ownerPhoneController),
                      _field('Owner Email', _ownerEmailController, keyboardType: TextInputType.emailAddress),
                      _districtDropdown(),
                      _policeStationDropdown(),
                      const SizedBox(height: 8),
                      const Text('Bank Information', style: TextStyle(fontWeight: FontWeight.bold)),
                      _field('Bank Name', _bankNameController),
                      _field('Branch Name', _branchNameController),
                      _field('Account Name', _accountNameController),
                      _field('Account Number', _accountNoController),
                      _field('Routing Number', _routingNoController),
                      const SizedBox(height: 8),
                      const Text('Documents', style: TextStyle(fontWeight: FontWeight.bold)),
                      _field('RL Number', _rlNoController),
                      _imagePickerTile('Profile Image', _profileImage, () => _pickImage((v) => setState(() => _profileImage = v))),
                      _imagePickerTile('NID Image', _nidImage, () => _pickImage((v) => setState(() => _nidImage = v))),
                      _imagePickerTile('Trade License Image', _tradeLicenseImage, () => _pickImage((v) => setState(() => _tradeLicenseImage = v))),
                      _imagePickerTile('RL License Image', _rlLicenseImage, () => _pickImage((v) => setState(() => _rlLicenseImage = v))),
                      _imagePickerTile('Civil Aviation License Image', _civilAviationLicenseImage, () => _pickImage((v) => setState(() => _civilAviationLicenseImage = v))),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: Text(_isSaving ? 'Saving...' : 'Update Profile'),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _imagePickerTile(String label, XFile? file, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFD1D5DB))),
        title: Text(label),
        subtitle: Text(file?.name ?? 'No file selected'),
        trailing: const Icon(Icons.upload_file),
        onTap: onTap,
      ),
    );
  }

  Widget _districtDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: _selectedDistrictId,
        decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        items: _districts.map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name))).toList(),
        onChanged: _isLoading ? null : _onDistrictChanged,
        validator: (v) => v == null ? 'District is required' : null,
      ),
    );
  }

  Widget _policeStationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: _selectedPoliceStationId,
        decoration: const InputDecoration(labelText: 'Police Station', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        items: _policeStations.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name))).toList(),
        onChanged: _isLoading ? null : (v) => setState(() => _selectedPoliceStationId = v),
        validator: (v) => v == null ? 'Police Station is required' : null,
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      ),
    );
  }
}
