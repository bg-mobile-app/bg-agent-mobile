import 'package:flutter/material.dart';

import '../../../common/theme/app_palette.dart';

class ReceivedBookingCardStyle {
  const ReceivedBookingCardStyle({
    required this.badgeBg,
    required this.badgeText,
    required this.ctaLabel,
  });

  final Color badgeBg;
  final Color badgeText;
  final String ctaLabel;
}

class ReceivedBookingCard extends StatelessWidget {
  const ReceivedBookingCard({
    super.key,
    required this.bookingId,
    required this.postId,
    required this.statusText,
    required this.name,
    required this.passportNo,
    required this.createdAtText,
    required this.fromCountry,
    required this.toCountry,
    required this.medicalText,
    required this.visaText,
    required this.policeClearText,
    required this.totalCostText,
    required this.hasAdvancePayout,
    required this.hasAfterVisaPayout,
    required this.hasBeforeFlightPayout,
    required this.style,
    required this.onMoreTap,
    this.showMedical = false,
    this.showVisa = false,
    this.showPoliceClear = false,
  });

  final int bookingId;
  final String postId;
  final String statusText;
  final String name;
  final String passportNo;
  final String createdAtText;
  final String fromCountry;
  final String toCountry;
  final String medicalText;
  final String visaText;
  final String policeClearText;
  final String totalCostText;
  final bool hasAdvancePayout;
  final bool hasAfterVisaPayout;
  final bool hasBeforeFlightPayout;
  final ReceivedBookingCardStyle style;
  final VoidCallback onMoreTap;
  final bool showMedical;
  final bool showVisa;
  final bool showPoliceClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onMoreTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x334B5D7A), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 26,
              offset: Offset(0, 12),
            ),
            BoxShadow(
              color: Color(0x122563EB),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _profileSection(),
            const SizedBox(height: 20),
            _detailsSection(),
            const SizedBox(height: 16),
            _financialBar(),
            const SizedBox(height: 12),
            _payoutIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '#$bookingId',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: AppPalette.textStrongBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  style.badgeBg,
                  style.badgeBg.withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText.toUpperCase(),
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: style.badgeText,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            postId,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _pill('Passport: $passportNo', AppPalette.textMuted),
          const SizedBox(height: 8),
          _pill(createdAtText, AppPalette.textStrongBlue),
        ],
      ),
    );
  }

  Widget _detailsSection() {
    final hasClearance = showMedical || showVisa || showPoliceClear;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x334B5D7A)),
          bottom: BorderSide(color: Color(0x334B5D7A)),
        ),
      ),
      child: Column(
        children: [
          _routeRow(),
          if (hasClearance) ...[const SizedBox(height: 14), _clearanceRow()],
        ],
      ),
    );
  }

  Widget _routeRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              fromCountry,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.flight_takeoff_rounded,
              size: 18,
              color: AppPalette.textStrongBlue,
            ),
          ),
          Expanded(
            child: Text(
              toCountry,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearanceRow() {
    final cells = <Widget>[
      if (showMedical)
        Expanded(
          child: _clearanceCell(
            'Medical',
            medicalText,
            Icons.medical_services_outlined,
          ),
        ),
      if (showVisa)
        Expanded(
          child: _clearanceCell('Visa', visaText, Icons.verified_user_outlined),
        ),
      if (showPoliceClear)
        Expanded(
          child: _clearanceCell(
            'Police Clear',
            policeClearText,
            Icons.gavel_rounded,
          ),
        ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x334B5D7A)),
      ),
      child: Row(children: _withDividers(cells)),
    );
  }

  List<Widget> _withDividers(List<Widget> children) {
    if (children.length <= 1) return children;
    final output = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      output.add(children[i]);
      if (i != children.length - 1) {
        output.add(
          const SizedBox(
            height: 28,
            child: VerticalDivider(color: Color(0x334B5D7A), thickness: 1),
          ),
        );
      }
    }
    return output;
  }

  Widget _clearanceCell(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppPalette.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _financialBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF1FF), Color(0xFFDCE7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'TOTAL COST',
            style: TextStyle(
              fontSize: 12,
              color: AppPalette.textMuted,
              letterSpacing: .8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            totalCostText,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: AppPalette.textStrongBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutIndicators() {
    return Row(
      children: [
        Expanded(
          child: _payoutChip('ADVANCE', hasAdvancePayout, Icons.check_circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _payoutChip('PRE-VISA', hasAfterVisaPayout, Icons.pending),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _payoutChip('PRE-FLIGHT', hasBeforeFlightPayout, Icons.flight),
        ),
      ],
    );
  }

  Widget _payoutChip(String label, bool done, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF0FDF4) : const Color(0xFFE1E8FD),
        borderRadius: BorderRadius.circular(8),
        border: done ? Border.all(color: const Color(0xFFD1FAE5)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: done ? const Color(0xFF15803D) : const Color(0xFF737686),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: done ? const Color(0xFF15803D) : const Color(0xFF737686),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
