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
            border: Border(
              top: BorderSide(color: AppPalette.borderNeutral),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                minimum: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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
                                  width: 52,
                                  height: 52,
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
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => onTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 12 : 0,
                                  vertical: isSelected ? 7 : 10,
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
                                            width: isSelected ? 23 : 28,
                                            height: isSelected ? 23 : 28,
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
                                                      fontSize: 10,
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
              const SizedBox(
                width: double.infinity,
                height: 22,
                child: ColoredBox(color: AppPalette.appcolor),
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
    label: 'Create Ad',
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
