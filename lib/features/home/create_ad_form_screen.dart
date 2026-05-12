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
        color: const Color(0xFFDCE7F7),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(t),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 120),
                  child: Column(
                    children: [
                      _warning(t),
                      const SizedBox(height: 10),
                      _sectionCard(
                        title: t['poster']!,
                        trailing: _optionalBadge(),
                        icon: Icons.photo_outlined,
                        child: _uploadBox(t),
                      ),
                      const SizedBox(height: 10),
                      _sectionCard(title: 'Basic Job Info', icon: Icons.info_outline, child: _basicInfo(t)),
                      const SizedBox(height: 10),
                      _sectionCard(title: 'Salary & Requirements', icon: Icons.payments_outlined, child: _salary(t)),
                      const SizedBox(height: 10),
                      _sectionCard(title: 'Candidate Profile', icon: Icons.person_search_outlined, child: _candidate(t)),
                      const SizedBox(height: 10),
                      _sectionCard(title: 'Payment Breakdown', icon: Icons.account_balance_wallet_outlined, child: _payment()),
                    ],
                  ),
                ),
              ),
              _footerButtons(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(Map<String, String> t) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: const BoxDecoration(color: Color(0xFFF8FAFF), border: Border(bottom: BorderSide(color: Color(0xFFD1D8EA)))),
    child: Row(
      children: [
        const Icon(Icons.arrow_back, color: AppPalette.brandBlue),
        const SizedBox(width: 8),
        Expanded(child: Text(t['title']!, style: AppTextStyles.subtitle1.copyWith(fontSize: 14, color: AppPalette.brandBlue, fontWeight: FontWeight.w700))),
        const Icon(Icons.help_outline, size: 18, color: AppPalette.brandBlue),
      ],
    ),
  );

  Widget _warning(Map<String, String> t) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFFFF3CC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEFD37A))),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFF5BA26), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['warning']!, style: const TextStyle(fontSize: 10, color: Color(0xFF8A4B00), fontWeight: FontWeight.w700)),
              const Text('Violation results in immediate post rejection.', style: TextStyle(fontSize: 9, color: Color(0xFFB36500))),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard({required String title, required IconData icon, required Widget child, Widget? trailing}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD8DEEA), width: 1), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10)]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppPalette.brandBlue),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );

  Widget _optionalBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: const Color(0xFFE9EEFF), borderRadius: BorderRadius.circular(99)),
    child: const Text('Optional', style: TextStyle(fontSize: 9, color: Color(0xFF5E6A89))),
  );

  Widget _uploadBox(Map<String, String> t) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xFFF3F6FE), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBDC7DA), style: BorderStyle.solid)),
    child: Column(
      children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFD9E2F5), child: Icon(Icons.upload_file, color: AppPalette.brandBlue, size: 20)),
        const SizedBox(height: 10),
        Text(t['upload']!, style: const TextStyle(fontSize: 12, color: AppPalette.brandBlue, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        const Text('SVG, PNG, JPG (MAX. 800x400px)', style: TextStyle(fontSize: 9, color: Color(0xFF7D879D))),
      ],
    ),
  );

  Widget _basicInfo(Map<String, String> t) => Column(children: [
    _field(t['jobTitle']!, 'e.g. Senior Mason'), _field(t['country']!, 'Saudi Arabia', isDrop: true), _field(t['workType']!, 'Construction', isDrop: true), _field(t['company']!, 'Enter full company name'), _field(t['address']!, 'Location details'), _field(t['sponsor']!, 'Sponsor or Agency'), _field(t['selection']!, 'Direct Interview', isDrop: true), _field(t['occupation']!, 'As written in visa documents'),
  ]);

  Widget _salary(Map<String, String> t) => Column(children: [
    _salaryRow(t['salary']!),
    Row(children: [_field(t['minAge']!, '21', flex: 1), const SizedBox(width: 8), _field(t['maxAge']!, '45', flex: 1)]),
    _field(t['iqama']!, 'Free/Provided', isDrop: true),
    _field(t['food']!, 'Provided', isDrop: true),
    _field(t['accommodation']!, 'Free/Provided', isDrop: true),
    _field(t['hours']!, 'e.g. 8 Hours + OT'),
    _field(t['quota']!, '50'),
    Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE3E7EF)), color: const Color(0xFFF8FAFC)),
      child: Row(children: [const Icon(Icons.check_box_outline_blank, size: 16, color: Color(0xFF9AA4BA)), const SizedBox(width: 8), Text(t['renewable']!, style: const TextStyle(fontSize: 10, color: Color(0xFF6A7488)))]),
    ),
  ]);

  Widget _candidate(Map<String, String> t) => Column(children: [
    _field(t['gender']!, 'Male', isDrop: true),
    _field(t['experience']!, 'No Experience', isDrop: true),
    _docs(t['documents']!),
    _field(t['deadline']!, 'mm/dd/yyyy', rightIcon: Icons.calendar_today_outlined),
    _field(t['processing']!, 'e.g. 45-60 Days'),
  ]);

  Widget _docs(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      const SizedBox(height: 6),
      Wrap(spacing: 5, runSpacing: 5, children: const [
        _ChipTag('Passport'),
        _ChipTag('NID'),
        _ChipTag('Medical Certificate'),
        _AddChip(),
      ]),
    ]),
  );

  Widget _payment() => Column(children: const [
    _PriceTile(title: 'Total Price', amount: '৳ 4,50,000', icon: Icons.account_balance, tint: Color(0xFFEEF2FF), color: AppPalette.brandBlue),
    SizedBox(height: 8),
    _PriceTile(title: 'Advance', amount: '৳50,000', icon: Icons.wallet, tint: Color(0xFFFFF2E8), color: Color(0xFFEC6A00)),
    SizedBox(height: 8),
    Row(children: [Expanded(child: _MiniPriceTile(title: 'After Visa', amount: '৳ 3,00,000', icon: Icons.description_outlined)), SizedBox(width: 8), Expanded(child: _MiniPriceTile(title: 'Before Flight', amount: '৳ 1,00,000', icon: Icons.flight_takeoff_outlined))]),
  ]);

  Widget _salaryRow(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      const SizedBox(height: 4),
      Row(children: [Expanded(child: _inputShell('0.00', roundedLeft: true)), _currencyShell()]),
    ]),
  );

  Widget _field(String label, String value, {bool isDrop = false, int flex = 0, IconData? rightIcon}) {
    final body = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label(label),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(color: const Color(0xFFF8FAFD), border: Border.all(color: const Color(0xFFCCD3E0)), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF4A556C)))), if (isDrop) const Icon(Icons.expand_more, size: 15), if (rightIcon != null) Icon(rightIcon, size: 14)]),
        ),
      ]),
    );
    return flex > 0 ? Expanded(flex: flex, child: body) : body;
  }

  Widget _label(String label) => Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, letterSpacing: .6, color: Color(0xFF5F6980), fontWeight: FontWeight.w700));

  Widget _inputShell(String value, {bool roundedLeft = false}) => Container(
    height: 38,
    decoration: BoxDecoration(color: const Color(0xFFF8FAFD), border: Border.all(color: const Color(0xFFCCD3E0)), borderRadius: BorderRadius.horizontal(left: Radius.circular(roundedLeft ? 8 : 0))),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    alignment: Alignment.centerLeft,
    child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF4A556C))),
  );

  Widget _currencyShell() => Container(
    height: 38,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xFFF0F3FA), border: Border.all(color: const Color(0xFFCCD3E0)), borderRadius: const BorderRadius.horizontal(right: Radius.circular(8))),
    child: const Row(children: [Text('SAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), SizedBox(width: 6), Icon(Icons.expand_more, size: 14)]),
  );

  Widget _footerButtons(Map<String, String> t) => Container(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
    decoration: const BoxDecoration(color: Color(0xFFF8FAFF), border: Border(top: BorderSide(color: Color(0xFFD1D8EA)))),
    child: Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(t['back']!))),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle, size: 16),
            label: Text(t['save']!),
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.brandBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ],
    ),
  );
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.title, required this.amount, required this.icon, required this.tint, required this.color});

  final String title;
  final String amount;
  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(.1))),
      child: Row(children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: TextStyle(fontSize: 8, color: color.withOpacity(.7), fontWeight: FontWeight.w700)), Text(amount, style: TextStyle(fontSize: 20 / 2, fontWeight: FontWeight.w800, color: color))])),
        Icon(Icons.chevron_right, color: color.withOpacity(.35)),
      ]),
    );
  }
}

