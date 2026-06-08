import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/services/api_exception.dart';
import '../../common/theme/app_palette.dart';
import 'services/create_ad_service.dart';
import '../search/models/work_permit_details.dart';
import 'dashboard_screen.dart';

class CreateAdFormScreen extends StatefulWidget {
  const CreateAdFormScreen({super.key, required this.isBangla, this.adId});

  final bool isBangla;
  final int? adId;

  @override
  State<CreateAdFormScreen> createState() => _CreateAdFormScreenState();
}

enum _CreateAdDateField { applicationDeadline, startDate, endDate }

class _DropdownExtraAction {
  const _DropdownExtraAction._();

  static const instance = _DropdownExtraAction._();
}

class _CreateAdFormScreenState extends State<CreateAdFormScreen> {
  final CreateAdService _createAdService = CreateAdService();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quotaController = TextEditingController();
  final TextEditingController _newWorkTypeController = TextEditingController();
  final TextEditingController _packagePriceController = TextEditingController();
  final TextEditingController _advancePriceController = TextEditingController();
  final TextEditingController _afterVisaController = TextEditingController();
  final TextEditingController _beforeFlightController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _currentStep = 0;
  bool _isLoadingMeta = false;
  bool _isLoadingExistingAd = false;
  bool _isPublishing = false;
  bool _showNewWorkTypeInput = false;
  bool _isSuggestingWorkType = false;
  List<CountryOption> _countries = [];
  List<WorkTypeOption> _workTypes = [];
  Object? _selectedCountryValue;
  int? _selectedWorkTypeId;
  String? _selectionType;
  DateTime? _applicationDeadline;
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _selectedImage;
  String _existingImageUrl = '';
  String _paymentSystem = 'AFTER_VISA_BEFORE_FLIGHT';

  static const List<String> _selectionTypes = [
    'Direct',
    'Delegate',
    'Zoom Interview',
    'Lottery',
  ];

  bool get _isEditMode => widget.adId != null;

