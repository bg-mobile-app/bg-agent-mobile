import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class CreateAdFormScreen extends StatelessWidget {
  const CreateAdFormScreen({super.key, required this.isBangla});

  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    final t = isBangla ? _bn : _en;
    return DashboardPageScaffold(
      currentHref: '/dashboard/ads/create',
      child: Container(
        color: const Color(0xFFF4F5FA),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['title']!, style: AppTextStyles.subtitle1.copyWith(color: AppPalette.brandBlue)),
                const SizedBox(height: 10),
                _stepper(t),
                const SizedBox(height: 10),
                _warning(t),
                const SizedBox(height: 10),
                _card(t['poster']!, _uploadBox(t)),
                const SizedBox(height: 10),
                _card('Basic Job Info', _basicInfo(t)),
                const SizedBox(height: 10),
                _card('Salary & Requirements', _salary(t)),
                const SizedBox(height: 10),
                _card('Candidate Profile', _candidate(t)),
                const SizedBox(height: 10),
                _card('Payment Breakdown', _payment()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(t['back']!))),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(onPressed: () {}, child: Text(t['save']!)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepper(Map<String, String> t) => Container(
    padding: const EdgeInsets.all(10),
    decoration: _box(),
    child: Row(children: const [
      _StepDot(label: '1', text: 'Basic Info', active: true),
      Expanded(child: Divider()),
      _StepDot(label: '2', text: 'Details'),
      Expanded(child: Divider()),
      _StepDot(label: '3', text: 'Payment'),
    ]),
  );

  Widget _warning(Map<String, String> t) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFFFF3E8), border: Border.all(color: const Color(0xFFFFD7B5)), borderRadius: BorderRadius.circular(12)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
      const SizedBox(width: 8),
      Expanded(child: Text(t['warning']!, style: const TextStyle(fontSize: 12))),
    ]),
  );

  Widget _uploadBox(Map<String, String> t) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBFD1FF), style: BorderStyle.solid), borderRadius: BorderRadius.circular(14), color: const Color(0xFFF2F6FF)),
    child: Column(children: [
      const CircleAvatar(radius: 24, backgroundColor: Color(0xFFDCE7FF), child: Icon(Icons.cloud_upload, color: AppPalette.brandBlue)),
      const SizedBox(height: 8),
      Text(t['upload']!, style: const TextStyle(color: AppPalette.brandBlue, fontSize: 12)),
      const SizedBox(height: 2),
      const Text('SVG, PNG, JPG (MAX. 800x400px)', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
    ]),
  );

  Widget _basicInfo(Map<String, String> t) => Column(children: [
    _field(t['jobTitle']!), _field(t['country']!, isDrop: true), _field(t['workType']!, isDrop: true), _field(t['company']!), _field(t['address']!), _field(t['sponsor']!), _field(t['selection']!, isDrop: true), _field(t['occupation']!),
  ]);

  Widget _salary(Map<String, String> t) => Column(children: [
    _field(t['salary']!),
    Row(children: [_field(t['minAge']!, flex: 1), const SizedBox(width: 8), _field(t['maxAge']!, flex: 1)]),
    _field(t['iqama']!, isDrop: true), _field(t['food']!, isDrop: true), _field(t['accommodation']!, isDrop: true), _field(t['hours']!), _field(t['quota']!),
    Row(children: [const Checkbox(value: false, onChanged: null), Text(t['renewable']!, style: const TextStyle(fontSize: 12))]),
  ]);

  Widget _candidate(Map<String, String> t) => Column(children: [
    _field(t['gender']!, isDrop: true), _field(t['experience']!, isDrop: true), _field(t['documents']!), _field(t['deadline']!), _field(t['processing']!),
  ]);

  Widget _payment() => Column(children: const [
    _PriceTile(title: 'Package Price', amount: '৳ 4,50,000', icon: Icons.payments_outlined, tint: Color(0xFFE9EEFF)),
    SizedBox(height: 8),
    _PriceTile(title: 'Advance', amount: '৳ 50,000', icon: Icons.account_balance_wallet_outlined, tint: Color(0xFFFFF0E5), color: Color(0xFFD95F02)),
    SizedBox(height: 8),
    _PriceTile(title: 'After Visa', amount: '৳ 3,00,000', icon: Icons.description_outlined, tint: Color(0xFFEFF1FA)),
    SizedBox(height: 8),
    _PriceTile(title: 'Before Flight', amount: '৳ 1,00,000', icon: Icons.flight_takeoff_outlined, tint: Color(0xFFEFF1FA)),
  ]);

  Widget _card(String title, Widget child) => Container(
    padding: const EdgeInsets.all(12),
    decoration: _box(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTextStyles.subtitle1.copyWith(fontSize: 20 / 2)),
      const Divider(),
      child,
    ]),
  );

  BoxDecoration _box() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB)));

  Widget _field(String label, {bool isDrop = false, int flex = 0}) {
    final field = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(' ', style: TextStyle(color: Colors.grey.shade500)), if (isDrop) const Icon(Icons.expand_more, size: 18)]),
        ),
      ]),
    );
    return flex > 0 ? Expanded(flex: flex, child: field) : field;
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.text, this.active = false});
  final String label;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(radius: 12, backgroundColor: active ? AppPalette.brandBlue : const Color(0xFFE5E7EB), child: Text(label, style: TextStyle(fontSize: 10, color: active ? Colors.white : Colors.black54))),
      const SizedBox(height: 2),
      Text(text, style: TextStyle(fontSize: 9, color: active ? AppPalette.brandBlue : Colors.black54)),
    ]);
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.title, required this.amount, required this.icon, required this.tint, this.color = AppPalette.textPrimary});
  final String title;
  final String amount;
  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))), Text(amount, style: TextStyle(fontSize: 22 / 2, fontWeight: FontWeight.w600, color: color))])), Icon(icon, color: color.withOpacity(.6))]),
    );
  }
}

