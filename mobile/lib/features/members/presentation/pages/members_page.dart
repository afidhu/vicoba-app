import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../../../transactions/presentation/bloc/transactions_bloc.dart';
import '../../../transactions/presentation/bloc/transactions_event.dart';
import '../../../transactions/presentation/bloc/transactions_state.dart';
import '../../domain/entities/member.dart';
import '../bloc/members_bloc.dart';
import '../bloc/members_event.dart';
import '../bloc/members_state.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/role_badge.dart';

class MembersPage extends StatefulWidget {
  final String groupId;

  const MembersPage({super.key, required this.groupId});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final canManage = Permissions.canManageMembers(
      context.watch<ActiveGroupCubit>().state.role,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(
                Icons.person_add_alt_1_outlined,
                color: AppColors.primary,
              ),
              tooltip: 'Register Member',
              onPressed: () => AddMemberDialog.show(context, widget.groupId),
            ),
        ],
      ),
      body: BlocConsumer<MembersBloc, MembersState>(
        listener: (context, state) {
          if (state is MemberOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MembersLoading) {
            return const AppLoader(message: 'Loading group members...');
          } else if (state is MembersError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<MembersBloc>().add(
                LoadMembersEvent(widget.groupId),
              ),
            );
          } else if (state is MembersLoaded) {
            final filteredMembers = state.members.where((m) {
              final query = _searchQuery.toLowerCase();
              return m.name.toLowerCase().contains(query) ||
                  (m.phone != null && m.phone!.contains(query)) ||
                  m.role.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search members by name or phone...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Members: ${state.members.length}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Active: ${state.members.where((m) => m.isActive).length}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredMembers.isEmpty
                      ? AppEmptyState(
                          title: _searchQuery.isEmpty
                              ? 'No Members Registered'
                              : 'No Results Found',
                          subtitle: _searchQuery.isEmpty
                              ? 'The group does not have any members registered yet.'
                              : 'No member matches "$_searchQuery".',
                          icon: Icons.person_search_outlined,
                          actionLabel: (_searchQuery.isEmpty && canManage)
                              ? 'Register Member'
                              : null,
                          onAction: (_searchQuery.isEmpty && canManage)
                              ? () => AddMemberDialog.show(
                                  context,
                                  widget.groupId,
                                )
                              : null,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<MembersBloc>().add(
                              LoadMembersEvent(widget.groupId),
                            );
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredMembers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final member = filteredMembers[index];

                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showMemberProfile(member),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: member.isActive
                                              ? AppColors.primaryLight
                                              : Colors.grey.shade200,
                                          child: Text(
                                            member.name.isNotEmpty
                                                ? member.name[0].toUpperCase()
                                                : 'M',
                                            style: TextStyle(
                                              color: member.isActive
                                                  ? AppColors.primary
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      member.name,
                                                      style: AppTextStyles
                                                          .headingSmall,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  RoleBadge(role: member.role),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  if (member.phone != null) ...[
                                                    const Icon(
                                                      Icons.phone_outlined,
                                                      size: 13,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      member.phone!,
                                                      style: AppTextStyles
                                                          .bodySmall,
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                  const Icon(
                                                    Icons.pie_chart_outline,
                                                    size: 13,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${member.shareHoldings} shares',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Joined ${DateFormatter.format(member.joinedAt)}',
                                                style: AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showMemberProfile(Member member) {
    context.read<TransactionsBloc>().add(
      LoadTransactions(widget.groupId, memberId: member.id),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: AppTextStyles.headingMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  [
                    member.role,
                    if (member.phone?.isNotEmpty == true) member.phone!,
                    if (member.nidaNumber?.isNotEmpty == true)
                      'NIDA ${member.nidaNumber}',
                    '${member.shareHoldings} shares',
                  ].join('  •  '),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),
                Text('Recent Transactions', style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<TransactionsBloc, TransactionsState>(
                    builder: (context, transactionState) {
                      if (transactionState is TransactionsLoading ||
                          transactionState is TransactionsInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (transactionState is TransactionsError) {
                        return Center(child: Text(transactionState.message));
                      }
                      if (transactionState is TransactionsLoaded) {
                        final transactions = transactionState.transactions
                            .take(10)
                            .toList();
                        if (transactions.isEmpty) {
                          return const Center(
                            child: Text(
                              'No transactions recorded for this member.',
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final isOut =
                                transaction.direction == 'OUT' ||
                                (transaction.direction == null &&
                                    (transaction.type == 'LOAN_DISBURSEMENT' ||
                                        transaction.type == 'EXPENSE'));
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                transaction.type.replaceAll('_', ' '),
                              ),
                              subtitle: Text(
                                [
                                  DateFormat(
                                    'MMM dd, yyyy HH:mm',
                                  ).format(transaction.transactionDate),
                                  if (transaction.description?.isNotEmpty ==
                                      true)
                                    transaction.description!,
                                ].join('  •  '),
                              ),
                              trailing: Text(
                                '${isOut ? '-' : '+'} TSH ${transaction.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isOut ? Colors.red : Colors.green,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
