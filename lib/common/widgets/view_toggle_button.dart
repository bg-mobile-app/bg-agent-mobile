import 'package:flutter/material.dart';

class ViewToggleButton extends StatelessWidget {
  const ViewToggleButton({
    super.key,
    required this.isCardView,
    required this.onChanged,
  });

  final bool isCardView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isCardView
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 50,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Icon(
                      Icons.grid_view_outlined,
                      size: 22,
                      color: isCardView
                          ? const Color(0xFF004AC6)
                          : const Color(0xFF434655),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Icon(
                      Icons.list_outlined,
                      size: 22,
                      color: !isCardView
                          ? const Color(0xFF004AC6)
                          : const Color(0xFF434655),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
