import 'package:flutter/material.dart';

import '../models/home_models.dart';
import 'home_responsive.dart';

class WorkPermitCard extends StatelessWidget {
  const WorkPermitCard({
    super.key,
    required this.item,
    required this.brandBlue,
    required this.onViewDetails,
    required this.formatBdt,
    required this.timeAgo,
  });

  final WorkPermitItem item;
  final Color brandBlue;
  final VoidCallback onViewDetails;
  final String Function(int) formatBdt;
  final String Function(DateTime) timeAgo;

  bool get _isLottery => item.selectionType.toUpperCase() == 'LOTTERY';

  @override
  Widget build(BuildContext context) {
    final screenResponsive = HomeResponsive.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenResponsive.width;
        final responsive = HomeResponsive.fromWidth(cardWidth);
        final contentPadding = responsive.size(18, min: 12, max: 18);
        final sectionGap = responsive.size(16, min: 10, max: 16);

        final cardRadius = BorderRadius.circular(
          responsive.size(28, min: 20, max: 28),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: cardRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onViewDetails,
              borderRadius: cardRadius,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: cardRadius,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImageHeader(responsive),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        contentPadding,
                        responsive.size(16, min: 12, max: 16),
                        contentPadding,
                        contentPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsive.font(20, min: 16, max: 20),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: responsive.size(14, min: 10, max: 14)),
                          Row(
                            children: [
                              _buildMetaCell('Job Type', item.workType, responsive),
                              Container(
                                width: 1,
                                height: responsive.size(34, min: 28, max: 34),
                                margin: EdgeInsets.symmetric(
                                  horizontal: responsive.size(14, min: 8, max: 14),
                                ),
                                color: const Color(0xFFE2E8F0),
                              ),
                              _buildMetaCell(
                                'Posted',
                                timeAgo(item.createdAt),
                                responsive,
                                isBlue: true,
                              ),
                            ],
                          ),
                          SizedBox(height: sectionGap),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          SizedBox(height: sectionGap),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Package Price',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: responsive.font(10, min: 8, max: 10),
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    SizedBox(
                                      height: responsive.size(4, min: 3, max: 4),
                                    ),
                                    Text(
                                      'BDT ${formatBdt(item.customerPrice)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: responsive.font(22, min: 16, max: 22),
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: responsive.size(12, min: 8, max: 12)),
                              ElevatedButton(
                                onPressed: onViewDetails,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandBlue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.size(18, min: 12, max: 18),
                                    vertical: responsive.size(14, min: 10, max: 14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      responsive.size(16, min: 12, max: 16),
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'View Details',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: responsive.font(13, min: 11, max: 13),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildImageHeader(HomeResponsive responsive) {
    return SizedBox(
      height: responsive.size(250, min: 180, max: 250),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(item.image),
          Positioned(
            left: responsive.size(14, min: 10, max: 14),
            top: responsive.size(14, min: 10, max: 14),
            child: _imageBadge(
              responsive: responsive,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: responsive.size(16, min: 12, max: 16),
                    height: responsive.size(16, min: 12, max: 16),
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImage(item.countryFlag),
                  ),
                  SizedBox(width: responsive.size(6, min: 4, max: 6)),
                  Flexible(
                    child: Text(
                      item.countryName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: responsive.font(10, min: 8, max: 10),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: responsive.size(14, min: 10, max: 14),
            top: responsive.size(14, min: 10, max: 14),
            child: _imageBadge(
              responsive: responsive,
              backgroundColor: _isLottery ? const Color(0xFF10B981) : brandBlue,
              child: Text(
                item.selectionType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsive.font(10, min: 8, max: 10),
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

  Widget _imageBadge({
    required HomeResponsive responsive,
    required Color backgroundColor,
    required Widget child,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: responsive.width * 0.52),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.size(10, min: 7, max: 10),
          vertical: responsive.size(6, min: 4, max: 6),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMetaCell(
    String label,
    String value,
    HomeResponsive responsive, {
    bool isBlue = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: responsive.font(10, min: 8, max: 10),
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: responsive.size(4, min: 3, max: 4)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: responsive.font(14, min: 11, max: 14),
              fontWeight: FontWeight.w700,
              color: isBlue ? brandBlue : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
