import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/services/api_client.dart';
import '../common/widgets/layout/app_scaffold.dart';
import '../features/auth/agent_sign_up_thank_you_screen.dart';
import '../features/auth/recruiting_sign_up_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/onboarding/get_started_screen.dart';
import '../features/onboarding/splash_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Widget _recruitingAgencySignUpScreen(
  BuildContext context,
  GoRouterState state,
) {
  return RecruitingSignUpScreen(
    agencyType: state.uri.queryParameters['type'] ?? 'recruiting',
  );
}

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

Future<String?> _authRedirect(BuildContext context, GoRouterState state) async {
  final location = state.uri.path;
  final isAuthRoute = location == AppRoutes.splash ||
      location == AppRoutes.login ||
      location == AppRoutes.getStarted ||
      location == AppRoutes.signUpCustomer ||
      location == AppRoutes.agentSignUp ||
      location == AppRoutes.agencySignUp ||
      location == AppRoutes.recruitingSignUp ||
      location == AppRoutes.agentSignUpThankYou ||
      location == AppRoutes.otpVerify;

  if (isAuthRoute) return null;

  final cookies = await ApiClient().tokenStorage.getCookies();
  final isLoggedIn = cookies != null && cookies.isNotEmpty;
  return isLoggedIn ? null : AppRoutes.login;
}

final GoRouter appRouter = GoRouter(
  redirect: _authRedirect,
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.getStarted,
      builder: (context, state) => const GetStartedScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUpCustomer,
      // Keep legacy paths, but send users directly to recruiting agency sign up.
      builder: _recruitingAgencySignUpScreen,
    ),
    GoRoute(
      path: AppRoutes.agentSignUp,
      // Keep legacy paths, but send users directly to recruiting agency sign up.
      builder: _recruitingAgencySignUpScreen,
    ),
    GoRoute(
      path: AppRoutes.agencySignUp,
      builder: _recruitingAgencySignUpScreen,
    ),
    GoRoute(
      path: AppRoutes.recruitingSignUp,
      builder: _recruitingAgencySignUpScreen,
    ),
    GoRoute(
      path: AppRoutes.agentSignUpThankYou,
      builder: (context, state) => const AgentSignUpThankYouScreen(),
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
          _slideTransition(c, s, AppScaffold(tabIndex: 1, queryParams: s.uri.queryParameters)),
    ),
    GoRoute(
      path: AppRoutes.tabBooking,
      pageBuilder: (c, s) =>
          _slideTransition(c, s, const AppScaffold(tabIndex: 2)),
    ),
    GoRoute(
      path: '/dashboard/ads/create',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        const AppScaffold(dashboardPath: '/dashboard/ads/create', tabIndex: 2),
      ),
    ),
    GoRoute(
      path: '/dashboard/ads/edit/:lang/:id',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 2),
      ),
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
    GoRoute(
      path: '/dashboard/:a/:b/:c/:d/:e',
      pageBuilder: (c, s) => _slideTransition(
        c,
        s,
        AppScaffold(dashboardPath: s.uri.path, tabIndex: 4),
      ),
    ),
  ],
);
