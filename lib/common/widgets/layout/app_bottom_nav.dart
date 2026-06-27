import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';

import '../../theme/app_palette.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.primaryColor = const Color(0xFF2563EB),
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallDevice = screenWidth < 360;
    final navHorizontalPadding = isSmallDevice ? 8.0 : 12.0;
    final navVerticalPadding = isSmallDevice ? 6.0 : 10.0;
    final itemHorizontalPadding = isSmallDevice ? 2.0 : 4.0;
    final selectedHorizontalPadding = isSmallDevice ? 8.0 : 12.0;
    final selectedVerticalPadding = isSmallDevice ? 5.0 : 7.0;
    final unselectedVerticalPadding = isSmallDevice ? 7.0 : 10.0;
    final iconSize = isSmallDevice ? 24.0 : 28.0;
    final selectedIconSize = isSmallDevice ? 20.0 : 23.0;
    final labelFontSize = isSmallDevice ? 9.0 : 10.0;
    final prominentButtonSize = isSmallDevice ? 44.0 : 52.0;
    final prominentIconSize = isSmallDevice ? 28.0 : 34.0;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppPalette.surface,
            border: Border(top: BorderSide(color: AppPalette.borderNeutral)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                minimum: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: navHorizontalPadding,
                    vertical: navVerticalPadding,
                  ),
                  child: Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == currentIndex;

                      if (item.isProminent) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(index),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: prominentButtonSize,
                                  height: prominentButtonSize,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF1D4ED8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white,
                                    size: prominentIconSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: itemHorizontalPadding,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => onTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected
                                      ? selectedHorizontalPadding
                                      : 0,
                                  vertical: isSelected
                                      ? selectedVerticalPadding
                                      : unselectedVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0x1A2563EB)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          scale: isSelected ? 0.88 : 1.0,
                                          child: FUI(
                                            isSelected
                                                ? item.selectedIcon
                                                : item.icon,
                                            width: isSelected
                                                ? selectedIconSize
                                                : iconSize,
                                            height: isSelected
                                                ? selectedIconSize
                                                : iconSize,
                                            color: isSelected
                                                ? primaryColor
                                                : const Color(0xFF98A1AF),
                                          ),
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          transitionBuilder:
                                              (child, animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: SizeTransition(
                                                    sizeFactor: animation,
                                                    axis: Axis.vertical,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                          child: isSelected
                                              ? Padding(
                                                  key: ValueKey(item.label),
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 1,
                                                      ),
                                                  child: Text(
                                                    item.label,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: labelFontSize,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(
                                                  key: ValueKey('no-label'),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isProminent = false,
  });

  final String label;
  final String icon;
  final String selectedIcon;
  final bool isProminent;
}

const List<_BottomNavItem> _items = [
  _BottomNavItem(
    label: 'Home',
    icon: RegularStraight.HOME,
    selectedIcon: RegularStraight.HOME,
  ),
  _BottomNavItem(
    label: 'Search',
    icon: RegularStraight.SEARCH,
    selectedIcon: RegularStraight.SEARCH,
  ),
  _BottomNavItem(
    label: 'Appointment',
    icon: '',
    selectedIcon: '',
    isProminent: true,
  ),
  _BottomNavItem(
    label: 'Chat',
    icon: RegularStraight.COMMENT,
    selectedIcon: RegularStraight.COMMENT,
  ),
  _BottomNavItem(
    label: 'Profile',
    icon: RegularStraight.USER,
    selectedIcon: RegularStraight.USER,
  ),
];
