import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fui_kit/fui_kit.dart';

import 'models/home_models.dart';
import 'services/home_service.dart';
import 'widgets/home_common_widgets.dart';
import 'widgets/work_permit_card.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _brandBlue = AppPalette.brandBlue;

  final _companyController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();

  String? _country;
  String? _workType;
  String _serviceType = 'WORK_PERMIT';
  String _selectionType = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;

  final _bannerController = PageController(viewportFraction: 1);
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  bool _isLoggedIn = false;

  final HomeService _homeService = HomeService();
  bool _isLoading = true;

  List<String> _countries = [];
  List<WorkTypeItem> _workTypes = [];
  List<String> _banners = [
    'assets/img/ads/1.png',
  ];
  List<WorkPermitItem> _workPermits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 2300), (_) {
      if (!_bannerController.hasClients) return;
      _bannerIndex = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _homeService.getCountries(),
      _homeService.getWorkTypes(),
      _homeService.getOfferBanners(),
      _homeService.getWorkPermits(),
    ]);

    if (mounted) {
      setState(() {
        _countries = results[0] as List<String>;
        _workTypes = results[1] as List<WorkTypeItem>;

        final fetchedBanners = results[2] as List<String>;
        if (fetchedBanners.isNotEmpty) {
          _banners = fetchedBanners;
        }

        _workPermits = results[3] as List<WorkPermitItem>;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Working on this page')));
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 3),
      initialDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _showAdvancedFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dropdown(
                    value: _serviceType,
                    hint: 'Service Type',
                    items: const ['WORK_PERMIT'],
                    onChanged: (v) =>
                        setState(() => _serviceType = v ?? 'WORK_PERMIT'),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      Expanded(child: _textField(_minAgeController, 'Min Age')),
                      const SizedBox(width: 8),
                      Expanded(child: _textField(_maxAgeController, 'Max Age')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  _textField(_companyController, 'Company Name'),
                  const SizedBox(height: AppSpacing.xs + 2),
                  _dropdown(
                    value: _selectionType,
                    hint: 'Selection Type',
                    items: const ['All', 'Direct', 'Lottery'],
                    onChanged: (v) =>
                        setState(() => _selectionType = v ?? 'All'),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Row(
                    children: [
                      Expanded(
                        child: _dateButton(
                          label: _fromDate == null
                              ? 'From Date'
                              : '${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}',
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dateButton(
                          label: _toDate == null
                              ? 'To Date'
                              : '${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}',
                          onTap: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showComingSoon();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBrandHeader(
        brandBlue: _brandBlue,
        isLoggedIn: _isLoggedIn,
        onSignIn: () async {
          final result = await context.push('/login');
          if (result == true && mounted) {
            setState(() => _isLoggedIn = true);
          }
        },
        onSignUp: () => context.push('/sign-up/customer'),
        onNotifications: _showComingSoon,
        onProfile: _showComingSoon,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeroSection()),
                  SliverToBoxAdapter(child: _buildOfferBanner()),
                  SliverToBoxAdapter(child: _buildServices()),
                  SliverToBoxAdapter(child: _buildWorkTypesSection()),
                  SliverToBoxAdapter(child: _buildWorkPermitSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: _buildSearchFilters(),
    );
  }

  Widget _buildSearchFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: _country,
                hint: 'Country Name',
                items: _countries,
                onChanged: (v) => setState(() => _country = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dropdown(
                value: _workType,
                hint: 'Type of Work',
                items: _workTypes.map((e) => e.name).toList(),
                onChanged: (v) => setState(() => _workType = v),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _showAdvancedFilterSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _brandBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: AppPalette.appcolor, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServices() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: navLinkData.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: .78,
        ),
        itemBuilder: (context, index) {
          final item = navLinkData[index];
          return InkWell(
            onTap: item.href.isEmpty ? _showComingSoon : _showComingSoon,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: index == 0 ? _brandBlue : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: index == 0 ? const [BoxShadow(color: Color(0x332563EB), blurRadius: 16, offset: Offset(0, 8))] : const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Center(
                        child: FUI(
                          item.icon,
                          color: index == 0 ? Colors.white : _brandBlue,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferBanner() {
    return SizedBox(
      height: 294,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              if (banner.startsWith('http')) {
                return Image.network(banner, fit: BoxFit.cover, width: double.infinity);
              }
              return Image.asset(
                banner,
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkTypesSection() {
    if (_workTypes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          _sectionHeader('Work Categories', actionLabel: 'View All', onActionTap: () => context.push('/search')),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _workTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = _workTypes[index];
                return InkWell(
                  onTap: () => context.push('/search'),
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: Image.network(
                            item.icon,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.work_outline, color: AppPalette.brandBlue, size: 30),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.totalAds} Ads',
                            style: const TextStyle(fontSize: 10, color: AppPalette.brandBlue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkPermitSection() {
    if (_workPermits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          _sectionHeader('Work Permit', actionLabel: 'See More', onActionTap: () => context.push('/search')),
          const SizedBox(height: 14),
          SizedBox(
            height: 540,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _workPermits.length,
              itemBuilder: (context, index) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final double cardWidth = screenWidth * .84 > 340 ? 340 : screenWidth * .84;
                return SizedBox(
                  width: cardWidth,
                  child: WorkPermitCard(
                    item: _workPermits[index],
                    brandBlue: _brandBlue,
                    onViewDetails: _showComingSoon,
                    formatBdt: _formatBdt,
                    timeAgo: _timeAgo,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required String actionLabel, VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 50/2, color: Color(0xFF111827)),
        ),
        TextButton.icon(
          onPressed: onActionTap ?? _showComingSoon,
          style: TextButton.styleFrom(
            foregroundColor: _brandBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }

  String _formatBdt(int value) {
    final raw = value.toString();
    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          isExpanded: true,
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.black87,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            constraints: const BoxConstraints(minHeight: 56),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _dateButton({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