  String _tr(String en, String bn) => widget.isBangla ? bn : en;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _packagePriceController.addListener(_handlePaymentInputChanged);
    _advancePriceController.addListener(_handlePaymentInputChanged);
    _afterVisaController.addListener(_handlePaymentInputChanged);
    _beforeFlightController.addListener(_handlePaymentInputChanged);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _quotaController.dispose();
    _newWorkTypeController.dispose();
    _packagePriceController.dispose();
    _advancePriceController.dispose();
    _afterVisaController.dispose();
    _beforeFlightController.dispose();
    super.dispose();
  }

  void _handlePaymentInputChanged() {
    if (mounted) setState(() {});
  }

  int _parseMoney(TextEditingController controller) {
    final normalized = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(normalized) ?? 0;
  }

  int get _packagePrice => _parseMoney(_packagePriceController);
  int get _advancePrice => _parseMoney(_advancePriceController);
  int get _afterVisaPrice => _parseMoney(_afterVisaController);
  int get _beforeFlightPrice => _parseMoney(_beforeFlightController);
  bool get _usesAdvancePayment =>
      _paymentSystem == 'ADVANCE_AFTER_VISA_BEFORE_FLIGHT';
  int get _paymentTotal =>
      (_usesAdvancePayment ? _advancePrice : 0) +
      _afterVisaPrice +
      _beforeFlightPrice;

  String _formatMoney(int value) {
    if (value == 0) return '0';
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  List<Map<String, dynamic>> get _paymentSteps {
    final steps = <Map<String, dynamic>>[];
    var sequence = 1;
    if (_usesAdvancePayment) {
      steps.add({
        'step': 'ADVANCE',
        'amount': _advancePrice,
        'sequence': sequence++,
      });
    }
    steps.add({
      'step': 'AFTER_VISA',
      'amount': _afterVisaPrice,
      'sequence': sequence++,
    });
    steps.add({
      'step': 'BEFORE_FLIGHT',
      'amount': _beforeFlightPrice,
      'sequence': sequence,
    });
    return steps;
  }

  bool _validatePaymentDetails() {
    if (_packagePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr('Package price is required', 'প্যাকেজ মূল্য আবশ্যক'),
          ),
        ),
      );
      return false;
    }
    if (_usesAdvancePayment && _advancePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr('Advance payment is required', 'অগ্রিম পেমেন্ট আবশ্যক'),
          ),
        ),
      );
      return false;
    }
    if (_afterVisaPrice <= 0 || _beforeFlightPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              'After Visa and Before Flight payments are required',
              'ভিসার পর এবং ফ্লাইটের আগে পেমেন্ট আবশ্যক',
            ),
          ),
        ),
      );
      return false;
    }
    if (_paymentTotal != _packagePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              'Payment steps total must match package price',
              'পেমেন্ট ধাপের মোট প্যাকেজ মূল্যের সমান হতে হবে',
            ),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingMeta = true;
      _isLoadingExistingAd = _isEditMode;
    });

    try {
      final results = await Future.wait<dynamic>([
        _createAdService.getCountries(),
        _createAdService.getWorkTypes(),
      ]);
      if (!mounted) return;
      setState(() {
        _countries = results[0] as List<CountryOption>;
        _workTypes = results[1] as List<WorkTypeOption>;
        _isLoadingMeta = false;
      });

      final adId = widget.adId;
      if (adId != null) {
        final details = await _createAdService.getAdDetails(adId);
        if (!mounted) return;
        _prefillForm(details);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? _tr(
                    'Failed to load ad data',
                    'বিজ্ঞাপনের তথ্য লোড করা যায়নি',
                  )
                : _tr(
                    'Failed to load form data',
                    'ফর্মের তথ্য লোড করা যায়নি',
                  ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMeta = false;
          _isLoadingExistingAd = false;
        });
      }
    }
  }

  void _prefillForm(WorkPermitDetails details) {
    var matchingCountry = _findCountry(details.countryName);
    if (matchingCountry == null && details.countryName.trim().isNotEmpty) {
      matchingCountry = CountryOption(
        value: details.countryName,
        name: details.countryName,
      );
      _countries = [..._countries, matchingCountry];
    }
    final detailsWorkType = details.workType;
    final workTypeId = detailsWorkType?.id ?? 0;
    if (detailsWorkType != null &&
        workTypeId > 0 &&
        !_workTypes.any((item) => item.id == workTypeId)) {
      _workTypes = [
        ..._workTypes,
        WorkTypeOption(id: workTypeId, name: detailsWorkType.name),
      ];
    }

    _jobTitleController.text = details.title;
    _descriptionController.text = details.description;
    _quotaController.text = details.quota > 0 ? details.quota.toString() : '';
    final packagePrice = details.packagePrice ?? details.customerPrice;
    _packagePriceController.text = packagePrice > 0
        ? packagePrice.toString()
        : '';
    _paymentSystem = details.paymentSystem.isNotEmpty
        ? details.paymentSystem
        : 'AFTER_VISA_BEFORE_FLIGHT';
    _advancePriceController.text = details.advancePrice > 0
        ? details.advancePrice.toString()
        : '';
    _afterVisaController.text = details.afterVisa > 0
        ? details.afterVisa.toString()
        : '';
    _beforeFlightController.text = details.beforeFlight > 0
        ? details.beforeFlight.toString()
        : '';
    for (final step in details.paymentSteps) {
      final normalized = step.name
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9]+'), '_');
      final amount = step.amount.toInt();
      if (amount <= 0) continue;
      if (normalized.contains('ADVANCE')) {
        _advancePriceController.text = amount.toString();
      } else if (normalized.contains('AFTER') && normalized.contains('VISA')) {
        _afterVisaController.text = amount.toString();
      } else if (normalized.contains('BEFORE') &&
          normalized.contains('FLIGHT')) {
        _beforeFlightController.text = amount.toString();
      }
    }

    setState(() {
      _selectedCountryValue = matchingCountry?.value;
      _selectedWorkTypeId = workTypeId > 0 ? workTypeId : null;
      _selectionType = _displaySelectionType(details.selectionType);
      _applicationDeadline = details.applicationDeadline;
      _startDate = details.startDate;
      _endDate = details.endDate;
      _existingImageUrl = details.image;
    });
  }

  CountryOption? _findCountry(String countryName) {
    final normalized = countryName.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final item in _countries) {
      if (item.name.trim().toLowerCase() == normalized ||
          item.code.trim().toLowerCase() == normalized ||
          item.value.toString().trim().toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }

  Future<void> _publishAd() async {
    final title = _jobTitleController.text.trim();
    final quota = int.tryParse(_quotaController.text.trim());
    final applicationDeadline = _formatDate(_applicationDeadline);

    if (_selectedCountryValue == null ||
        _selectedWorkTypeId == null ||
        _selectionType == null ||
        (!_isEditMode && _selectedImage == null) ||
        title.isEmpty ||
        quota == null ||
        applicationDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              _isEditMode
                  ? 'Please complete title, country, work type, selection method, quota and deadline'
                  : 'Please complete title, country, work type, selection method, quota, deadline and image',
              _isEditMode
                  ? 'পদের নাম, দেশ, কাজের ধরন, নির্বাচন পদ্ধতি, কোটা এবং শেষ তারিখ পূরণ করুন'
                  : 'পদের নাম, দেশ, কাজের ধরন, নির্বাচন পদ্ধতি, কোটা, শেষ তারিখ এবং ছবি পূরণ করুন',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _isPublishing = true);
    try {
      if (_isEditMode) {
        await _createAdService.updateAd(
          adId: widget.adId!,
          country: _apiCountryValue(),
          workTypeId: _selectedWorkTypeId!,
          title: title,
          description: _descriptionController.text.trim(),
          selectionType: _apiSelectionTypeValue(_selectionType!),
          quota: quota,
          applicationDeadline: applicationDeadline,
          packagePrice: _packagePrice,
          paymentSystem: _paymentSystem,
          paymentSteps: _paymentSteps,
          isBn: widget.isBangla,
          imagePath: _selectedImage?.path,
        );
      } else {
        await _createAdService.createAd(
          country: _apiCountryValue(),
          workTypeId: _selectedWorkTypeId!,
          title: title,
          description: _descriptionController.text.trim(),
          selectionType: _apiSelectionTypeValue(_selectionType!),
          quota: quota,
          applicationDeadline: applicationDeadline,
          packagePrice: _packagePrice,
          paymentSystem: _paymentSystem,
          paymentSteps: _paymentSteps,
          isBn: widget.isBangla,
          imagePath: _selectedImage!.path,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? _tr(
                    'Ad updated successfully',
                    'বিজ্ঞাপন সফলভাবে আপডেট হয়েছে',
                  )
                : _tr(
                    'Ad created successfully',
                    'বিজ্ঞাপন সফলভাবে তৈরি হয়েছে',
                  ),
          ),
        ),
      );
      _exitForm();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim().isNotEmpty
          ? e.message
          : _isEditMode
          ? _tr('Failed to update ad', 'বিজ্ঞাপন আপডেট করা যায়নি')
          : _tr('Failed to publish ad', 'বিজ্ঞাপন প্রকাশ করা যায়নি');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? _tr('Failed to update ad', 'বিজ্ঞাপন আপডেট করা যায়নি')
                : _tr('Failed to publish ad', 'বিজ্ঞাপন প্রকাশ করা যায়নি'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  void _exitForm() {
    if (context.canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(_isEditMode ? '/dashboard/ads/my' : '/dashboard/ads/create');
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _selectedImage = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('Failed to pick image', 'ছবি নির্বাচন করা যায়নি')),
        ),
      );
    }
  }

  bool get _requiresInterviewDates {
    return _selectionType == 'Delegate' || _selectionType == 'Zoom Interview';
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _apiCountryValue() {
    final selectedCountry = _selectedCountryOption();
    final countryCode = selectedCountry?.code.trim();
    if (countryCode != null && countryCode.isNotEmpty) {
      return countryCode.toUpperCase();
    }
    return _selectedCountryValue?.toString().trim() ?? '';
  }

  String _displaySelectionType(String value) {
    switch (value.trim().toUpperCase()) {
      case 'PUSHING':
      case 'DIRECT':
        return 'Direct';
      case 'DELEGATE':
        return 'Delegate';
      case 'ZOOM_INTERVIEW':
        return 'Zoom Interview';
      case 'LOTTERY':
        return 'Lottery';
    }
    return value;
  }

  String _apiSelectionTypeValue(String value) {
    switch (value) {
      case 'Direct':
        return 'PUSHING';
      case 'Delegate':
        return 'DELEGATE';
      case 'Zoom Interview':
        return 'ZOOM_INTERVIEW';
      case 'Lottery':
        return 'LOTTERY';
    }
    return value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '_');
  }

  Future<void> _pickFormDate({required _CreateAdDateField field}) async {
    final now = DateTime.now();
    DateTime? current;
    switch (field) {
      case _CreateAdDateField.applicationDeadline:
        current = _applicationDeadline;
        break;
      case _CreateAdDateField.startDate:
        current = _startDate;
        break;
      case _CreateAdDateField.endDate:
        current = _endDate;
        break;
    }
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: current ?? now,
    );
    if (picked == null) return;
    setState(() {
      switch (field) {
        case _CreateAdDateField.applicationDeadline:
          _applicationDeadline = picked;
          break;
        case _CreateAdDateField.startDate:
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
          break;
        case _CreateAdDateField.endDate:
          _endDate = picked;
          break;
      }
    });
  }

  CountryOption? _selectedCountryOption() {
    for (final item in _countries) {
      if (item.value == _selectedCountryValue) return item;
    }
    return null;
  }

  Widget _countryOptionLeading(CountryOption country, double size) {
    if (country.unicodeFlag.isNotEmpty) {
      return Text(country.unicodeFlag, style: TextStyle(fontSize: size * 0.86));
    }

    final emoji = _countryCodeToEmoji(country.code);
    if (emoji.isNotEmpty) {
      return Text(emoji, style: TextStyle(fontSize: size * 0.86));
    }

    final flag = country.flag.trim();
    if (flag.isNotEmpty && !flag.toLowerCase().endsWith('.svg')) {
      final image = flag.startsWith('http')
          ? Image.network(flag, fit: BoxFit.cover)
          : Image.asset(flag, fit: BoxFit.cover);
      return ClipOval(
        child: SizedBox(width: size, height: size, child: image),
      );
    }

    return Icon(
      Icons.flag_outlined,
      size: size,
      color: const Color(0xFF64748B),
    );
  }

  String _countryCodeToEmoji(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 2) return '';

    final first = normalized.codeUnitAt(0);
    final second = normalized.codeUnitAt(1);
    if (first < 65 || first > 90 || second < 65 || second > 90) return '';

    const regionalIndicatorOffset = 0x1F1E6 - 65;
    return String.fromCharCodes([
      first + regionalIndicatorOffset,
      second + regionalIndicatorOffset,
    ]);
  }

  WorkTypeOption? _selectedWorkTypeOption() {
    for (final item in _workTypes) {
      if (item.id == _selectedWorkTypeId) return item;
    }
    return null;
  }

  Future<void> _suggestWorkType() async {
    final name = _newWorkTypeController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSuggestingWorkType = true);
    try {
      final suggested = await _createAdService.suggestWorkType(name);
      if (!mounted) return;
      setState(() {
        if (suggested != null &&
            !_workTypes.any((item) => item.id == suggested.id)) {
          _workTypes = [..._workTypes, suggested];
        }
        if (suggested != null) {
          _selectedWorkTypeId = suggested.id;
        }
        _showNewWorkTypeInput = false;
        _newWorkTypeController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('Work type submitted', 'কাজের ধরন জমা হয়েছে')),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr('Failed to submit work type', 'কাজের ধরন জমা দেওয়া যায়নি'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSuggestingWorkType = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppPalette.brandBlue,
        systemNavigationBarDividerColor: AppPalette.brandBlue,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: DashboardPageScaffold(
        currentHref: '/dashboard/ads/create',
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              _topBar(),
              _progressBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
              _footerButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_isLoadingExistingAd) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildStep1ImageUpload();
      case 1:
        return _buildStep2BasicInfo();
      case 2:
        return _buildStep3PaymentBreakdown();
      case 3:
        return _buildStep4DetailedDescription();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _topBar() => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              _exitForm();
            }
          },
          child: const Icon(Icons.arrow_back, color: AppPalette.brandBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _isEditMode
                ? _tr('Edit Ad', 'বিজ্ঞাপন সম্পাদনা করুন')
                : _tr('Create New Ad', 'নতুন বিজ্ঞাপন তৈরি করুন'),
            style: const TextStyle(
              fontSize: 16,
              color: AppPalette.brandBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '${_tr('Step', 'ধাপ')} ${_currentStep + 1} ${_tr('of', 'এর')} 4',
          style: const TextStyle(
            fontSize: 13,
            color: AppPalette.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _progressBar() {
    return Container(
      height: 4,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / 4;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 0,
                top: 0,
                bottom: 0,
                width: stepWidth * (_currentStep + 1),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppPalette.brandBlue,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1ImageUpload() {
    return Container(
      key: const ValueKey(0),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppPalette.brandBlue.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 120,
                        width: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_existingImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _existingImageUrl,
                        height: 120,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_outlined,
                          color: AppPalette.brandBlue,
                          size: 48,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppPalette.brandBlue.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppPalette.brandBlue,
                        size: 32,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedImage == null && _existingImageUrl.isEmpty
                        ? _tr(
                            'Upload job poster or main image',
                            'কাজের পোস্টার বা প্রধান ছবি আপলোড করুন',
                          )
                        : _tr(
                            'Image selected. Tap to change',
                            'ছবি নির্বাচন করা হয়েছে। পরিবর্তন করতে ট্যাপ করুন',
                          ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '(PNG, JPG, WEBP, Max 2MB)',
                    style: TextStyle(fontSize: 12, color: AppPalette.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFEF3C7)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.report_problem_rounded,
                    color: Color(0xFFB45309),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('Important Instruction', 'গুরুত্বপূর্ণ নির্দেশনা'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tr(
                          'Do not include phone number/contact information in ads. Violation results in immediate post rejection.',
                          'বিজ্ঞাপনে ফোন নম্বর বা যোগাযোগের তথ্য অন্তর্ভুক্ত করবেন না। নিয়ম ভঙ্গ করলে পোস্ট বাতিল হবে।',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2BasicInfo() {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.brandBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppPalette.brandBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _tr('Basic Information', 'সাধারণ তথ্য'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildField(
            label: _tr('Job Title', 'পদের নাম'),
            hint: _tr('e.g. Electrician', 'উদাঃ ইলেকট্রিশিয়ান'),
            controller: _jobTitleController,
          ),
          const SizedBox(height: 24),
          _buildOptionDropdown<CountryOption>(
            label: _tr('Country', 'দেশ'),
            value: _selectedCountryOption(),
            hint: _isLoadingMeta
                ? _tr('Loading countries...', 'দেশ লোড হচ্ছে...')
                : _tr('Select Country', 'দেশ নির্বাচন করুন'),
            items: _countries,
            itemLabel: (item) => item.name,
            itemLeading: (item, size) => _countryOptionLeading(item, size),
            onChanged: (value) =>
                setState(() => _selectedCountryValue = value?.value),
          ),
          const SizedBox(height: 24),
          _buildOptionDropdown<WorkTypeOption>(
            label: _tr('Type of Work', 'কাজের ধরন'),
            value: _selectedWorkTypeOption(),
            hint: _isLoadingMeta
                ? _tr('Loading work types...', 'কাজের ধরন লোড হচ্ছে...')
                : _tr('Select Work Type', 'কাজের ধরন নির্বাচন করুন'),
            items: _workTypes,
            itemLabel: (item) => item.name,
            extraActionLabel: _tr(
              'Add new work type',
              'নতুন কাজের ধরন যোগ করুন',
            ),
            onExtraAction: () => setState(() => _showNewWorkTypeInput = true),
            onChanged: (value) {
              setState(() {
                _selectedWorkTypeId = value?.id;
                _showNewWorkTypeInput = false;
              });
            },
          ),
          if (_showNewWorkTypeInput) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildField(
                    label: _tr('New Work Type', 'নতুন কাজের ধরন'),
                    hint: _tr('Enter work type', 'কাজের ধরন লিখুন'),
                    controller: _newWorkTypeController,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSuggestingWorkType ? null : _suggestWorkType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.brandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSuggestingWorkType
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _tr('Add', 'যোগ করুন'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildOptionDropdown<String>(
            label: _tr('Selection Type', 'নির্বাচন পদ্ধতি'),
            value: _selectionType,
            hint: _tr('Select Selection Type', 'নির্বাচন পদ্ধতি নির্বাচন করুন'),
            items: _selectionTypes,
            itemLabel: (item) => item,
            onChanged: (value) {
              setState(() {
                _selectionType = value;
                if (!_requiresInterviewDates) {
                  _startDate = null;
                  _endDate = null;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          _buildField(
            label: _tr('Quota', 'কোটা'),
            hint: _tr('Number of open positions', 'খালি পদের সংখ্যা'),
            controller: _quotaController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildDateField(
            label: _tr('Application Deadline', 'আবেদনের শেষ তারিখ'),
            value: _applicationDeadline,
            hint: _tr(
              'Select application deadline',
              'আবেদনের শেষ তারিখ নির্বাচন করুন',
            ),
            onTap: () =>
                _pickFormDate(field: _CreateAdDateField.applicationDeadline),
          ),
          if (_requiresInterviewDates) ...[
            const SizedBox(height: 24),
            _buildDateField(
              label: _tr('Interview Start Date', 'ইন্টারভিউ শুরুর তারিখ'),
              value: _startDate,
              hint: _tr(
                'Select interview start date',
                'ইন্টারভিউ শুরুর তারিখ নির্বাচন করুন',
              ),
              onTap: () => _pickFormDate(field: _CreateAdDateField.startDate),
            ),
            const SizedBox(height: 24),
            _buildDateField(
              label: _tr('Interview End Date', 'ইন্টারভিউ শেষের তারিখ'),
              value: _endDate,
              hint: _tr(
                'Select interview end date',
                'ইন্টারভিউ শেষের তারিখ নির্বাচন করুন',
              ),
              onTap: () => _pickFormDate(field: _CreateAdDateField.endDate),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3PaymentBreakdown() {
    return Container(
      key: const ValueKey(2),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.brandBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppPalette.brandBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _tr('Package Price Details', 'প্যাকেজ মূল্যের বিবরণ'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentInfoBox(
            icon: Icons.info_outline,
            title: _tr('Important Instruction', 'গুরুত্বপূর্ণ নির্দেশনা'),
            message: _tr(
              'Enter every numerical payment value using English digits only.',
              'সব সংখ্যাগত পেমেন্ট মান শুধুমাত্র ইংরেজি সংখ্যায় লিখুন।',
            ),
            background: const Color(0xFFEFF1FC),
            border: const Color(0xFFE0E5F5),
            iconBackground: AppPalette.brandBlue,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppPalette.brandBlue,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.brandBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('PACKAGE PRICE *', 'প্যাকেজ মূল্য *'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _packagePriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: '450000',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BDT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentSystemDropdown(),
          const SizedBox(height: 20),
          _buildPaymentInfoBox(
            icon: Icons.report_problem_rounded,
            title: _tr('Commission Warning', 'কমিশন সতর্কতা'),
            message: _tr(
              'An additional 10% for customers and 5% for agents will be added to the final cost automatically.',
              'চূড়ান্ত খরচে গ্রাহকদের জন্য অতিরিক্ত ১০% এবং এজেন্টদের জন্য ৫% স্বয়ংক্রিয়ভাবে যোগ হবে।',
            ),
            background: const Color(0xFFFFFBEB),
            border: const Color(0xFFFEF3C7),
            iconBackground: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFB45309),
          ),
          const SizedBox(height: 24),
          _buildPaymentStepsGrid(),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoBox({
    required IconData icon,
    required String title,
    required String message,
    required Color background,
    required Color border,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppPalette.textMuted,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSystemDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('PAYMENT SYSTEM *', 'পেমেন্ট সিস্টেম *'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _paymentSystem,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'ADVANCE_AFTER_VISA_BEFORE_FLIGHT',
                  child: Text(
                    _tr(
                      'Advance + After Visa + Before Flight',
                      'অগ্রিম + ভিসার পর + ফ্লাইটের আগে',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'AFTER_VISA_BEFORE_FLIGHT',
                  child: Text(
                    _tr(
                      'After Visa + Before Flight',
                      'ভিসার পর + ফ্লাইটের আগে',
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _paymentSystem = value);
                if (!_usesAdvancePayment) _advancePriceController.clear();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStepsGrid() {
    final rows = <Widget>[];
    if (_usesAdvancePayment) {
      rows.add(
        _buildPaymentStepRow(
          _tr('Advance Payment', 'অগ্রিম পেমেন্ট'),
          _advancePriceController,
        ),
      );
    }
    rows.addAll([
      _buildPaymentStepRow(
        _tr('After Visa Payment', 'ভিসার পর পেমেন্ট'),
        _afterVisaController,
      ),
      _buildPaymentStepRow(
        _tr('Before Flight Payment', 'ফ্লাইটের আগে পেমেন্ট'),
        _beforeFlightController,
      ),
      _buildPaymentTotalRow(),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('PAYMENT TITLES & AMOUNTS', 'পেমেন্ট শিরোনাম ও পরিমাণ'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildPaymentStepRow(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: _tr('Amount', 'পরিমাণ'),
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BDT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTotalRow() {
    final matchesPackage = _packagePrice > 0 && _paymentTotal == _packagePrice;
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _tr('Total Payment', 'মোট পেমেন্ট'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppPalette.brandBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatMoney(_paymentTotal),
                    style: TextStyle(
                      fontSize: 15,
                      color: matchesPackage
                          ? AppPalette.brandBlue
                          : AppPalette.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'BDT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4DetailedDescription() {
    return Container(
      key: const ValueKey(3),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppPalette.brandBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _tr('Detailed Description', 'বিস্তারিত বিবরণ'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                hintText: _tr(
                  'Write detailed requirements, work conditions, specific skills needed...',
                  'বিস্তারিত প্রয়োজনীয়তা, কাজের শর্তাবলী লিখুন...',
                ),
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppPalette.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
    Widget Function(T item, double size)? itemLeading,
    String? extraActionLabel,
    VoidCallback? onExtraAction,
  }) {
    final hasValue = value != null;
    final displayText = hasValue ? itemLabel(value) : hint;
    final leading = hasValue ? itemLeading?.call(value, 24) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final selected = await _showFormDropdownSheet<T>(
                title: hint,
                items: items,
                selectedValue: value,
                itemLabel: itemLabel,
                itemLeading: itemLeading,
                extraActionLabel: extraActionLabel,
              );
              if (selected == _DropdownExtraAction.instance) {
                onExtraAction?.call();
              } else if (selected is T) {
                onChanged(selected);
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBEAFE)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x120F172A),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (leading != null) ...[leading, const SizedBox(width: 10)],
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: hasValue
                            ? Colors.black
                            : const Color(0xFF64748B),
                        fontWeight: hasValue
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<Object?> _showFormDropdownSheet<T>({
    required String title,
    required List<T> items,
    required T? selectedValue,
    required String Function(T item) itemLabel,
    Widget Function(T item, double size)? itemLeading,
    String? extraActionLabel,
  }) {
    return showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mediaQuery = MediaQuery.of(context);
            final keyboardInset = mediaQuery.viewInsets.bottom;
            final filteredItems = query.trim().isEmpty
                ? items
                : items
                      .where(
                        (item) => itemLabel(
                          item,
                        ).toLowerCase().contains(query.trim().toLowerCase()),
                      )
                      .toList();

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: mediaQuery.size.height * 0.72,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded, size: 22),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                          child: TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) =>
                                setSheetState(() => query = value),
                            decoration: InputDecoration(
                              hintText: _tr('Search $title', '$title খুঁজুন'),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppPalette.brandBlue,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDBEAFE),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppPalette.brandBlue,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount:
                                filteredItems.length +
                                (extraActionLabel == null ? 0 : 1),
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 18,
                              endIndent: 18,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              if (extraActionLabel != null &&
                                  index == filteredItems.length) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 4,
                                  ),
                                  leading: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: AppPalette.brandBlue,
                                  ),
                                  title: Text(
                                    extraActionLabel,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppPalette.brandBlue,
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(
                                    context,
                                    _DropdownExtraAction.instance,
                                  ),
                                );
                              }

                              final item = filteredItems[index];
                              final isSelected = item == selectedValue;
                              final leading = itemLeading?.call(item, 24);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 4,
                                ),
                                leading: leading,
                                title: Text(
                                  itemLabel(item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppPalette.brandBlue,
                                        size: 22,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(context, item),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? hint : _formatDate(value)!,
                    style: TextStyle(
                      fontSize: 15,
                      color: value == null
                          ? const Color(0xFF94A3B8)
                          : AppPalette.textPrimary,
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('GENDER', 'লিঙ্গ'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppPalette.brandBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.brandBlue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _tr('Male', 'পুরুষ'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _tr('Female', 'মহিলা'),
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _tr('Any', 'যেকোনো'),
                    style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('DOCUMENTS', 'কাগজপত্র'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _docChip(_tr('Passport', 'পাসপোর্ট'), true),
            _docChip(_tr('Photo', 'ছবি'), false),
            _docChip(_tr('Experience', 'অভিজ্ঞতা'), true),
            _docChip(_tr('Medical', 'মেডিকেল'), false),
          ],
        ),
      ],
    );
  }

  Widget _docChip(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppPalette.brandBlue : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppPalette.brandBlue : const Color(0xFFE2E8F0),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppPalette.brandBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppPalette.textMuted,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, size: 16, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageIncluded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('PACKAGE INCLUDED', 'প্যাকেজ সুবিধা'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppPalette.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _packageItem(
              _tr('Ticket', 'টিকিট'),
              Icons.airplane_ticket_outlined,
              true,
            ),
            _packageItem(_tr('Hotel', 'হোটেল'), Icons.hotel_outlined, false),
            _packageItem(
              _tr('Food', 'খাবার'),
              Icons.restaurant_outlined,
              false,
            ),
            _packageItem(
              _tr('Medical', 'মেডিকেল'),
              Icons.medical_services_outlined,
              true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _packageItem(String title, IconData icon, bool active) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppPalette.brandBlue.withOpacity(0.2)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? AppPalette.brandBlue : AppPalette.textMuted,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? AppPalette.brandBlue : AppPalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricInputCard(
    String label,
    String hint,
    Color bg,
    Color border,
    Color labelColor,
    Color valueColor, {
    bool hasCurrency = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.0,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: valueColor.withOpacity(0.4)),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              fillColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              suffixText: hasCurrency ? '' : '%',
              suffixStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _tr('Back', 'পেছনে'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isPublishing
                    ? null
                    : () {
                        if (_currentStep == 0 &&
                            !_isEditMode &&
                            _selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(
                                  'Ad image is required to continue',
                                  'পরবর্তী ধাপে যেতে বিজ্ঞাপনের ছবি আবশ্যক',
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        if (_currentStep == 2 && !_validatePaymentDetails()) {
                          return;
                        }

                        if (_currentStep < 3) {
                          setState(
                            () => _currentStep = (_currentStep + 1).clamp(0, 3),
                          );
                        } else {
                          _publishAd();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isPublishing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _currentStep < 3
                            ? _tr('Next Step', 'পরবর্তী ধাপ')
                            : _isEditMode
                            ? _tr('Update Ad', 'বিজ্ঞাপন আপডেট করুন')
                            : _tr('Publish Ad', 'বিজ্ঞাপন দিন'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