class _MiniPriceTile extends StatelessWidget {
  const _MiniPriceTile({required this.title, required this.amount, required this.icon});

  final String title;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF2F4FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFDEE3EF))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)), child: Icon(icon, size: 13, color: const Color(0xFF6A7488))),
        const SizedBox(height: 8),
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 7, color: Color(0xFF6A7488), fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFE9EEFF), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFC7D3F8))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: const TextStyle(fontSize: 9, color: AppPalette.brandBlue, fontWeight: FontWeight.w700)), const SizedBox(width: 3), const Icon(Icons.close, size: 10, color: AppPalette.brandBlue)]),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFC7D3F8))),
      child: const Text('+ Add', style: TextStyle(fontSize: 9, color: AppPalette.brandBlue, fontWeight: FontWeight.w700)),
    );
  }
}

const Map<String, String> _en = {
  'title': 'Create Post',
  'poster': 'Job Media',
  'back': 'Back',
  'save': 'Save Ads',
  'upload': 'Click or drag to upload poster',
  'warning': 'Warning: Do not include phone number/contact information in ads.',
  'jobTitle': 'Job Title (পদের নাম) *',
  'country': 'Country (দেশ)',
  'workType': 'Type of Work (কাজের ধরন)',
  'company': 'Company Name (কোম্পানির নাম)',
  'address': 'Company Address (কোম্পানির ঠিকানা)',
  'sponsor': 'Visa Sponsor Name',
  'selection': 'Selection Type',
  'occupation': 'Occupation in Visa (ভিসায় পেশা)',
  'salary': 'Salary (বেতন)',
  'minAge': 'Min Age',
  'maxAge': 'Max Age',
  'iqama': 'Iqama',
  'food': 'Food',
  'accommodation': 'Accommodation',
  'hours': 'Working Hours',
  'quota': 'Quota (পদ সংখ্যা)',
  'renewable': 'Contract Renewable (চুক্তি নবায়নযোগ্য)',
  'gender': 'Gender (লিঙ্গ)',
  'experience': 'Experience',
  'documents': 'Required Documents (প্রয়োজনীয় কাগজপত্র)',
  'deadline': 'Application Deadline',
  'processing': 'Processing Time',
};

