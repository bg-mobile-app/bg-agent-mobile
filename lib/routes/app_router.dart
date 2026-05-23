import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/widgets/layout/app_scaffold.dart';
import '../features/auth/agent_sign_up_screen.dart';
import '../features/auth/agent_sign_up_thank_you_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/onboarding/get_started_screen.dart';
import '../features/onboarding/splash_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage _slideTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart)),
        ),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(
      path: AppRoutes.getStarted,
      builder: (_, __) => const GetStartedScreen(),
    ),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const SignInScreen()),
    GoRoute(
      path: AppRoutes.signUpCustomer,
      // Keep legacy path, but only allow agent sign up.
      builder: (_, __) => const AgentSignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUpPartner,
      // Keep legacy path, but only allow agent sign up.
      builder: (_, __) => const AgentSignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.agentSignUp,
      builder: (_, __) => const AgentSignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.agentSignUpThankYou,
      builder: (_, __) => const AgentSignUpThankYouScreen(),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      builder: (_, state) => OtpVerificationScreen(
        username: state.uri.queryParameters['username'] ?? '',
        onVerifiedRoute: state.uri.queryParameters['next'],
      ),
    ),
    GoRoute(
      path: AppRoutes.tabHome,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 0)),
    ),
    GoRoute(
      path: AppRoutes.tabSearch,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 1)),
    ),
    GoRoute(
      path: AppRoutes.tabBooking,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 2)),
    ),
    GoRoute(
      path: AppRoutes.tabChat,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 3)),
    ),
    GoRoute(
      path: AppRoutes.tabProfile,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 4)),
    ),
    GoRoute(
      path: '/logout',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        const AppScaffold(dashboardPath: '/logout', tabIndex: 4),
      ),
    ),
    GoRoute(
      path: '/dashboard/:a',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 4),
      ),
    ),
    GoRoute(
      path: '/dashboard/:a/:b',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 4),
      ),
    ),
    GoRoute(
      path: '/dashboard/:a/:b/:c',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 4),
      ),
    ),
    GoRoute(
      path: '/dashboard/:a/:b/:c/:d',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 4),
      ),
    ),
  ],
);
