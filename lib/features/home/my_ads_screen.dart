import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';
import 'services/my_ads_service.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  static const Color _brandBlue = Color(0xFF2563EB);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MyAdsService _myAdsService = MyAdsService();
  Timer? _debounce;

  String _activeFilter = 'All Ads';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _errorMessage;
  List<MyAdItem> _visibleAds = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchAds();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger when user scrolls within 200 pixels of the bottom for a seamless load
    if (currentScroll >= maxScroll - 200) {
      if (!_isLoading && _currentPage < _totalPages) {
        _fetchMoreAds();
      }
    }
  }

  Future<void> _fetchAds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final res = await _myAdsService.getOwnerOwnAdsList(
        page: 1,
        search: _searchController.text,
        status: _activeFilter == 'All Ads' ? '' : _activeFilter,
      );

      if (!mounted) return;
      setState(() {
        _visibleAds = res.results;
        _totalPages = res.totalPages == 0 ? 1 : res.totalPages;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
      _showInfo('Failed to load ads. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchMoreAds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final res = await _myAdsService.getOwnerOwnAdsList(
        page: nextPage,
        search: _searchController.text,
        status: _activeFilter == 'All Ads' ? '' : _activeFilter,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _visibleAds = [..._visibleAds, ...res.results];
        _totalPages = res.totalPages == 0 ? 1 : res.totalPages;
      });
    } catch (error) {
      if (!mounted) return;
      _showInfo('Failed to load more ads.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchAds();
    });
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/ads/my',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      onHelpTap: () => _showInfo('Ads guide is coming soon'),
                    ),
                    const SizedBox(height: 18),
                    _CreateButton(
                      onTap: () => context.push('/dashboard/ads/create'),
                    ),
                    const SizedBox(height: 14),
                    _SearchBox(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSearchTap: () {
                        _fetchAds();
                      },
                    ),
                    const SizedBox(height: 14),
                    _StatusFilters(
                      activeFilter: _activeFilter,
                      onSelected: (status) {
                        setState(() {
                          _activeFilter = status;
                        });
                        _fetchAds();
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading && _currentPage == 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _ErrorBox(
                        onRetry: _fetchAds,
                        message: 'Could not load ads from server.',
                      )
                    else if (_visibleAds.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Text(
                          'No ads found for selected filter.',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppPalette.textMuted,
                          ),
                        ),
                      )
                    else ...[
                      ..._visibleAds.map(
                        (ad) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AdCard(
                            ad: ad,
                            onTap: () =>
                                _showInfo('Opening ad #${ad.id} details'),
                            onEdit: () {
                              final lang = ad.isBn ? 'bn' : 'en';
                              context.push(
                                '/dashboard/ads/edit/$lang/${ad.id}',
                              );
                            },
                            onPromote: () =>
                                _showInfo('Promote ad #${ad.id} request sent'),
                          ),
                        ),
                      ),
                      if (_isLoading && _currentPage > 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0D4CC7),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onHelpTap});

  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Ads (বিজ্ঞাপন)',
          style: AppTextStyles.headline2.copyWith(
            color: const Color(0xFF0F4ECF),
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton.icon(
          onPressed: onHelpTap,
          icon: const Icon(Icons.menu_book_outlined, color: Color(0xFF0F4ECF), size: 18),
          label: const Text(
            'Ad Guide',
            style: TextStyle(
              color: Color(0xFF0F4ECF),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE0E7FF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D4CC7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A0D4CC7),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              'CREATE NEW ADS',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2563EB),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search by title, country or post ID',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _MyAdsScreenState._brandBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.activeFilter, required this.onSelected});

  final String activeFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const statuses = ['All Ads', 'PENDING', 'ACTIVE', 'REJECTED', 'END QUOTA'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => onSelected(status),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: status == activeFilter
                          ? const Color(0xFF0D4CC7)
                          : const Color(0xFFD3DBEE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status == activeFilter
                            ? Colors.white
                            : const Color(0xFF334155),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({
    required this.ad,
    required this.onTap,
    required this.onEdit,
    required this.onPromote,
  });

  final MyAdItem ad;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onPromote;

  @override
  Widget build(BuildContext context) {
    final bool isQuotaEnd = ad.status == 'END QUOTA';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
              child: ad.image.isNotEmpty
                  ? Image.network(
                      ad.image,
                      width: 120,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 150,
                        color: const Color(0xFFE2E8F0),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 150,
                      color: const Color(0xFFE2E8F0),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Post ID: #${ad.id} • ${ad.country}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isQuotaEnd
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            ad.status,
                            style: TextStyle(
                              color: isQuotaEnd
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF047857),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _ActionButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          label: 'Boost',
                          icon: Icons.trending_up,
                          onTap: onPromote,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        children: [
          Text(message),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
