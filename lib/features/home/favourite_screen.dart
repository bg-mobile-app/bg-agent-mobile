import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/services/profile_service.dart';
import 'models/favourite_model.dart';
import 'widgets/work_permit_card.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  List<FavouriteItem> _favourites = [];

  @override
  void initState() {
    super.initState();
    _fetchFavourites();
  }

  Future<void> _fetchFavourites() async {
    setState(() => _isLoading = true);
    final favs = await _profileService.getFavourites();
    if (mounted) {
      setState(() {
        _favourites = favs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.pageBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumb(),
                  const SizedBox(height: 14),
                  const Text(
                    'My Favourites',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Here are your saved work permits.',
                    style: TextStyle(
                      color: AppPalette.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: const Text(
            'Dashboard',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
          ),
        ),
        BreadCrumbItem(
          content: const Text(
            'Favourite',
            style: TextStyle(
              color: AppPalette.textStrongBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      divider: const Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favourites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'No favourites found.',
            style: TextStyle(color: AppPalette.textMuted, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _favourites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final fav = _favourites[index];
        return WorkPermitCard(
          item: fav.workPermit,
          brandBlue: AppPalette.brandBlue,
          onViewDetails: () {
            context.push('/search/details/${fav.workPermit.slug}');
          },
          formatBdt: (v) => '৳$v',
          timeAgo: _formatTimeAgo,
        );
      },
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
