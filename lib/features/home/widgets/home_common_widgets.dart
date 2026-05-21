import 'package:flutter/material.dart';

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
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
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
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      toolbarHeight: 74,
      automaticallyImplyLeading: false,
      leadingWidth: 88,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/img/logo/logo_black.png',
          height: 48,
          fit: BoxFit.contain,
        ),
      ),
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      actions: [
        if (isLoggedIn) ...[
          IconButton(
            onPressed: onNotifications, 
            icon: const Badge(
              backgroundColor: Colors.red,
              smallSize: 8,
              child: Icon(Icons.notifications_none, color: Colors.black87, size: 28),
            ), 
            tooltip: 'Notifications'
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onProfile,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFD7E3FF),
              backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Color(0xFF2563EB))
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
              minimumSize: const Size(96, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: const Text('Sign In'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(96, 48),
              elevation: 6,
              shadowColor: const Color(0x552563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: const Text('Sign Up'),
          ),
        ],
        const SizedBox(width: 16),
      ],
    );
  }
}
