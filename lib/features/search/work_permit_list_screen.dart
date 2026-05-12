import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:go_router/go_router.dart';

import '../home/models/home_models.dart';
import '../home/widgets/home_common_widgets.dart';
import '../home/widgets/work_permit_card.dart';
import 'work_permit_details_screen.dart';
import 'widgets/filter_sidebar.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';

class WorkPermitListScreen extends StatefulWidget {
  const WorkPermitListScreen({super.key});

  @override
  State<WorkPermitListScreen> createState() => _WorkPermitListScreenState();
}

class _WorkPermitListScreenState extends State<WorkPermitListScreen> {
  static const Color _brandBlue = AppPalette.brandBlue;
  final _searchController = TextEditingController();
  bool _isLoggedIn = false;

  final List<WorkPermitItem> _allItems = [
    WorkPermitItem(
      title: 'Factory Worker Visa - Malaysia',
      slug: 'factory-worker-malaysia',
      image: 'assets/img/work-permit/3.png',
      customerPrice: 420000,
      agentPrice: 390000,
      countryName: 'Malaysia',
      countryFlag: 'assets/img/customer/appointment/Malaysia.webp',
      workType: 'Factory',
      selectionType: 'DIRECT',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    WorkPermitItem(
      title: 'Construction Helper - Romania',
      slug: 'construction-helper-romania',
      image: 'assets/img/work-permit/2.png',
      customerPrice: 560000,
      agentPrice: 520000,
      countryName: 'Romania',
      countryFlag: 'assets/img/customer/appointment/Romania.png',
      workType: 'Construction',
      selectionType: 'LOTTERY',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WorkPermitItem(
      title: 'Hotel Staff - Japan',
      slug: 'hotel-staff-japan',
      image: 'assets/img/work-permit/1.jpg',
      customerPrice: 680000,
      agentPrice: 640000,
      countryName: 'Japan',
      countryFlag: 'assets/img/customer/appointment/Japan.png',
      workType: 'Hospitality',
      selectionType: 'DIRECT',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WorkPermitItem(
      title: 'Agriculture Worker - Poland',
      slug: 'agriculture-worker-poland',
      image: 'assets/img/work-permit/1.jpg',
      customerPrice: 470000,
      agentPrice: 435000,
      countryName: 'Poland',
      countryFlag: 'assets/img/customer/appointment/world.png',
      workType: 'Agriculture',
      selectionType: 'DELEGATE',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  List<WorkPermitItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.of(_allItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Working on this page')));
  }

  void _applyFilters(FilterValue value) {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final queryOk =
            value.query.isEmpty ||
            item.title.toLowerCase().contains(value.query.toLowerCase());
        final countryOk =
            value.country == null || item.countryName == value.country;
        final workTypeOk =
            value.workType == null || item.workType == value.workType;
        final selectionOk =
            value.selectionType == null ||
            item.selectionType == value.selectionType;
        return queryOk && countryOk && workTypeOk && selectionOk;
      }).toList();
    });
  }

  void _openDetailsBySlug(WorkPermitItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkPermitDetailsScreen(item: item)),
    );
  }

  Future<void> _openFiltersBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilterSidebar(
            onApply: (value) {
              _applyFilters(value);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBrandHeader(
        brandBlue: _brandBlue,
        isLoggedIn: _isLoggedIn,
        onSignIn: () async {
          final result = await context.push('/login');
          if (result == true && mounted) setState(() => _isLoggedIn = true);
        },
        onSignUp: () => context.push('/sign-up/customer'),
        onNotifications: _showComingSoon,
        onProfile: _showComingSoon,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppSpacing.xl : AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                _searchBar(),
                _buildServices(),
                const SizedBox(height: AppSpacing.lg),
                _buildWorkPermitSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return AppSearchBar(
      controller: _searchController,
      hintText: 'Search in bideshgami',
      onChanged: (query) => _applyFilters(FilterValue(query: query.trim())),
      onSearchTap: _showComingSoon,
    );
  }

  Widget _buildWorkPermitSection() {
    if (_filteredItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Text('No work permits found.'),
      );
    }
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = 1;
    final childAspectRatio = width >= 768 ? 1.25 : 0.95;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Work Permit', style: AppTextStyles.headline2),
            if (width < 1024)
              InkWell(
                onTap: _openFiltersBottomSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 42,
                  width: 42,
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
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (width >= 1024) ...[
                  SizedBox(
                    width: 320,
                    child: FilterSidebar(onApply: _applyFilters),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) => WorkPermitCard(
                      item: _filteredItems[index],
                      brandBlue: _brandBlue,
                      onViewDetails: () =>
                          _openDetailsBySlug(_filteredItems[index]),
                      formatBdt: _formatBdt,
                      timeAgo: _timeAgo,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildServices() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
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
            onTap: _showComingSoon,
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
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
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

  String _formatBdt(int value) {
    final raw = value.toString();
    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