const Map<String, String> _en = {
  'title': 'Create Post', 'poster': 'Job Poster', 'back': 'Back', 'save': 'Save Ads', 'upload': 'Click to upload or drag and drop',
  'warning': 'Warning: Do not include phone number/contact information in ads.', 'jobTitle': 'Job Title', 'country': 'Country', 'workType': 'Type of Work', 'company': 'Company Name', 'address': 'Company Address', 'sponsor': 'Visa Sponsor Name', 'selection': 'Selection Type', 'occupation': 'Occupation in Visa', 'salary': 'Salary', 'minAge': 'Min Age', 'maxAge': 'Max Age', 'iqama': 'Iqama', 'food': 'Food', 'accommodation': 'Accommodation', 'hours': 'Working Hours', 'quota': 'Quota', 'renewable': 'Contract Renewable', 'gender': 'Gender', 'experience': 'Required Experience', 'documents': 'Required Documents', 'deadline': 'Application Deadline', 'processing': 'Processing Time',
};

const Map<String, String> _bn = {
  'title': 'Create Post (বিজ্ঞাপন দিন)', 'poster': 'Job Poster (বিজ্ঞাপন ছবি)', 'back': 'ফিরে যান', 'save': 'বিজ্ঞাপন জমা দিন', 'upload': 'আপলোড করতে ক্লিক করুন বা ড্র্যাগ করুন',
  'warning': 'সতর্কবার্তা: বিজ্ঞাপনে কোনো মোবাইল নম্বর বা কন্টাক্ট ইনফরমেশন দিবেন না।', 'jobTitle': 'Job Title (পদের নাম)', 'country': 'Country (দেশ)', 'workType': 'Type of Work (কাজের ধরন)', 'company': 'Company Name (কোম্পানির নাম)', 'address': 'Company Address (কোম্পানির ঠিকানা)', 'sponsor': 'Visa Sponsor Name', 'selection': 'Selection Type', 'occupation': 'Occupation in Visa (ভিসায় পেশা)', 'salary': 'Salary (বেতন)', 'minAge': 'Min Age', 'maxAge': 'Max Age', 'iqama': 'Iqama', 'food': 'Food', 'accommodation': 'Accommodation', 'hours': 'Working Hours', 'quota': 'Quota (পদ সংখ্যা)', 'renewable': 'Contract Renewable (চুক্তি নবায়নযোগ্য)', 'gender': 'Gender (লিঙ্গ)', 'experience': 'Required Experience', 'documents': 'Required Documents (প্রয়োজনীয় কাগজপত্র)', 'deadline': 'Application Deadline', 'processing': 'Processing Time',
};
