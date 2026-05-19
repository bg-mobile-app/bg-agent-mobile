import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  List<DistrictOption> _districts = [];
  List<PoliceStationOption> _policeStations = [];
  int? _selectedDistrictId;
  int? _selectedPoliceStationId;

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

      setState(() {
        _nameController.text = profile.owner?.fullName ?? '';
        _phoneController.text = profile.owner?.phone ?? '';
        _emailController.text = profile.owner?.email ?? '';
        _addressController.text = profile.agencyAddress ?? '';
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
    } catch (e) {
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
    try {
      final stations = await _locationService.getPoliceStations(districtId);
      if (!mounted) return;
      setState(() {
        _policeStations = stations;
      });
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final formData = FormData.fromMap({
        'owner_full_name': _nameController.text.trim(),
        'owner_phone': _phoneController.text.trim(),
        'owner_email': _emailController.text.trim(),
        'agency_address': _addressController.text.trim(),
        if (_selectedDistrictId != null) 'district': _selectedDistrictId,
        if (_selectedPoliceStationId != null) 'police_station': _selectedPoliceStationId,
      });

      final updated = await _profileService.updateAgencyProfile(formData);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: _error != null && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ),
              )
            : Skeletonizer(
                enabled: _isLoading,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field('Owner Full Name', _nameController),
                        _field('Owner Phone', _phoneController),
                        _field('Owner Email', _emailController),
                        _field('Agency Address', _addressController),
                        _districtDropdown(),
                        _policeStationDropdown(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_isSaving ? 'Saving...' : 'Update Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _districtDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: _selectedDistrictId,
        decoration: const InputDecoration(
          labelText: 'District',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
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
        decoration: const InputDecoration(
          labelText: 'Police Station',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        items: _policeStations.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name))).toList(),
        onChanged: _isLoading ? null : (v) => setState(() => _selectedPoliceStationId = v),
        validator: (v) => v == null ? 'Police Station is required' : null,
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}
