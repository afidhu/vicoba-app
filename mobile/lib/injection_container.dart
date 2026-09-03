import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_group_summary_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/groups/data/datasources/groups_remote_datasource.dart';
import 'features/groups/data/repositories/groups_repository_impl.dart';
import 'features/groups/domain/repositories/groups_repository.dart';
import 'features/groups/domain/usecases/create_group_usecase.dart';
import 'features/groups/domain/usecases/get_group_details_usecase.dart';
import 'features/groups/domain/usecases/get_groups_usecase.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/members/data/datasources/members_remote_datasource.dart';
import 'features/members/data/repositories/members_repository_impl.dart';
import 'features/members/domain/repositories/members_repository.dart';
import 'features/members/domain/usecases/add_member_usecase.dart';
import 'features/members/domain/usecases/get_members_usecase.dart';
import 'features/members/domain/usecases/update_member_usecase.dart';
import 'features/members/presentation/bloc/members_bloc.dart';
import 'features/contributions/data/datasources/contributions_remote_datasource.dart';
import 'features/contributions/data/repositories/contributions_repository_impl.dart';
import 'features/contributions/domain/repositories/contributions_repository.dart';
import 'features/contributions/domain/usecases/get_contributions_usecase.dart';
import 'features/contributions/domain/usecases/record_contribution_usecase.dart';
import 'features/contributions/presentation/bloc/contributions_bloc.dart';
import 'features/shares/data/datasources/shares_remote_datasource.dart';
import 'features/shares/data/repositories/shares_repository_impl.dart';
import 'features/shares/domain/repositories/shares_repository.dart';
import 'features/shares/domain/usecases/buy_shares_usecase.dart';
import 'features/shares/domain/usecases/get_shares_usecase.dart';
import 'features/shares/presentation/bloc/shares_bloc.dart';
import 'features/loans/data/datasources/loans_remote_datasource.dart';
import 'features/loans/data/repositories/loans_repository_impl.dart';
import 'features/loans/domain/repositories/loans_repository.dart';
import 'features/loans/domain/usecases/loan_usecases.dart';
import 'features/loans/presentation/bloc/loans_bloc.dart';
import 'features/repayments/data/datasources/repayments_remote_datasource.dart';
import 'features/repayments/data/repositories/repayments_repository_impl.dart';
import 'features/repayments/domain/repositories/repayments_repository.dart';
import 'features/repayments/domain/usecases/repayment_usecases.dart';
import 'features/repayments/presentation/bloc/repayments_bloc.dart';
import 'features/expenses/data/datasources/expenses_remote_datasource.dart';
import 'features/expenses/data/repositories/expenses_repository_impl.dart';
import 'features/expenses/domain/repositories/expenses_repository.dart';
import 'features/expenses/domain/usecases/expense_usecases.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';
import 'features/meetings/data/datasources/meetings_remote_datasource.dart';
import 'features/meetings/data/repositories/meetings_repository_impl.dart';
import 'features/meetings/domain/repositories/meetings_repository.dart';
import 'features/meetings/domain/usecases/meeting_usecases.dart';
import 'features/meetings/presentation/bloc/meetings_bloc.dart';
import 'features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'features/transactions/data/repositories/transactions_repository_impl.dart';
import 'features/transactions/domain/repositories/transactions_repository.dart';
import 'features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'features/transactions/presentation/bloc/transactions_bloc.dart';
import 'features/reports/data/datasources/reports_remote_datasource.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/domain/usecases/report_usecases.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/fines/data/datasources/fines_remote_datasource.dart';
import 'features/fines/data/repositories/fines_repository_impl.dart';
import 'features/fines/domain/repositories/fines_repository.dart';
import 'features/fines/domain/usecases/fine_usecases.dart';
import 'features/fines/presentation/bloc/fines_bloc.dart';
import 'features/groups/presentation/cubit/active_group_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl(), storageService: sl()));
  sl.registerLazySingleton(() => ActiveGroupCubit(sl()));

  // Features - Auth
  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        getProfileUseCase: sl(),
        authRepository: sl(),
        storageService: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      storageService: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Features - Dashboard
  // Blocs
  sl.registerFactory(() => DashboardBloc(getGroupSummaryUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetGroupSummaryUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Groups
  // Blocs
  sl.registerFactory(() => GroupsBloc(
        getGroupsUseCase: sl(),
        getGroupDetailsUseCase: sl(),
        createGroupUseCase: sl(),
        storageService: sl(),
      ));
  // UseCases
  sl.registerLazySingleton(() => GetGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<GroupsRepository>(() => GroupsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<GroupsRemoteDataSource>(() => GroupsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Members
  // Blocs
  sl.registerFactory(() => MembersBloc(
        getMembersUseCase: sl(),
        addMemberUseCase: sl(),
        getMemberUseCase: sl(),
        updateMemberUseCase: sl(),
      ));
  // UseCases
  sl.registerLazySingleton(() => GetMembersUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => GetMemberUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMemberUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<MembersRepository>(() => MembersRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<MembersRemoteDataSource>(() => MembersRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Contributions
  // Blocs
  sl.registerFactory(() => ContributionsBloc(getContributionsUseCase: sl(), recordContributionUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetContributionsUseCase(sl()));
  sl.registerLazySingleton(() => RecordContributionUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<ContributionsRepository>(() => ContributionsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<ContributionsRemoteDataSource>(() => ContributionsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Shares
  // Blocs
  sl.registerFactory(() => SharesBloc(getSharesUseCase: sl(), buySharesUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetSharesUseCase(sl()));
  sl.registerLazySingleton(() => BuySharesUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<SharesRepository>(() => SharesRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<SharesRemoteDataSource>(() => SharesRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Loans
  // Blocs
  sl.registerFactory(() => LoansBloc(
        getLoansUseCase: sl(),
        requestLoanUseCase: sl(),
        approveLoanUseCase: sl(),
        rejectLoanUseCase: sl(),
      ));
  // UseCases
  sl.registerLazySingleton(() => GetLoansUseCase(sl()));
  sl.registerLazySingleton(() => RequestLoanUseCase(sl()));
  sl.registerLazySingleton(() => ApproveLoanUseCase(sl()));
  sl.registerLazySingleton(() => RejectLoanUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<LoansRepository>(() => LoansRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<LoansRemoteDataSource>(() => LoansRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Repayments
  // Blocs
  sl.registerFactory(() => RepaymentsBloc(getRepaymentsUseCase: sl(), recordRepaymentUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetRepaymentsUseCase(sl()));
  sl.registerLazySingleton(() => RecordRepaymentUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<RepaymentsRepository>(() => RepaymentsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<RepaymentsRemoteDataSource>(() => RepaymentsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Expenses
  // Blocs
  sl.registerFactory(() => ExpensesBloc(getExpensesUseCase: sl(), recordExpenseUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => RecordExpenseUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<ExpensesRepository>(() => ExpensesRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<ExpensesRemoteDataSource>(() => ExpensesRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Meetings
  // Blocs
  sl.registerFactory(() => MeetingsBloc(
        getMeetingsUseCase: sl(),
        createMeetingUseCase: sl(),
        getMeetingDetailsUseCase: sl(),
        recordAttendanceUseCase: sl(),
      ));
  // UseCases
  sl.registerLazySingleton(() => GetMeetingsUseCase(sl()));
  sl.registerLazySingleton(() => CreateMeetingUseCase(sl()));
  sl.registerLazySingleton(() => GetMeetingDetailsUseCase(sl()));
  sl.registerLazySingleton(() => RecordAttendanceUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<MeetingsRepository>(() => MeetingsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<MeetingsRemoteDataSource>(() => MeetingsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Transactions
  // Blocs
  sl.registerFactory(() => TransactionsBloc(getTransactionsUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<TransactionsRepository>(() => TransactionsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<TransactionsRemoteDataSource>(() => TransactionsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Reports
  // Blocs
  sl.registerFactory(() => ReportsBloc(getFinancialSummaryUseCase: sl(), getMemberReportUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetFinancialSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetMemberReportUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(remoteDataSource: sl()));
  // DataSources
  sl.registerLazySingleton<ReportsRemoteDataSource>(() => ReportsRemoteDataSourceImpl(dio: sl<DioClient>().dio));

  // Features - Fines
  sl.registerFactory(() => FinesBloc(
        getFinesUseCase: sl(),
        recordFineUseCase: sl(),
        updateFineStatusUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetFinesUseCase(sl()));
  sl.registerLazySingleton(() => RecordFineUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFineStatusUseCase(sl()));
  sl.registerLazySingleton<FinesRepository>(() => FinesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FinesRemoteDataSource>(() => FinesRemoteDataSourceImpl(dio: sl<DioClient>().dio));
}
