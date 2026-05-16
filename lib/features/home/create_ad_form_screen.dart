import 'package:flutter/material.dart';

import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class CreateAdFormScreen extends StatefulWidget {
  const CreateAdFormScreen({super.key, required this.isBangla});

  final bool isBangla;

  @override
  State<CreateAdFormScreen> createState() => _CreateAdFormScreenState();
}

class _CreateAdFormScreenState extends State<CreateAdFormScreen> {
  int _currentStep = 0;

  String _tr(String en, String bn) => widget.isBangla ? bn : en;

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: '/dashboard/ads/create',
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            _topBar(),
            _progressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            _footerButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ImageUpload();
      case 1:
        return _buildStep2BasicInfo();
      case 2:
        return _buildStep3PaymentBreakdown();
      case 3:
        return _buildStep4DetailedDescription();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _topBar() => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Icon(Icons.arrow_back, color: AppPalette.brandBlue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _tr('Create New Ad', 'নতুন বিজ্ঞাপন তৈরি করুন'),
            style: const TextStyle(fontSize: 16, color: AppPalette.brandBlue, fontWeight: FontWeight.w700),
          ),
        ),
        Text('${_tr('Step', 'ধাপ')} ${_currentStep + 1} ${_tr('of', 'এর')} 4', style: const TextStyle(fontSize: 13, color: AppPalette.textMuted, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _progressBar() {
    return Container(
      height: 4,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / 4;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 0,
                top: 0,
                bottom: 0,
                width: stepWidth * (_currentStep + 1),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppPalette.brandBlue,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1ImageUpload() {
    return Container(
      key: const ValueKey(0),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.brandBlue.withOpacity(0.1), width: 2),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppPalette.brandBlue.withOpacity(0.05), shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_upload_outlined, color: AppPalette.brandBlue, size: 32),
                ),
                const SizedBox(height: 16),
                Text(_tr('Upload job poster or main image', 'কাজের পোস্টার বা প্রধান ছবি আপলোড করুন'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppPalette.textPrimary, height: 1.4)),
                const SizedBox(height: 6),
                const Text('(PNG, JPG, WEBP, Max 2MB)', style: TextStyle(fontSize: 12, color: AppPalette.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFEF3C7)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.report_problem_rounded, color: Color(0xFFB45309), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tr('Important Instruction', 'গুরুত্বপূর্ণ নির্দেশনা'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF78350F), letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(_tr('Do not include phone number/contact information in ads. Violation results in immediate post rejection.', 'বিজ্ঞাপনে ফোন নম্বর বা যোগাযোগের তথ্য অন্তর্ভুক্ত করবেন না। নিয়ম ভঙ্গ করলে পোস্ট বাতিল হবে।'), style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2BasicInfo() {
    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppPalette.brandBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description_outlined, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_tr('Basic Information', 'সাধারণ তথ্য'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.textPrimary))),
            ],
          ),
          const SizedBox(height: 32),
          _buildField(label: _tr('Country', 'দেশ'), hint: _tr('Select Country', 'দেশ নির্বাচন করুন'), isDropdown: true),
          const SizedBox(height: 24),
          _buildField(label: _tr('Type of Work', 'কাজের ধরন'), hint: _tr('Select Work Type', 'কাজের ধরন নির্বাচন করুন'), isDropdown: true),
          const SizedBox(height: 24),
          _buildField(label: _tr('Job Title', 'পদের নাম'), hint: _tr('e.g. Electrician', 'উদাঃ ইলেকট্রিশিয়ান')),
          const SizedBox(height: 24),
          
          Text(_tr('SALARY', 'বেতন'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppPalette.textMuted)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56, padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _tr('Amount', 'পরিমাণ'),
                      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 15, color: AppPalette.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 110, height: 56, padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppPalette.brandBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(18)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('SAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppPalette.brandBlue)),
                    SizedBox(width: 4),
                    Icon(Icons.expand_more, color: AppPalette.brandBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildField(label: _tr('Hours', 'ঘণ্টা'), hint: '8')),
              const SizedBox(width: 16),
              Expanded(child: _buildField(label: _tr('Days', 'দিন'), hint: '6')),
            ],
          ),
          const SizedBox(height: 24),
          _buildField(label: _tr('Contract', 'চুক্তি'), hint: _tr('2 Years', '২ বছর')),
          const SizedBox(height: 32),
          _buildGenderSelection(),
          const SizedBox(height: 32),
          _buildDocsSelection(),
          const SizedBox(height: 32),
          _buildPackageIncluded(),
        ],
      ),
    );
  }

  Widget _buildStep3PaymentBreakdown() {
    return Container(
      key: const ValueKey(2),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppPalette.brandBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.payments_outlined, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_tr('Payment Breakdown', 'পেমেন্ট বিবরণ'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.textPrimary))),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppPalette.brandBlue, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppPalette.brandBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tr('TOTAL PACKAGE', 'মোট প্যাকেজ'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
                        decoration: InputDecoration(
                          hintText: '4,50,000',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('SAR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _metricInputCard(_tr('CUSTOMER %', 'গ্রাহক %'), '10', const Color(0xFFEFF6FF), const Color(0xFFDBEAFE), const Color(0xFF1D4ED8), const Color(0xFF1E3A8A), hasCurrency: false)),
              const SizedBox(width: 16),
              Expanded(child: _metricInputCard(_tr('AGENT %', 'এজেন্ট %'), '5', const Color(0xFFFAF5FF), const Color(0xFFF3E8FF), const Color(0xFF7E22CE), const Color(0xFF581C87), hasCurrency: false)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _metricInputCard(_tr('ADVANCE', 'অগ্রিম'), '50,000', const Color(0xFFFFF7ED), const Color(0xFFFFEDD5), const Color(0xFFC2410C), const Color(0xFF78350F))),
              const SizedBox(width: 16),
              Expanded(child: _metricInputCard(_tr('AFTER VISA', 'ভিসার পর'), '2,00,000', const Color(0xFFF0FDF4), const Color(0xFFDCFCE7), const Color(0xFF15803D), const Color(0xFF14532D))),
            ],
          ),
          const SizedBox(height: 16),
          _metricInputCard(_tr('PRE-FLIGHT', 'ফ্লাইটের আগে'), '2,00,000', const Color(0xFFEEF2FF), const Color(0xFFE0E7FF), const Color(0xFF4338CA), const Color(0xFF312E81)),
        ],
      ),
    );
  }

  Widget _buildStep4DetailedDescription() {
    return Container(
      key: const ValueKey(3),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppPalette.brandBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.list_alt, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_tr('Detailed Description', 'বিস্তারিত বিবরণ'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppPalette.textPrimary))),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24)),
            child: TextField(
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _tr('Write detailed requirements, work conditions, specific skills needed...', 'বিস্তারিত প্রয়োজনীয়তা, কাজের শর্তাবলী লিখুন...'),
                hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8), height: 1.5),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, color: AppPalette.textPrimary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String hint, IconData? icon, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppPalette.textMuted)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 15, color: AppPalette.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              if (isDropdown) const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
              if (icon != null) Icon(icon, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr('GENDER', 'লিঙ্গ'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppPalette.textMuted)),
        const SizedBox(height: 8),
        Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppPalette.brandBlue, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppPalette.brandBlue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
                  child: Text(_tr('Male', 'পুরুষ'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
              Expanded(child: Center(child: Text(_tr('Female', 'মহিলা'), style: const TextStyle(color: AppPalette.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)))),
              Expanded(child: Center(child: Text(_tr('Any', 'যেকোনো'), style: const TextStyle(color: AppPalette.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr('DOCUMENTS', 'কাগজপত্র'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppPalette.textMuted)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: [
            _docChip(_tr('Passport', 'পাসপোর্ট'), true),
            _docChip(_tr('Photo', 'ছবি'), false),
            _docChip(_tr('Experience', 'অভিজ্ঞতা'), true),
            _docChip(_tr('Medical', 'মেডিকেল'), false),
          ],
        ),
      ],
    );
  }

  Widget _docChip(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppPalette.brandBlue : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppPalette.brandBlue : const Color(0xFFE2E8F0)),
        boxShadow: active ? [BoxShadow(color: AppPalette.brandBlue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : AppPalette.textMuted)),
          if (active) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, size: 16, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageIncluded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_tr('PACKAGE INCLUDED', 'প্যাকেজ সুবিধা'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppPalette.textMuted)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _packageItem(_tr('Ticket', 'টিকিট'), Icons.airplane_ticket_outlined, true),
            _packageItem(_tr('Hotel', 'হোটেল'), Icons.hotel_outlined, false),
            _packageItem(_tr('Food', 'খাবার'), Icons.restaurant_outlined, false),
            _packageItem(_tr('Medical', 'মেডিকেল'), Icons.medical_services_outlined, true),
          ],
        ),
      ],
    );
  }

  Widget _packageItem(String title, IconData icon, bool active) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppPalette.brandBlue.withOpacity(0.2) : Colors.transparent, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: active ? AppPalette.brandBlue : AppPalette.textMuted),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? AppPalette.brandBlue : AppPalette.textMuted)),
        ],
      ),
    );
  }

  Widget _metricInputCard(String label, String hint, Color bg, Color border, Color labelColor, Color valueColor, {bool hasCurrency = true}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: labelColor)),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor, height: 1.0),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: valueColor.withOpacity(0.4)),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              suffixText: hasCurrency ? '' : '%',
              suffixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_tr('Back', 'পেছনে'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppPalette.textPrimary)),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() => _currentStep++);
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep < 3 ? _tr('Next Step', 'পরবর্তী ধাপ') : _tr('Publish Ad', 'বিজ্ঞাপন দিন'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
