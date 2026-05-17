import 'package:flutter/material.dart';

import '../models/home_models.dart';

class WorkPermitCard extends StatelessWidget {
  const WorkPermitCard({
    super.key,
    required this.item,
    required this.brandBlue,
    required this.onViewDetails,
    required this.formatBdt,
    required this.timeAgo,
  });

  static const double _imageHeight = 250;
  static const double _titleHeight = 48;

  final WorkPermitItem item;
  final Color brandBlue;
  final VoidCallback onViewDetails;
  final String Function(int) formatBdt;
  final String Function(DateTime) timeAgo;

  bool get _isLottery => item.selectionType.toUpperCase() == 'LOTTERY';

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _titleHeight,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildMetaCell('Industry', item.workType),
                      Container(
                        width: 1,
                        height: 34,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: const Color(0xFFE2E8F0),
                      ),
                      _buildMetaCell(
                        'Posted',
                        timeAgo(item.createdAt),
                        isBlue: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Package Price',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'BDT ${formatBdt(item.customerPrice)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF1F5F9),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }
    return Image.asset(path, fit: fit);
  }

  Widget _buildImageHeader() {
    return SizedBox(
      height: _imageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(item.image),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImage(item.countryFlag),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.countryName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isLottery ? const Color(0xFF10B981) : brandBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.selectionType,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCell(String label, String value, {bool isBlue = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isBlue ? brandBlue : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
