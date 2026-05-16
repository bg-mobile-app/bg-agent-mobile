import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  int _selectedLanguage = 0;

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/ads/create',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breadcrumb(),
                    const SizedBox(height: 8),
                    Text('Create Post', style: AppTextStyles.headline2.copyWith(fontSize: 26)),
                    const SizedBox(height: 24),
                    _buildRecommendBanner(),
                    const SizedBox(height: 32),
                    Text('Choose Language', style: AppTextStyles.headline2.copyWith(fontSize: 22)),
                    const SizedBox(height: 16),
                    _languageCard(
                      index: 0,
                      iconPath: 'assets/img/logo/banglaIcon.png',
                      title: 'বাংলায় বিজ্ঞাপন দিন',
                      subtitle: 'Advertise in Bengali',
                      actionText: 'Select Bengali',
                      actionIcon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 16),
                    _languageCard(
                      index: 1,
                      iconPath: 'assets/img/logo/EnglishIcon1.png',
                      title: 'Advertise in English',
                      subtitle: 'ইংরেজি নির্বাচন করুন',
                      actionText: 'Select English',
                      actionIcon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 32),
                    _buildGuidelinesCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: Text(
            'Dashboard',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Ads',
            style: AppTextStyles.caption.copyWith(color: AppPalette.textMuted),
          ),
        ),
        BreadCrumbItem(
          content: Text(
            'Create Post',
            style: AppTextStyles.caption.copyWith(
              color: AppPalette.textStrongBlue,
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

  Widget _buildRecommendBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.brandBlue.withOpacity(0.1)),
        boxShadow: AppPalette.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppPalette.brandBlue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'বেশি সংখ্যক ক্রেতা আকৃষ্ট করতে ও সর্বোচ্চ ফলাফল পেতে বাংলায় বিজ্ঞাপন দিন',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageCard({
    required int index,
    required String iconPath,
    required String title,
    required String subtitle,
    required String actionText,
    required IconData actionIcon,
  }) {
    final selected = _selectedLanguage == index;

    return InkWell(
      onTap: () {
        setState(() => _selectedLanguage = index);
        context.go(index == 0 ? '/dashboard/ads/create/form/bn' : '/dashboard/ads/create/form/en');
      },
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppPalette.brandBlue : AppPalette.borderSoftBlue,
            width: selected ? 2 : 1,
          ),
          boxShadow: AppPalette.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? AppPalette.brandBlue.withOpacity(0.1) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(iconPath, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        selected ? 'Selected' : actionText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppPalette.brandBlue : AppPalette.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        selected ? Icons.check_circle : actionIcon,
                        size: 16,
                        color: selected ? AppPalette.brandBlue : AppPalette.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppPalette.brandBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              )
            else
              const Icon(Icons.chevron_right, color: AppPalette.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0E5F5)),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppPalette.brandBlue, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Need help choosing?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppPalette.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our data shows that listings in Bengali receive 40% more engagement from local customers. Check our best practices for creating high-performing posts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppPalette.textMuted, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                elevation: 4,
                shadowColor: AppPalette.brandBlue.withOpacity(0.4),
              ),
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Read Posting Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
