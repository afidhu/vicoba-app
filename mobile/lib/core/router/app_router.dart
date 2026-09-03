import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/loans/presentation/pages/loans_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import 'route_names.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/transactions/presentation/pages/audit_log_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/contributions/presentation/pages/contributions_page.dart';
import '../../features/shares/presentation/pages/shares_page.dart';
import '../../features/fines/presentation/pages/fines_page.dart';
import '../../features/meetings/presentation/pages/meetings_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Bridges a [Stream] into a [Listenable] so GoRouter re-evaluates `redirect`
/// whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  static const _authRoutes = {'/splash', '/login', '/register', '/forgot-password'};

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final loc = state.matchedLocation;
        final onAuthRoute = _authRoutes.contains(loc);

        if (authState is AuthInitial || authState is AuthLoading) {
          return loc == '/splash' ? null : '/splash';
        }
        if (authState is Authenticated) {
          return onAuthRoute ? '/' : null;
        }
        // Unauthenticated / AuthError
        return onAuthRoute && loc != '/splash' ? null : '/login';
      },
      routes: [
        GoRoute(path: '/splash', name: RouteNames.splash, builder: (c, s) => const SplashPage()),
        GoRoute(path: '/login', name: RouteNames.login, builder: (c, s) => const LoginPage()),
        GoRoute(path: '/register', name: RouteNames.register, builder: (c, s) => const RegisterPage()),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (c, s) => const ForgotPasswordPage(),
        ),
        GoRoute(path: '/', name: RouteNames.dashboard, builder: (c, s) => const DashboardPage()),
        GoRoute(path: '/groups', name: RouteNames.groups, builder: (c, s) => const GroupsPage()),
        GoRoute(
          path: '/groups/create',
          name: RouteNames.createGroup,
          builder: (c, s) => const CreateGroupPage(),
        ),
        GoRoute(
          path: '/group/:groupId',
          name: RouteNames.groupDetails,
          builder: (c, s) => GroupDetailPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/audit/:groupId',
          name: RouteNames.auditLogs,
          builder: (c, s) => AuditLogPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/members/:groupId',
          name: RouteNames.members,
          builder: (c, s) => MembersPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/contributions/:groupId',
          name: RouteNames.contributions,
          builder: (c, s) => ContributionsPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/shares/:groupId',
          name: RouteNames.shares,
          builder: (c, s) => SharesPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/fines/:groupId',
          name: RouteNames.fines,
          builder: (c, s) => FinesPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/loans/:groupId',
          name: RouteNames.loans,
          builder: (c, s) => LoansPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/expenses/:groupId',
          name: RouteNames.expenses,
          builder: (c, s) => ExpensesPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/transactions/:groupId',
          name: RouteNames.transactions,
          builder: (c, s) => TransactionsPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/meetings/:groupId',
          name: RouteNames.meetings,
          builder: (c, s) => MeetingsPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(
          path: '/reports/:groupId',
          name: RouteNames.reports,
          builder: (c, s) => ReportsPage(groupId: s.pathParameters['groupId']!),
        ),
        GoRoute(path: '/profile', name: RouteNames.profile, builder: (c, s) => const ProfilePage()),
      ],
    );
  }
}
