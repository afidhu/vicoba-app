import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../../groups/presentation/bloc/groups_event.dart';
import '../../../groups/presentation/bloc/groups_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_metric_card.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsBloc>().add(LoadGroupsEvent());
  }

  String? _lastSyncedGroupId;

  void _loadDashboardForGroup(String groupId, [String? groupName]) {
    context.read<DashboardBloc>().add(LoadDashboardSummaryEvent(groupId));
    if (_lastSyncedGroupId != groupId) {
      _lastSyncedGroupId = groupId;
      if (groupName != null) {
        context.read<ActiveGroupCubit>().setGroup(groupId: groupId, groupName: groupName);
      }
      context.read<MembersBloc>().add(LoadMembersEvent(groupId));
    }
  }

  void _syncRole(MembersState state) {
    if (state is! MembersLoaded) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;
    final me = state.members.where((m) => m.userId == auth.user.id);
    if (me.isNotEmpty) {
      context.read<ActiveGroupCubit>().setRole(me.first.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('VICOBA Hub'),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              onSelected: (value) {
                final gid = context.read<ActiveGroupCubit>().state.groupId;
                switch (value) {
                  case 'groups':
                    context.pushNamed(RouteNames.groups);
                    break;
                  case 'profile':
                    context.pushNamed(RouteNames.profile);
                    break;
                  case 'reports':
                    if (gid != null) {
                      context.pushNamed(RouteNames.reports,
                          pathParameters: {'groupId': gid});
                    }
                    break;
                  case 'meetings':
                    if (gid != null) {
                      context.pushNamed(RouteNames.meetings,
                          pathParameters: {'groupId': gid});
                    }
                    break;
                  case 'audit':
                    if (gid != null) {
                      context.pushNamed(RouteNames.auditLogs,
                          pathParameters: {'groupId': gid});
                    }
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'groups', child: Text('My Groups')),
                PopupMenuItem(value: 'reports', child: Text('Reports')),
                PopupMenuItem(value: 'meetings', child: Text('Meetings')),
                PopupMenuItem(value: 'audit', child: Text('Audit Log')),
                PopupMenuItem(value: 'profile', child: Text('Profile')),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<MembersBloc, MembersState>(
        listener: (context, s) => _syncRole(s),
        child: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, groupState) {
          if (groupState is GroupsLoaded && groupState.activeGroup != null) {
            _loadDashboardForGroup(
              groupState.activeGroup!.id,
              groupState.activeGroup!.name,
            );
          }
        },
        builder: (context, groupState) {
          if (groupState is GroupsLoading) {
            return const AppLoader(message: 'Loading groups...');
          } else if (groupState is GroupsError) {
            return AppErrorWidget(
              message: groupState.message,
              onRetry: () => context.read<GroupsBloc>().add(LoadGroupsEvent()),
            );
          } else if (groupState is GroupsLoaded) {
            if (groupState.groups.isEmpty) {
              return AppEmptyState(
                title: 'No Groups Available',
                subtitle: 'You are not assigned to any VICOBA group yet. Create your group or ask your group chairperson to add you.',
                icon: Icons.groups_outlined,
                actionLabel: 'Create Group',
                onAction: () => context.pushNamed(RouteNames.createGroup),
              );
            }

            final activeGroup = groupState.activeGroup ?? groupState.groups.first;

            return RefreshIndicator(
              onRefresh: () async {
                _loadDashboardForGroup(activeGroup.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Selector Dropdown / Header
                    _GroupSelectorBar(
                      groups: groupState.groups,
                      activeGroup: activeGroup,
                      onGroupChanged: (group) {
                        if (group != null) {
                          context.read<GroupsBloc>().add(
                            SelectActiveGroupEvent(
                              groupId: group.id,
                              groupName: group.name,
                            ),
                          );
                          _loadDashboardForGroup(group.id);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dashboard Data
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, dashState) {
                        if (dashState is DashboardLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.0),
                            child: AppLoader(message: 'Updating group financial summary...'),
                          );
                        } else if (dashState is DashboardError) {
                          return AppErrorWidget(
                            message: dashState.message,
                            onRetry: () => _loadDashboardForGroup(activeGroup.id),
                          );
                        } else if (dashState is DashboardLoaded) {
                          final summary = dashState.summary;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Financial Metric Cards Grid
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.35,
                                children: [
                                  SummaryMetricCard(
                                    title: 'Total Contributions',
                                    value: CurrencyFormatter.format(summary.totals.totalContributions),
                                    icon: Icons.payments_outlined,
                                    color: AppColors.primary,
                                    subtitle: 'Weekly savings',
                                    onTap: () => context.pushNamed(
                                      RouteNames.contributions,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                  SummaryMetricCard(
                                    title: 'Share Capital',
                                    value: CurrencyFormatter.format(summary.totals.totalShareCapital),
                                    icon: Icons.pie_chart_outline,
                                    color: AppColors.secondary,
                                    subtitle: 'Value: ${CurrencyFormatter.format(summary.group.sharePrice)}/sh',
                                    onTap: () => context.pushNamed(
                                      RouteNames.shares,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                  SummaryMetricCard(
                                    title: 'Outstanding Loans',
                                    value: CurrencyFormatter.format(summary.totals.outstandingLoans),
                                    icon: Icons.account_balance_wallet_outlined,
                                    color: Colors.indigo,
                                    subtitle: '${summary.counts.activeLoans} active loans',
                                    onTap: () => context.pushNamed(
                                      RouteNames.loans,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                  SummaryMetricCard(
                                    title: 'Unpaid Fines',
                                    value: CurrencyFormatter.format(summary.totals.unpaidFines),
                                    icon: Icons.gavel_outlined,
                                    color: summary.totals.unpaidFines > 0 ? AppColors.error : AppColors.success,
                                    subtitle: summary.totals.unpaidFines > 0 ? 'Pending collection' : 'All clear',
                                    onTap: () => context.pushNamed(
                                      RouteNames.fines,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                  SummaryMetricCard(
                                    title: 'Group Expenses',
                                    value: CurrencyFormatter.format(summary.totals.totalExpenses),
                                    icon: Icons.receipt_outlined,
                                    color: Colors.brown,
                                    subtitle: 'Total recorded',
                                    onTap: () => context.pushNamed(
                                      RouteNames.expenses,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                  SummaryMetricCard(
                                    title: 'Active Members',
                                    value: '${summary.counts.activeMembers} / ${summary.counts.totalMembers}',
                                    icon: Icons.people_outline,
                                    color: Colors.teal,
                                    subtitle: 'Group members',
                                    onTap: () => context.pushNamed(
                                      RouteNames.members,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Quick Action Shortcuts
                              Text('Quick Actions', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _QuickActionButton(
                                      icon: Icons.payments,
                                      label: 'Record\nContribution',
                                      color: AppColors.primary,
                                      onTap: () => context.pushNamed(
                                        RouteNames.contributions,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _QuickActionButton(
                                      icon: Icons.add_chart,
                                      label: 'Purchase\nShares',
                                      color: AppColors.secondary,
                                      onTap: () => context.pushNamed(
                                        RouteNames.shares,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _QuickActionButton(
                                      icon: Icons.monetization_on_outlined,
                                      label: 'Issue\nLoan',
                                      color: Colors.indigo,
                                      onTap: () => context.pushNamed(
                                        RouteNames.loans,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _QuickActionButton(
                                      icon: Icons.gavel,
                                      label: 'Issue\nFine',
                                      color: Colors.deepOrange,
                                      onTap: () => context.pushNamed(
                                        RouteNames.fines,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _QuickActionButton(
                                      icon: Icons.receipt_long,
                                      label: 'Log\nExpense',
                                      color: Colors.brown,
                                      onTap: () => context.pushNamed(
                                        RouteNames.expenses,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _QuickActionButton(
                                      icon: Icons.event_note,
                                      label: 'Group\nMeeting',
                                      color: Colors.teal,
                                      onTap: () => context.pushNamed(
                                        RouteNames.meetings,
                                        pathParameters: {'groupId': activeGroup.id},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Recent Transactions Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Recent Transactions', style: AppTextStyles.headingSmall),
                                  TextButton(
                                    onPressed: () => context.pushNamed(
                                      RouteNames.transactions,
                                      pathParameters: {'groupId': activeGroup.id},
                                    ),
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (summary.recentTransactions.isEmpty)
                                const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Center(
                                      child: Text(
                                        'No recent transactions recorded for this group.',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: summary.recentTransactions.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final tx = summary.recentTransactions[index];
                                    final isIn = tx.direction == 'IN';

                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isIn
                                              ? AppColors.successLight
                                              : AppColors.errorLight,
                                          child: Icon(
                                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                                            color: isIn ? AppColors.success : AppColors.error,
                                            size: 18,
                                          ),
                                        ),
                                        title: Text(
                                          tx.description ?? tx.type.replaceAll('_', ' '),
                                          style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          '${tx.memberName != null ? "${tx.memberName} • " : ""}${DateFormatter.formatDateTime(tx.createdAt)}',
                                          style: AppTextStyles.caption,
                                        ),
                                        trailing: Text(
                                          '${isIn ? "+" : "-"}${CurrencyFormatter.format(tx.amount)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isIn ? AppColors.success : AppColors.error,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
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

class _GroupSelectorBar extends StatelessWidget {
  final List<Group> groups;
  final Group activeGroup;
  final ValueChanged<Group?> onGroupChanged;

  const _GroupSelectorBar({
    required this.groups,
    required this.activeGroup,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.group_work, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Group>(
                value: activeGroup,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                isExpanded: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                selectedItemBuilder: (BuildContext context) {
                  return groups.map<Widget>((Group group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (group.location != null)
                          Text(
                            group.location!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    );
                  }).toList();
                },
                items: groups.map((Group group) {
                  return DropdownMenuItem<Group>(
                    value: group,
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onGroupChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
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
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
