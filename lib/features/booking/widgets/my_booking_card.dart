import 'package:flutter/material.dart';

import '../../../common/theme/app_palette.dart';

class MyBookingCard extends StatelessWidget {
  const MyBookingCard({
    super.key,
    required this.postId,
    required this.bookingId,
    required this.serviceType,
    required this.statusLabel,
    required this.customerName,
    required this.passportNo,
    required this.packagePrice,
    required this.paidAmount,
    required this.dateText,
    this.onLongPress,
    this.onActionTap,
  });

  final String postId;
  final int bookingId;
  final String serviceType;
  final String statusLabel;
  final String customerName;
  final String passportNo;
  final int packagePrice;
  final int paidAmount;
  final String dateText;
  final VoidCallback? onLongPress;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Post #$postId • Booking #$bookingId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textMuted,
                      ),
                    ),
                  ),
                  if (onActionTap != null)
                    InkWell(
                      onTap: onActionTap,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_vert,
                          color: AppPalette.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      serviceType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.textStrongBlue,
                      ),
                    ),
                  ),
                  _statusChip(statusLabel),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5ECF8)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 18,
                          color: AppPalette.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: AppPalette.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            passportNo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFDCE6F5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _moneyCell(label: 'Package', amount: packagePrice),
                  ),
                  _moneyCell(label: 'Paid', amount: paidAmount, alignEnd: true),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFDCE6F5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: AppPalette.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moneyCell({
    required String label,
    required int amount,
    bool alignEnd = false,
  }) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
      ),
      const SizedBox(height: 2),
      Text(
        '৳ $amount',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: alignEnd ? AppPalette.brandBlue : AppPalette.textPrimary,
        ),
      ),
    ],
  );

  Widget _statusChip(String status) {
    final low = status.toLowerCase();
    Color bg = const Color(0xFFEAF1FF);
    Color fg = AppPalette.textStrongBlue;
    if (low.contains('complete') ||
        low.contains('success') ||
        low.contains('handover')) {
      bg = const Color(0xFFE7F8EE);
      fg = const Color(0xFF1E7A45);
    } else if (low.contains('pending') ||
        low.contains('processing') ||
        low.contains('collect')) {
      bg = const Color(0xFFFFF4DC);
      fg = const Color(0xFF9A6700);
    } else if (low.contains('reject') || low.contains('return request')) {
      bg = const Color(0xFFFFE7EA);
      fg = const Color(0xFFA32638);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
