import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/members/presentation/bloc/members_bloc.dart';
import 'features/contributions/presentation/bloc/contributions_bloc.dart';
import 'features/shares/presentation/bloc/shares_bloc.dart';
import 'features/loans/presentation/bloc/loans_bloc.dart';
import 'features/repayments/presentation/bloc/repayments_bloc.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';
import 'features/meetings/presentation/bloc/meetings_bloc.dart';
import 'features/transactions/presentation/bloc/transactions_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/fines/presentation/bloc/fines_bloc.dart';
import 'features/groups/presentation/cubit/active_group_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
        BlocProvider(create: (context) => di.sl<ActiveGroupCubit>()..hydrate()),
        BlocProvider(create: (context) => di.sl<GroupsBloc>()),
        BlocProvider(create: (context) => di.sl<DashboardBloc>()),
        BlocProvider(create: (context) => di.sl<MembersBloc>()),
        BlocProvider(create: (context) => di.sl<ContributionsBloc>()),
        BlocProvider(create: (context) => di.sl<SharesBloc>()),
        BlocProvider(create: (context) => di.sl<LoansBloc>()),
        BlocProvider(create: (context) => di.sl<RepaymentsBloc>()),
        BlocProvider(create: (context) => di.sl<ExpensesBloc>()),
        BlocProvider(create: (context) => di.sl<MeetingsBloc>()),
        BlocProvider(create: (context) => di.sl<TransactionsBloc>()),
        BlocProvider(create: (context) => di.sl<ReportsBloc>()),
        BlocProvider(create: (context) => di.sl<FinesBloc>()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final _router = AppRouter.create(context.read<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VICOBA Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
