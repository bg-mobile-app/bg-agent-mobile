import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/ads/my',
      child: Container(
        color: const Color(0xFFF4F6FC),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(),
                const SizedBox(height: 20),
                _CreateButton(),
                const SizedBox(height: 20),
                _SearchBox(),
                const SizedBox(height: 20),
                _StatusFilters(),
                const SizedBox(height: 18),
                ..._ads.map((ad) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _AdCard(ad: ad),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back, color: Color(0xFF0F4ECF))),
        Expanded(
          child: Text('Create Post (বিজ্ঞাপন দিন)', style: AppTextStyles.headline2.copyWith(color: const Color(0xFF0F4ECF), fontWeight: FontWeight.w800)),
        ),
        const Icon(Icons.help_outline, color: Color(0xFF0F4ECF)),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(color: const Color(0xFF0D4CC7), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x2A0D4CC7), blurRadius: 14, offset: Offset(0, 6))]),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Text('CREATE NEW ADS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 30 / 2)),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD9E5FF))),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(child: Text('Search in bideshgami', style: AppTextStyles.subtitle1.copyWith(color: const Color(0xFF5A6785)))),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x2A2563EB), blurRadius: 8, offset: Offset(0, 3))]),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statuses = ['All Ads', 'PENDING', 'ACTIVE', 'REJECTED'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses
            .map((status) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: status == 'All Ads' ? const Color(0xFF0D4CC7) : const Color(0xFFD3DBEE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status == 'All Ads' ? Colors.white : const Color(0xFF33394B),
                        fontWeight: FontWeight.w700,
                        fontSize: 30 / 2,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad});
  final _AdItem ad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF9FBFF), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFDEE5F5))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
            child: Stack(
              children: [
                Image.network(ad.image, width: 164, height: 200, fit: BoxFit.cover),
                Positioned(
                  left: 10,
                  bottom: 8,
                  child: Text('ID: ${ad.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24 / 2)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 42 / 2, fontWeight: FontWeight.w700, height: 1.15)),
                  const SizedBox(height: 6),
                  Text('Post ID: ${ad.id}', style: AppTextStyles.subtitle1.copyWith(color: AppPalette.textPrimary, fontSize: 16 / 1.2)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: ad.status == 'END QUOTA' ? const Color(0xFFF5DADA) : const Color(0xFFC5EED8), borderRadius: BorderRadius.circular(20)),
                        child: Text(ad.status, style: TextStyle(color: ad.status == 'END QUOTA' ? const Color(0xFFB10000) : const Color(0xFF00703A), fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFCDD7F7), borderRadius: BorderRadius.circular(18)),
                        child: const Row(children: [Icon(Icons.edit_outlined, color: Color(0xFF0D4CC7), size: 20), SizedBox(width: 6), Text('Edit', style: TextStyle(color: Color(0xFF0D4CC7), fontSize: 30 / 2))]),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdItem {
  const _AdItem({required this.id, required this.title, required this.status, required this.image});

  final int id;
  final String title;
  final String status;
  final String image;
}

const _ads = [
  _AdItem(id: 20, title: 'এসি টেকনিশিয়ান নিয়োগ বিজ্ঞপ্তি', status: 'ACTIVE', image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA01XVoyK7Orh0QTkHE8D6TO5-vz93wlNbq0YC3TrqYhtf4wWBUAASTEO0AtXheaV4EYQE1rlc3wN-V1QyJjG31kSoktQwtiRNu3PBFpNuZCTcjo-CWUr2-OivfWF6FKHzhEbvlDn5Tyji6CNcOsgKB2c8GftgGDvuGY94V9WdUP4EqSlmJUHZBUX9AhFjszPmAwBitkgglGg067oNVq1L1jzmbmlFAnJubhVeON4CHZ_hqf73iY2HXkDRmZJ_fPESBQpJTwKBLbd4'),
  _AdItem(id: 19, title: 'ভিসা ভিসা ভিসা...', status: 'ACTIVE', image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC85jfHvvuamCjivt1PKX4ASRGDjPNraVTKZkx2N4BbJujMdoXWcqXll8PKR9MD9WOVHp2YaUKorTnmt7ZNTNMlbjHjEUjq8Kp1UXdDeUgf3g4vVM8ZUqCV8GL6pX_TT0lEx_l8zxxb6jf2gbV-h5B4S2pCmQ1zTFtLz05R6Cjbz426Az-dIQCUnthDJKZMvLAq2uYgi9VkV1LsqZmkLoxpztbDMqDyL4svfQmOtd9FnuvaaBYvIQ0P9vVSsT1xvR9uDrgAYqLEH9A'),
  _AdItem(id: 18, title: 'আয়ারল্যান্ড জরুরী নিয়োগ', status: 'END QUOTA', image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAMTaxA3eBfLG1bsOfirvwaJ_f6Ew7xncoBHBViJ9XfZTYhGc_-ae1U0BIJrQd_T-6I6rUYAbVCTIOS73AXTfjEAcUu0oQz-Q4uSwKh6n_8QroqTak7tAg-7Yca7nJWHF9MikkvKTQpKvGn_DQw5EM4swVjG-TOLDoYfO4w0c4ZhRfwWcgeA1NW8Lw6qHz4_ybKRSkiGsvKaQPVp_WhwBIJgxXcDUTd75QzoivvQovEyJUllJVOQbwSqpGpZv3Z7pOj4WICvVn9elA'),
  _AdItem(id: 17, title: 'কাতার জরুরী নিয়োগ বিজ্ঞপ্তি', status: 'ACTIVE', image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAMTaxA3eBfLG1bsOfirvwaJ_f6Ew7xncoBHBViJ9XfZTYhGc_-ae1U0BIJrQd_T-6I6rUYAbVCTIOS73AXTfjEAcUu0oQz-Q4uSwKh6n_8QroqTak7tAg-7Yca7nJWHF9MikkvKTQpKvGn_DQw5EM4swVjG-TOLDoYfO4w0c4ZhRfwWcgeA1NW8Lw6qHz4_ybKRSkiGsvKaQPVp_WhwBIJgxXcDUTd75QzoivvQovEyJUllJVOQbwSqpGpZv3Z7pOj4WICvVn9elA'),
  _AdItem(id: 16, title: 'italy job visa spacial of', status: 'ACTIVE', image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAs_8QZGEBXwsMLxpRXg4A6Kq7lYi_h8Glk0lvjP3zb7hrZgW0-i9-Cv6fwp0tMGr8-uM3tMEJr2lsQK45_ftGTgnIR_ygUn09LID7PfdL3YOab_1q_3k9X3CjtXnRzi99lnE8jBqi3B3BRdkHz92Y9PpIaB68hTXNwsU-Jq_3F3-XellJWT09w24wUcFZdQYs4oCT81HCZJ9kdrfePcE98qhdZ2DRuZ7rLFuhVig5OK0rxnepB2z6OdamtJmjPkKBVbOoS1bbBQ70'),
];
