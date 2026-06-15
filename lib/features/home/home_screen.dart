import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fui_kit/fui_kit.dart';

import 'models/home_models.dart';
import 'services/home_service.dart';
import 'widgets/home_common_widgets.dart';
import 'widgets/home_responsive.dart';
import 'widgets/work_permit_card.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/services/api_client.dart';
import '../../common/services/profile_service.dart';
import '../../routes/app_routes.dart';
import '../search/work_permit_details_screen.dart';

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
  String? _profileImageUrl;

  final HomeService _homeService = HomeService();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;

  List<CountryItem> _countries = [];
  List<WorkTypeItem> _workTypes = [];
  List<String> _banners = ['assets/img/ads/1.png'];
  List<WorkPermitItem> _workPermits = [];
  List<WorkPermitItem> _filteredWorkPermits = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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

  Future<void> _checkLoginStatus() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    if (mounted && cookies != null && cookies.isNotEmpty) {
      setState(() => _isLoggedIn = true);
      final profile = await _profileService.getAgencyProfile();
      if (mounted) {
        setState(() => _profileImageUrl = profile?.image);
      }
    }
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
        _countries = results[0] as List<CountryItem>;
        _workTypes = results[1] as List<WorkTypeItem>;

        final fetchedBanners = results[2] as List<String>;
        if (fetchedBanners.isNotEmpty) {
          _banners = fetchedBanners;
        }

        _workPermits = results[3] as List<WorkPermitItem>;
        _filteredWorkPermits = List<WorkPermitItem>.from(_workPermits);
        _isLoading = false;
      });
    }
  }

  bool get _hasActiveFilters {
    return (_country?.isNotEmpty ?? false) ||
        (_workType?.isNotEmpty ?? false) ||
        _serviceType != 'WORK_PERMIT' ||
        _selectionType != 'All' ||
        _companyController.text.trim().isNotEmpty ||
        _minAgeController.text.trim().isNotEmpty ||
        _maxAgeController.text.trim().isNotEmpty ||
        _fromDate != null ||
        _toDate != null;
  }

  Future<void> _applyFilters() async {
    if (!_hasActiveFilters) {
      setState(() => _filteredWorkPermits = List.from(_workPermits));
      return;
    }

    setState(() => _isLoading = true);

    String? countryCode;
    if (_country != null && _country!.isNotEmpty) {
      try {
        countryCode = _countries.firstWhere((c) => c.name == _country).code;
      } catch (_) {}
    }

    final fromDateStr = _fromDate != null
        ? '${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}'
        : null;
    final toDateStr = _toDate != null
        ? '${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}'
        : null;

    final filtered = await _homeService.filterWorkPermits(
      countryCode: countryCode,
      workType: _workType,
      companyName: _companyController.text.trim(),
      minAge: int.tryParse(_minAgeController.text.trim()),
      maxAge: int.tryParse(_maxAgeController.text.trim()),
      selectionType: _selectionType,
      fromDate: fromDateStr,
      toDate: toDateStr,
    );

    debugPrint(
      "HOME SCREEN: Received ${filtered.length} filtered items from API.",
    );

    if (mounted) {
      setState(() {
        _filteredWorkPermits = filtered;
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
        final responsive = HomeResponsive.of(context);
        final sheetGap = responsive.size(10, min: 8, max: 12);

        final mediaQuery = MediaQuery.of(context);
        final horizontalInset = responsive.size(
          AppSpacing.md,
          min: 12,
          max: AppSpacing.md,
        );
        final bottomInset = responsive.size(
          AppSpacing.md,
          min: 12,
          max: AppSpacing.md,
        );

        void submitAdvancedFilters() {
          Navigator.pop(context);
          _applyFilters();
        }

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: horizontalInset,
            right: horizontalInset,
            bottom: mediaQuery.viewInsets.bottom + bottomInset,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.size(AppSpacing.sm + 2, min: 10, max: 14),
              vertical: responsive.size(
                AppSpacing.md,
                min: 12,
                max: AppSpacing.md,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsive.size(16, min: 12, max: 16),
              ),
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
                    height: responsive.size(56, min: 48, max: 56),
                    horizontalPadding: responsive.size(10, min: 8, max: 10),
                    fontSize: responsive.font(11, min: 10, max: 11),
                    onChanged: (v) =>
                        setState(() => _serviceType = v ?? 'WORK_PERMIT'),
                  ),
                  SizedBox(height: sheetGap),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          _minAgeController,
                          'Min Age',
                          onSubmitted: submitAdvancedFilters,
                        ),
                      ),
                      SizedBox(width: responsive.size(8, min: 6, max: 8)),
                      Expanded(
                        child: _textField(
                          _maxAgeController,
                          'Max Age',
                          onSubmitted: submitAdvancedFilters,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sheetGap),
                  _textField(
                    _companyController,
                    'Company Name',
                    onSubmitted: submitAdvancedFilters,
                  ),
                  SizedBox(height: sheetGap),
                  _dropdown(
                    value: _selectionType,
                    hint: 'Selection Type',
                    items: const ['All', 'Direct', 'Lottery'],
                    height: responsive.size(56, min: 48, max: 56),
                    horizontalPadding: responsive.size(10, min: 8, max: 10),
                    fontSize: responsive.font(11, min: 10, max: 11),
                    onChanged: (v) =>
                        setState(() => _selectionType = v ?? 'All'),
                  ),
                  SizedBox(height: sheetGap),
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
                      SizedBox(width: responsive.size(8, min: 6, max: 8)),
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
                  SizedBox(height: responsive.size(12, min: 10, max: 12)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitAdvancedFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontSize: responsive.font(14, min: 12, max: 14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
        onSignUp: () => context.push(AppRoutes.agencySignUp),
        onNotifications: () => context.push('/dashboard/notifications'),
        onProfile: () => context.push('/dashboard/customer/profile'),
        profileImageUrl: _profileImageUrl,
      ),
      body: SafeArea(
        child: Skeletonizer(
          enabled: _isLoading,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _hasActiveFilters
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: [_buildOfferBanner(), _buildServices()],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(child: _buildWorkPermitSection()),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: HomeResponsive.of(context).size(24, min: 18, max: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final responsive = HomeResponsive.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.size(16, min: 12, max: 16),
        responsive.size(8, min: 6, max: 8),
        responsive.size(16, min: 12, max: 16),
        0,
      ),
      child: _buildSearchFilters(),
    );
  }

  Widget _buildSearchFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = HomeResponsive.fromWidth(constraints.maxWidth);
        final isTightPhone = responsive.isTightPhone;
        final gap = responsive.size(isTightPhone ? 6 : 8, min: 5, max: 8);
        final filterButtonSize = responsive.size(48, min: 42, max: 48);
        final dropdownHeight = responsive.size(56, min: 46, max: 56);
        final dropdownPadding = responsive.size(10, min: 7, max: 10);
        final dropdownFontSize = responsive.font(13, min: 12, max: 13);

        return Row(
          children: [
            Expanded(
              child: _dropdown(
                value: _country,
                hint: 'Country Name',
                items: _countries.map((e) => e.name).toList(),
                height: dropdownHeight,
                horizontalPadding: dropdownPadding,
                fontSize: dropdownFontSize,
                leadingBuilder: _countryOptionLeading,
                onChanged: (v) {
                  setState(() => _country = v);
                  _applyFilters();
                },
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _dropdown(
                value: _workType,
                hint: 'Type of Work',
                items: _workTypes.map((e) => e.name).toList(),
                height: dropdownHeight,
                horizontalPadding: dropdownPadding,
                fontSize: dropdownFontSize,
                onChanged: (v) {
                  setState(() => _workType = v);
                  _applyFilters();
                },
              ),
            ),
            SizedBox(width: gap),
            InkWell(
              onTap: _showAdvancedFilterSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: filterButtonSize,
                width: filterButtonSize,
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
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: responsive.size(20, min: 17, max: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServices() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = HomeResponsive.fromWidth(constraints.maxWidth);
        final horizontalPadding = responsive.size(16, min: 12, max: 16);
        final isCompactMobile = constraints.maxWidth <= 380;
        final iconBoxSize = isCompactMobile
            ? responsive.size(52, min: 48, max: 52)
            : responsive.size(62, min: 46, max: 62);
        final iconSize = isCompactMobile
            ? responsive.size(22, min: 19, max: 22)
            : responsive.size(24, min: 18, max: 24);
        final itemGap = isCompactMobile
            ? responsive.size(8, min: 6, max: 8)
            : responsive.size(14, min: 8, max: 14);
        final itemPadding = EdgeInsets.symmetric(
          horizontal: responsive.size(isCompactMobile ? 4 : 6, min: 3, max: 6),
          vertical: responsive.size(isCompactMobile ? 5 : 8, min: 4, max: 8),
        );
        final serviceTextFontSize = isCompactMobile
            ? responsive.font(10, min: 9.5, max: 10)
            : responsive.font(10, min: 8.5, max: 10);
        final serviceTextHeight = isCompactMobile ? 1.12 : 1.18;
        final rowSpacing = isCompactMobile
            ? responsive.size(4, min: 2, max: 4)
            : responsive.size(10, min: 6, max: 10);

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: responsive.size(16, min: 10, max: 16)),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.builder(
            itemCount: navLinkData.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: rowSpacing,
              crossAxisSpacing: responsive.size(10, min: 6, max: 10),
              childAspectRatio: .78,
            ),
            itemBuilder: (context, index) {
              final item = navLinkData[index];
              return InkWell(
                onTap: item.href.isEmpty
                    ? _showComingSoon
                    : () => context.push(item.href),
                borderRadius: BorderRadius.circular(
                  responsive.size(12, min: 10, max: 12),
                ),
                child: Container(
                  padding: itemPadding,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: index == 0 ? _brandBlue : Colors.white,
                          borderRadius: BorderRadius.circular(
                            responsive.size(18, min: 14, max: 18),
                          ),
                          boxShadow: index == 0
                              ? const [
                                  BoxShadow(
                                    color: Color(0x332563EB),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: FUI(
                            item.icon,
                            color: index == 0 ? Colors.white : _brandBlue,
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                      ),
                      SizedBox(height: itemGap),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: serviceTextFontSize,
                          height: serviceTextHeight,
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
      },
    );
  }

  Widget _buildOfferBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = HomeResponsive.fromWidth(constraints.maxWidth);
        final horizontalPadding = responsive.size(16, min: 12, max: 16);
        final mediaQuery = MediaQuery.of(context);
        final physicalWidth =
            mediaQuery.size.width * mediaQuery.devicePixelRatio;
        final isSmallPhone = responsive.isTightPhone || physicalWidth <= 720;
        final bannerHeight = isSmallPhone
            ? (constraints.maxWidth * 0.52).clamp(150.0, 190.0).toDouble()
            : (constraints.maxWidth * 0.72).clamp(210.0, 294.0).toDouble();

        return SizedBox(
          height: bannerHeight + responsive.size(22, min: 16, max: 22),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              responsive.size(16, min: 10, max: 16),
              horizontalPadding,
              responsive.size(6, min: 4, max: 6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                responsive.size(28, min: 18, max: 28),
              ),
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  if (banner.startsWith('http')) {
                    return Image.network(
                      banner,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
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
      },
    );
  }

  Widget _buildWorkPermitSection() {
    if (_filteredWorkPermits.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    final responsive = HomeResponsive.of(context);
    final displayItems = _isLoading
        ? List.generate(4, (_) => WorkPermitItem.getDummy())
        : _filteredWorkPermits;
    final horizontalPadding = responsive.size(16, min: 12, max: 16);
    final listHeight = responsive.size(480, min: 390, max: 480);
    final separator = responsive.size(14, min: 10, max: 14);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: responsive.size(10, min: 8, max: 10),
      ),
      child: Column(
        children: [
          _sectionHeader(
            'Work Permit',
            actionLabel: 'See More',
            onActionTap: () => context.push('/search'),
          ),
          SizedBox(height: responsive.size(14, min: 10, max: 14)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: SizedBox(
              key: ValueKey<bool>(_hasActiveFilters),
              height: _hasActiveFilters ? null : listHeight,
              child: ListView.separated(
                shrinkWrap: _hasActiveFilters,
                physics: _hasActiveFilters
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                scrollDirection: _hasActiveFilters
                    ? Axis.vertical
                    : Axis.horizontal,
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final availableWidth = screenWidth - (horizontalPadding * 2);
                  final cardWidth = (availableWidth * .94)
                      .clamp(220.0, 340.0)
                      .toDouble();
                  return SizedBox(
                    width: _hasActiveFilters ? double.infinity : cardWidth,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: WorkPermitCard(
                        item: displayItems[index],
                        brandBlue: _brandBlue,
                        onViewDetails: () =>
                            _openWorkPermitDetails(displayItems[index]),
                        formatBdt: _formatBdt,
                        timeAgo: _timeAgo,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: _hasActiveFilters ? separator : 0,
                  width: _hasActiveFilters ? 0 : separator,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    required String actionLabel,
    VoidCallback? onActionTap,
  }) {
    final responsive = HomeResponsive.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: responsive.font(25, min: 19, max: 25),
              color: const Color(0xFF111827),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onActionTap ?? _showComingSoon,
          style: TextButton.styleFrom(
            foregroundColor: _brandBlue,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.size(10, min: 6, max: 10),
              vertical: responsive.size(8, min: 5, max: 8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: TextStyle(
              fontSize: responsive.font(14, min: 11, max: 14),
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: Icon(
            Icons.arrow_forward_rounded,
            size: responsive.size(18, min: 14, max: 18),
          ),
          label: Text(
            actionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _openWorkPermitDetails(WorkPermitItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkPermitDetailsScreen(item: item)),
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

  Widget _countryOptionLeading(String countryName, double size) {
    CountryItem? country;
    for (final item in _countries) {
      if (item.name == countryName) {
        country = item;
        break;
      }
    }
    if (country == null) {
      return Icon(
        Icons.flag_outlined,
        size: size,
        color: const Color(0xFF64748B),
      );
    }

    if (country.unicodeFlag.isNotEmpty) {
      return Text(country.unicodeFlag, style: TextStyle(fontSize: size * 0.86));
    }

    final emoji = _countryCodeToEmoji(country.code);
    if (emoji.isNotEmpty) {
      return Text(emoji, style: TextStyle(fontSize: size * 0.86));
    }

    if (country.flag.isNotEmpty &&
        !country.flag.toLowerCase().endsWith('.svg')) {
      final image = country.flag.startsWith('http')
          ? Image.network(country.flag, fit: BoxFit.cover)
          : Image.asset(country.flag, fit: BoxFit.cover);
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

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double height = 56,
    double horizontalPadding = 10,
    double fontSize = 11,
    Widget Function(String, double)? leadingBuilder,
  }) {
    final radius = (height * 0.32).clamp(14.0, 18.0).toDouble();
    final hasValue = value != null && value.isNotEmpty;
    final selectedValue = value ?? '';
    final displayText = hasValue ? selectedValue : hint;
    final leading = hasValue
        ? leadingBuilder?.call(selectedValue, fontSize + 12)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final selected = await _showDropdownBottomSheet(
            title: hint,
            items: items,
            selectedValue: value,
            leadingBuilder: leadingBuilder,
          );
          if (selected != null) {
            onChanged(selected);
          }
        },
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDBEAFE)),
            borderRadius: BorderRadius.circular(radius),
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
              if (leading != null) ...[
                leading,
                SizedBox(
                  width: (horizontalPadding * 0.6).clamp(4.0, 8.0).toDouble(),
                ),
              ],
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    color: hasValue ? Colors.black : const Color(0xFF64748B),
                    fontSize: fontSize,
                  ),
                ),
              ),
              SizedBox(
                width: (horizontalPadding * 0.6).clamp(4.0, 8.0).toDouble(),
              ),
              if (hasValue) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(null),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF64748B),
                    size: (fontSize + 6).clamp(16.0, 19.0).toDouble(),
                  ),
                ),
                SizedBox(
                  width: (horizontalPadding * 0.45).clamp(3.0, 6.0).toDouble(),
                ),
              ],
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black87,
                size: (fontSize + 8).clamp(17.0, 20.0).toDouble(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showDropdownBottomSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    Widget Function(String, double)? leadingBuilder,
  }) {
    final responsive = HomeResponsive.of(context);
    final radius = responsive.size(24, min: 18, max: 24);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mediaQuery = MediaQuery.of(context);
            final keyboardInset = mediaQuery.viewInsets.bottom;
            final safeAvailableHeight =
                mediaQuery.size.height - keyboardInset - mediaQuery.padding.top;
            final sheetMaxHeight = (safeAvailableHeight * 0.9)
                .clamp(280.0, mediaQuery.size.height * 0.72)
                .toDouble();
            final filteredItems = query.trim().isEmpty
                ? items
                : items
                      .where(
                        (item) => item.toLowerCase().contains(
                          query.trim().toLowerCase(),
                        ),
                      )
                      .toList();

            void submitSearch(String value) {
              final normalizedValue = value.trim().toLowerCase();
              if (normalizedValue.isEmpty || filteredItems.isEmpty) return;

              final matchedItem = filteredItems.firstWhere(
                (item) => item.toLowerCase() == normalizedValue,
                orElse: () => filteredItems.first,
              );

              Navigator.pop(context, matchedItem);
            }

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
                    constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: responsive.size(10, min: 8, max: 10)),
                        Container(
                          width: responsive.size(42, min: 34, max: 42),
                          height: responsive.size(4, min: 3, max: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            responsive.size(18, min: 14, max: 18),
                            responsive.size(16, min: 12, max: 16),
                            responsive.size(8, min: 6, max: 8),
                            responsive.size(8, min: 6, max: 8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: responsive.font(
                                      18,
                                      min: 15,
                                      max: 18,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: responsive.size(22, min: 18, max: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            responsive.size(18, min: 14, max: 18),
                            0,
                            responsive.size(18, min: 14, max: 18),
                            responsive.size(10, min: 8, max: 10),
                          ),
                          child: TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) {
                              setSheetState(() => query = value);
                            },
                            onSubmitted: submitSearch,
                            decoration: InputDecoration(
                              hintText: 'Search $title',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: _brandBlue,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.size(
                                  12,
                                  min: 10,
                                  max: 12,
                                ),
                                vertical: responsive.size(12, min: 10, max: 12),
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
                                  color: _brandBlue,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        Flexible(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      responsive.size(24, min: 18, max: 24),
                                    ),
                                    child: Text(
                                      'No options available',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: responsive.font(
                                          14,
                                          min: 12,
                                          max: 14,
                                        ),
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  padding: EdgeInsets.only(
                                    top: responsive.size(8, min: 6, max: 8),
                                    bottom: responsive.size(8, min: 6, max: 8),
                                  ),
                                  itemCount: filteredItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        height: 1,
                                        indent: 18,
                                        endIndent: 18,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    final isSelected = item == selectedValue;

                                    final leading = leadingBuilder?.call(
                                      item,
                                      responsive.size(24, min: 20, max: 24),
                                    );

                                    return ListTile(
                                      dense: responsive.isTightPhone,
                                      leading: leading,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: responsive.size(
                                          18,
                                          min: 14,
                                          max: 18,
                                        ),
                                        vertical: responsive.size(
                                          4,
                                          min: 2,
                                          max: 4,
                                        ),
                                      ),
                                      title: Text(
                                        item,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontSize: responsive.font(
                                            15,
                                            min: 12,
                                            max: 15,
                                          ),
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: _brandBlue,
                                              size: responsive.size(
                                                22,
                                                min: 18,
                                                max: 22,
                                              ),
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

  Widget _textField(
    TextEditingController controller,
    String hint, {
    VoidCallback? onSubmitted,
  }) {
    final responsive = HomeResponsive.of(context);
    final radius = responsive.size(8, min: 7, max: 8);

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        if (onSubmitted != null) {
          onSubmitted();
        } else {
          _applyFilters();
        }
      },
      style: TextStyle(
        color: Colors.black,
        fontSize: responsive.font(14, min: 12, max: 14),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.black54,
          fontSize: responsive.font(14, min: 12, max: 14),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.size(10, min: 8, max: 10),
          vertical: responsive.size(10, min: 8, max: 10),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _dateButton({required String label, required VoidCallback onTap}) {
    final responsive = HomeResponsive.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.size(10, min: 8, max: 10),
          vertical: responsive.size(12, min: 9, max: 12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            responsive.size(8, min: 7, max: 8),
          ),
        ),
        textStyle: TextStyle(
          fontSize: responsive.font(14, min: 11, max: 14),
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