const Map<String, String> _bn = {
  'title': 'Create Post (বিজ্ঞাপন দিন)',
  'poster': 'Job Media (বিজ্ঞাপন ছবি)',
  'back': 'Back',
  'save': 'বিজ্ঞাপনটি জমা দিন',
  'upload': 'Click or drag to upload poster',
  'warning': 'সতর্কবার্তা: বিজ্ঞাপনে কোনো মোবাইল নম্বর দিবেন না।',
  'jobTitle': 'Job Title (পদের নাম) *',
  'country': 'Country (দেশ)',
  'workType': 'Type of Work (কাজের ধরন)',
  'company': 'Company Name (কোম্পানির নাম)',
  'address': 'Company Address (কোম্পানির ঠিকানা)',
  'sponsor': 'Visa Sponsor Name',
  'selection': 'Selection Type',
  'occupation': 'Occupation in Visa (ভিসায় পেশা)',
  'salary': 'Salary (বেতন)',
  'minAge': 'Min Age',
  'maxAge': 'Max Age',
  'iqama': 'Iqama',
  'food': 'Food',
  'accommodation': 'Accommodation',
  'hours': 'Working Hours',
  'quota': 'Quota (পদ সংখ্যা)',
  'renewable': 'Contract Renewable (চুক্তি নবায়নযোগ্য)',
  'gender': 'Gender (লিঙ্গ)',
  'experience': 'Experience',
  'documents': 'Required Documents (প্রয়োজনীয় কাগজপত্র)',
  'deadline': 'Application Deadline',
  'processing': 'Processing Time',
};
