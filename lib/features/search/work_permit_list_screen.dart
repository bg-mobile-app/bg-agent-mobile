import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:go_router/go_router.dart';

import '../home/models/home_models.dart';
import '../home/widgets/home_common_widgets.dart';
import '../home/widgets/work_permit_card.dart';
import 'work_permit_details_screen.dart';
import 'widgets/filter_sidebar.dart';
import 'services/work_permit_service.dart';
import '../chat/models/chat_models.dart';
import '../chat/services/chat_service.dart';
import '../chat/chat_conversation_screen.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_spacing.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/services/api_client.dart';
import '../../common/services/profile_service.dart';
import '../../routes/app_routes.dart';

class WorkPermitListScreen extends StatefulWidget {
  const WorkPermitListScreen({super.key, this.queryParams});

  final Map<String, String>? queryParams;

  @override
  State<WorkPermitListScreen> createState() => _WorkPermitListScreenState();
}

class _WorkPermitListScreenState extends State<WorkPermitListScreen> {
  static const Color _brandBlue = AppPalette.brandBlue;
  final _searchController = TextEditingController();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isMoreLoading = false;

  final WorkPermitService _workPermitService = WorkPermitService();
  final ProfileService _profileService = ProfileService();
  List<WorkPermitItem> _filteredItems = [];
  FilterValue _currentFilter = const FilterValue(query: '');
  String? _nextCursor;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _parseQueryParams();
    _loadData();
  }

  void _parseQueryParams() {
    final q = widget.queryParams;
    if (q != null && q.isNotEmpty) {
      _currentFilter = FilterValue(
        query: q['query'] ?? '',
        country: q['country'],
        workType: q['workType'],
        selectionType: q['selectionType'],
        minAge: q['minAge'],
        maxAge: q['maxAge'],
      );
      _searchController.text = _currentFilter.query;
    } else {
      _currentFilter = const FilterValue(query: '');
      _searchController.clear();
    }
  }

  @override
  void didUpdateWidget(covariant WorkPermitListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.queryParams != oldWidget.queryParams) {
      _parseQueryParams();
      _loadData();
    }
  }

  Future<void> _checkLoginStatus() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    if (mounted && cookies != null && cookies.isNotEmpty) {
      setState(() => _isLoggedIn = true);
      try {
        final profile = await _profileService.getAgencyProfile();
        if (mounted) {
          setState(() => _profileImageUrl = profile?.image);
        }
      } catch (e) {
        debugPrint("Error fetching agency profile image: $e");
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _nextCursor = null;
    });
    final response = await _workPermitService.getFilteredWorkPermits(
      query: _currentFilter.query,
      country: _currentFilter.country,
      workType: _currentFilter.workType,
      selectionType: _currentFilter.selectionType,
      minAge: _currentFilter.minAge,
      maxAge: _currentFilter.maxAge,
    );
    if (mounted) {
      setState(() {
        _filteredItems = response?.results ?? [];
        _nextCursor = _extractCursor(response?.nextUrl);
        _isLoading = false;
      });
    }
  }

  String? _extractCursor(String? urlString) {
    if (urlString == null || urlString.isEmpty) return null;
    try {
      final uri = Uri.parse(urlString);
      return uri.queryParameters['cursor'];
    } catch (e) {
      debugPrint("Error parsing cursor from URL $urlString: $e");
      return null;
    }
  }

  Future<void> _loadMore() async {
    if (_isMoreLoading || _nextCursor == null) return;
    setState(() => _isMoreLoading = true);
    final response = await _workPermitService.getFilteredWorkPermits(
      query: _currentFilter.query,
      country: _currentFilter.country,
      workType: _currentFilter.workType,
      selectionType: _currentFilter.selectionType,
      minAge: _currentFilter.minAge,
      maxAge: _currentFilter.maxAge,
      cursor: _nextCursor,
    );
    if (mounted) {
      setState(() {
        if (response != null) {
          _filteredItems.addAll(response.results);
          _nextCursor = _extractCursor(response.nextUrl);
        }
        _isMoreLoading = false;
      });
    }
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
    _currentFilter = value;
    _loadData();
  }

  void _openDetailsBySlug(WorkPermitItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkPermitDetailsScreen(item: item)),
    );
  }

  Future<void> _handleChat(WorkPermitItem item) async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a chat')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final chatService = ChatService();
    final conversation = await chatService.createConversation(
      workPermitId: item.id.toString(),
      receiverRole: "AGENCY", // Assuming the receiver is the agency
    );
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      if (conversation != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(chat: conversation),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission is not allowed')),
        );
      }
    }
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
            initialValue: _currentFilter,
            onApply: (value) {
              _applyFilters(value);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final chips = <Widget>[];

    if (_currentFilter.query.isNotEmpty) {
      chips.add(
        _filterChip('Keyword: ${_currentFilter.query}', () {
          _searchController.clear();
          _applyFilters(
            FilterValue(
              query: '',
              country: _currentFilter.country,
              workType: _currentFilter.workType,
              selectionType: _currentFilter.selectionType,
              minAge: _currentFilter.minAge,
              maxAge: _currentFilter.maxAge,
            ),
          );
        }),
      );
    }

    if (_currentFilter.country != null) {
      chips.add(
        _filterChip('Country: ${_currentFilter.country}', () {
          _applyFilters(
            FilterValue(
              query: _currentFilter.query,
              country: null,
              workType: _currentFilter.workType,
              selectionType: _currentFilter.selectionType,
              minAge: _currentFilter.minAge,
              maxAge: _currentFilter.maxAge,
            ),
          );
        }),
      );
    }

    if (_currentFilter.workType != null) {
      chips.add(
        _filterChip('Work: ${_currentFilter.workType}', () {
          _applyFilters(
            FilterValue(
              query: _currentFilter.query,
              country: _currentFilter.country,
              workType: null,
              selectionType: _currentFilter.selectionType,
              minAge: _currentFilter.minAge,
              maxAge: _currentFilter.maxAge,
            ),
          );
        }),
      );
    }

    if (_currentFilter.selectionType != null) {
      chips.add(
        _filterChip('Selection: ${_currentFilter.selectionType}', () {
          _applyFilters(
            FilterValue(
              query: _currentFilter.query,
              country: _currentFilter.country,
              workType: _currentFilter.workType,
              selectionType: null,
              minAge: _currentFilter.minAge,
              maxAge: _currentFilter.maxAge,
            ),
          );
        }),
      );
    }

    if (_currentFilter.minAge != null || _currentFilter.maxAge != null) {
      final minStr = _currentFilter.minAge ?? '';
      final maxStr = _currentFilter.maxAge ?? '';
      final ageText = minStr.isNotEmpty && maxStr.isNotEmpty
          ? 'Age: $minStr-$maxStr'
          : minStr.isNotEmpty
          ? 'Age: >=$minStr'
          : 'Age: <=$maxStr';
      chips.add(
        _filterChip(ageText, () {
          _applyFilters(
            FilterValue(
              query: _currentFilter.query,
              country: _currentFilter.country,
              workType: _currentFilter.workType,
              selectionType: _currentFilter.selectionType,
              minAge: null,
              maxAge: null,
            ),
          );
        }),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...chips,
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _applyFilters(const FilterValue(query: ''));
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _brandBlue,
        deleteIconColor: Colors.white,
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
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
        onSignUp: () => context.push(AppRoutes.agentSignUp),
        onNotifications: () => context.push('/dashboard/notifications'),
        onProfile: () => context.push('/dashboard/customer/profile'),
        profileImageUrl: _profileImageUrl,
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
                _buildActiveFilters(),
                const SizedBox(height: AppSpacing.md),
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
      onChanged: (query) => _applyFilters(
        FilterValue(
          query: query.trim(),
          country: _currentFilter.country,
          workType: _currentFilter.workType,
          selectionType: _currentFilter.selectionType,
          minAge: _currentFilter.minAge,
          maxAge: _currentFilter.maxAge,
        ),
      ),
      onSearchTap: () => _applyFilters(
        FilterValue(
          query: _searchController.text.trim(),
          country: _currentFilter.country,
          workType: _currentFilter.workType,
          selectionType: _currentFilter.selectionType,
          minAge: _currentFilter.minAge,
          maxAge: _currentFilter.maxAge,
        ),
      ),
    );
  }

  Widget _buildWorkPermitSection() {
    final width = MediaQuery.of(context).size.width;
    final displayItems = _isLoading
        ? List.generate(4, (_) => WorkPermitItem.getDummy())
        : _filteredItems;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Work Abroad', style: AppTextStyles.headline2),
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
        if (_filteredItems.isEmpty && !_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30),
            child: Center(
              child: Text(
                'No work permits found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (width >= 1024) ...[
                    SizedBox(
                      width: 320,
                      child: FilterSidebar(
                        initialValue: _currentFilter,
                        onApply: _applyFilters,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Skeletonizer(
                      enabled: _isLoading,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) => WorkPermitCard(
                              item: displayItems[index],
                              brandBlue: _brandBlue,
                              onViewDetails: () =>
                                  _openDetailsBySlug(displayItems[index]),
                              onChat: () => _handleChat(displayItems[index]),
                              formatBdt: _formatBdt,
                              timeAgo: _timeAgo,
                            ),
                          ),
                          if (!_isLoading && _nextCursor != null) ...[
                            const SizedBox(height: 24),
                            if (_isMoreLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              ElevatedButton(
                                onPressed: _loadMore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brandBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Load More'),
                              ),
                          ],
                        ],
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
          final isSelected = item.name == 'Work Abroad';
          return InkWell(
            onTap: () {
              if (isSelected) return;
              if (item.href.isNotEmpty) {
                if (item.href == '/') {
                  context.go(item.href);
                } else {
                  context.push(item.href);
                }
              } else {
                _showComingSoon();
              }
            },
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
                      color: isSelected ? _brandBlue : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isSelected
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
                      child: item.customIconData != null
                          ? Icon(
                              item.customIconData,
                              color: isSelected ? Colors.white : _brandBlue,
                              size: 24,
                            )
                          : FUI(
                              item.icon,
                              color: isSelected ? Colors.white : _brandBlue,
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected ? _brandBlue : const Color(0xFF64748B),
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
