import 'package:flutter/material.dart';
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
        color: const Color(0xFFF4F5FA),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Post', style: AppTextStyles.headline2.copyWith(fontSize: 26)),
                const SizedBox(height: 18),
                _buildRecommendBanner(),
                const SizedBox(height: 28),
                Text('Choose Language', style: AppTextStyles.headline2.copyWith(fontSize: 44 / 2)),
                const SizedBox(height: 14),
                _languageCard(
                  index: 0,
                  image: 'assets/img/ads/create/ads_bn.png',
                  title: 'বাংলায় বিজ্ঞাপন দিন',
                  subtitle: 'Advertise in Bengali',
                ),
                const SizedBox(height: 14),
                _languageCard(
                  index: 1,
                  image: 'assets/img/ads/create/ads_en.png',
                  title: 'Advertise in English',
                  subtitle: 'ইংরেজি নির্বাচন করুন',
                ),
                const SizedBox(height: 26),
                _buildGuidelinesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD0DBFB)),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(color: Color(0xFFD3E0FF), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppPalette.brandBlue, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMMENDED',
                  style: AppTextStyles.caption.copyWith(
                    color: AppPalette.brandBlue,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'বেশি সংখ্যক ক্রেতা আকৃষ্ট করতে ও সর্বোচ্চ ফলাফল পেতে বাংলায় বিজ্ঞাপন দিন',
                  style: TextStyle(fontSize: 17, height: 1.35, color: Color(0xFF1F2937)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageCard({required int index, required String image, required String title, required String subtitle}) {
    final selected = _selectedLanguage == index;

    return InkWell(
      onTap: () {
        setState(() => _selectedLanguage = index);
        context.go(index == 0 ? '/dashboard/ads/create/form/bn' : '/dashboard/ads/create/form/en');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4D7E2)),
          boxShadow: AppPalette.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 86,
              height: 86,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDCE7FB)),
              ),
              child: Image.asset(image, fit: BoxFit.cover),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle1.copyWith(fontSize: 42 / 2)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.body2.copyWith(fontSize: 19 / 2)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            selected
                ? Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(color: AppPalette.brandBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 26),
                  )
                : const Icon(Icons.chevron_right_rounded, color: Color(0xFFB6BBC8), size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1FC),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFE0E5F5)),
      ),
      child: Column(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              color: AppPalette.brandBlue,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppPalette.cardShadow,
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 26),
          Text('Need help choosing?', style: AppTextStyles.headline2.copyWith(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(
            'Learn the best practices for creating\nads that convert and reach more\npeople.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(fontSize: 20 / 2, color: const Color(0xFF333A4A), height: 1.45),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1450C5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 0,
              ),
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Read Posting Guidelines', style: TextStyle(fontSize: 20 / 2, fontWeight: FontWeight.w600, color: Colors.white)),
                  SizedBox(width: 10),
                  Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
