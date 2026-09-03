import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../cubit/active_group_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;

  const GroupDetailPage({super.key, required this.groupId});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsBloc>().add(LoadGroupDetailsEvent(widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  void _syncActiveRole(MembersState state) {
    if (state is! MembersLoaded) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final me = state.members.where((m) => m.userId == authState.user.id);
    if (me.isEmpty) return;
    context.read<ActiveGroupCubit>().setRole(me.first.role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Overview'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<GroupsBloc, GroupsState>(
            listener: (context, state) {
              if (state is GroupDetailsLoaded) {
                context.read<ActiveGroupCubit>().setGroup(
                      groupId: state.group.id,
                      groupName: state.group.name,
                    );
              }
            },
          ),
          BlocListener<MembersBloc, MembersState>(listener: (_, s) => _syncActiveRole(s)),
        ],
        child: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const AppLoader(message: 'Loading group details...');
          } else if (state is GroupsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<GroupsBloc>().add(LoadGroupDetailsEvent(widget.groupId)),
            );
          } else if (state is GroupDetailsLoaded) {
            final group = state.group;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.name,
                                      style: AppTextStyles.headingSmall,
                                    ),
                                    if (group.location != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        group.location!,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (group.meetingDay != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Meeting Day: ${group.meetingDay}',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Rules Card
                  Text('Group Rules & Rates', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _RuleRow(
                            icon: Icons.payments_outlined,
                            title: 'Weekly Contribution',
                            value: CurrencyFormatter.format(group.weeklyContribution),
                          ),
                          const Divider(),
                          _RuleRow(
                            icon: Icons.pie_chart_outline,
                            title: 'Share Unit Price',
                            value: CurrencyFormatter.format(group.sharePrice),
                          ),
                          const Divider(),
                          _RuleRow(
                            icon: Icons.gavel_outlined,
                            title: 'Default Fine Amount',
                            value: CurrencyFormatter.format(group.fineDefaultAmount),
                          ),
                          const Divider(),
                          _RuleRow(
                            icon: Icons.percent,
                            title: 'Loan Interest Rate',
                            value: '${group.loanInterestRate.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Feature Access Shortcuts
                  Text('Manage & Activities', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                    children: [
                      _FeatureTile(
                        icon: Icons.people_alt_outlined,
                        label: 'Members',
                        color: AppColors.primary,
                        onTap: () => context.pushNamed(
                          RouteNames.members,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.payments_outlined,
                        label: 'Contributions',
                        color: AppColors.primaryAccent,
                        onTap: () => context.pushNamed(
                          RouteNames.contributions,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.pie_chart_outline,
                        label: 'Shares',
                        color: AppColors.secondary,
                        onTap: () => context.pushNamed(
                          RouteNames.shares,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Loans',
                        color: Colors.indigo,
                        onTap: () => context.pushNamed(
                          RouteNames.loans,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.gavel_outlined,
                        label: 'Fines',
                        color: Colors.deepOrange,
                        onTap: () => context.pushNamed(
                          RouteNames.fines,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.receipt_outlined,
                        label: 'Expenses',
                        color: Colors.brown,
                        onTap: () => context.pushNamed(
                          RouteNames.expenses,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.event_note_outlined,
                        label: 'Meetings',
                        color: Colors.teal,
                        onTap: () => context.pushNamed(
                          RouteNames.meetings,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.analytics_outlined,
                        label: 'Reports',
                        color: Colors.purple,
                        onTap: () => context.pushNamed(
                          RouteNames.reports,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                      _FeatureTile(
                        icon: Icons.history_edu_outlined,
                        label: 'Audit Log',
                        color: Colors.blueGrey,
                        onTap: () => context.pushNamed(
                          RouteNames.auditLogs,
                          pathParameters: {'groupId': group.id},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _RuleRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
