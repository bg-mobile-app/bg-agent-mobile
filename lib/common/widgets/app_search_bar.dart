import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSearchTap,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isSmallDevice = availableWidth < 360;
        final horizontalPadding = isSmallDevice ? AppSpacing.sm : AppSpacing.md;
        final actionPadding = isSmallDevice ? 10.0 : 12.0;
        final actionRadius = isSmallDevice ? 12.0 : 14.0;
        final iconSize = isSmallDevice ? 18.0 : 20.0;

        return Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppPalette.borderSoftBlue),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D2563EB),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.black),
                  minLines: 1,
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    isDense: isSmallDevice,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallDevice ? 10 : 12,
                    ),
                    fillColor: Colors.white,
                    hintText: hintText,
                    hintStyle: AppTextStyles.body2.copyWith(
                      fontSize: isSmallDevice ? 13 : null,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onSearchTap?.call(),
                ),
              ),
              SizedBox(width: isSmallDevice ? 6 : 8),
              InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(actionRadius),
                child: Container(
                  padding: EdgeInsets.all(actionPadding),
                  decoration: BoxDecoration(
                    color: AppPalette.brandBlue,
                    borderRadius: BorderRadius.circular(actionRadius),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x402563EB),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
