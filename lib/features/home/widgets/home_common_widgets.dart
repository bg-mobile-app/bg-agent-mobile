import 'package:flutter/material.dart';

import 'home_responsive.dart';

class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.brandBlue,
  });

  final String label;
  final VoidCallback onTap;
  final Color brandBlue;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      height: responsive.size(36, min: 32, max: 38),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.size(12, min: 8, max: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.size(8, min: 7)),
          ),
          textStyle: TextStyle(
            fontSize: responsive.font(14, min: 12, max: 14),
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}


class AppBrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppBrandHeader({
    super.key,
    required this.brandBlue,
    required this.isLoggedIn,
    required this.onSignIn,
    required this.onSignUp,
    required this.onNotifications,
    required this.onProfile,
    this.profileImageUrl,
    this.backgroundColor = const Color(0xFFF5F8FF),
  });

  final Color brandBlue;
  final bool isLoggedIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final String? profileImageUrl;
  final Color backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final headerHeight = responsive.size(74, min: 62, max: 74);
    final logoHeight = responsive.size(48, min: 38, max: 48);
    final leadingWidth = responsive.size(88, min: 68, max: 88);
    final actionHeight = responsive.size(48, min: 40, max: 48);
    final actionWidth = responsive.size(96, min: 76, max: 96);
    final actionFontSize = responsive.font(15, min: 12, max: 15);
    final actionRadius = responsive.size(20, min: 16, max: 20);

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      toolbarHeight: headerHeight,
      automaticallyImplyLeading: false,
      leadingWidth: leadingWidth,
      leading: Padding(
        padding: EdgeInsets.only(left: responsive.size(12, min: 8, max: 12)),
        child: Image.asset(
          'assets/img/logo/logo_black.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      actions: [
        if (isLoggedIn) ...[
          IconButton(
            onPressed: onNotifications,
            iconSize: responsive.size(28, min: 22, max: 28),
            padding: EdgeInsets.all(responsive.size(8, min: 5, max: 8)),
            constraints: BoxConstraints.tightFor(
              width: responsive.size(48, min: 38, max: 48),
              height: responsive.size(48, min: 38, max: 48),
            ),
            icon: Badge(
              backgroundColor: Colors.red,
              smallSize: responsive.size(8, min: 6, max: 8),
              child: Icon(
                Icons.notifications_none,
                color: Colors.black87,
                size: responsive.size(28, min: 22, max: 28),
              ),
            ),
            tooltip: 'Notifications',
          ),
          SizedBox(width: responsive.size(8, min: 4, max: 8)),
          GestureDetector(
            onTap: onProfile,
            child: CircleAvatar(
              radius: responsive.size(18, min: 15, max: 18),
              backgroundColor: const Color(0xFFD7E3FF),
              backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? Icon(
                      Icons.person,
                      color: const Color(0xFF2563EB),
                      size: responsive.size(22, min: 18, max: 22),
                    )
                  : null,
            ),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: onSignIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: brandBlue,
              side: const BorderSide(color: Color(0xFFD7E3FF)),
              backgroundColor: Colors.white,
              minimumSize: Size(actionWidth, actionHeight),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.size(12, min: 8, max: 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(actionRadius),
              ),
              textStyle: TextStyle(
                fontSize: actionFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Sign In', maxLines: 1),
          ),
          SizedBox(width: responsive.size(10, min: 6, max: 10)),
          ElevatedButton(
            onPressed: onSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandBlue,
              foregroundColor: Colors.white,
              minimumSize: Size(actionWidth, actionHeight),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.size(12, min: 8, max: 12),
              ),
              elevation: 6,
              shadowColor: const Color(0x552563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(actionRadius),
              ),
              textStyle: TextStyle(
                fontSize: actionFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Sign Up', maxLines: 1),
          ),
        ],
        SizedBox(width: responsive.size(16, min: 8, max: 16)),
      ],
    );
  }
}
