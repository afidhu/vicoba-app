import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../bloc/contributions_bloc.dart';
import '../bloc/contributions_event.dart';
import '../bloc/contributions_state.dart';
import '../widgets/record_contribution_dialog.dart';

class ContributionsPage extends StatefulWidget {
  final String groupId;

  const ContributionsPage({super.key, required this.groupId});

  @override
  State<ContributionsPage> createState() => _ContributionsPageState();
}

class _ContributionsPageState extends State<ContributionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContributionsBloc>().add(LoadContributionsEvent(groupId: widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final canRecord = Permissions.canRecordContribution(
      context.watch<ActiveGroupCubit>().state.role,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Contributions'),
        actions: [
          if (canRecord)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'Record Contribution',
              onPressed: () => RecordContributionDialog.show(context, widget.groupId),
            ),
        ],
      ),
      body: BlocConsumer<ContributionsBloc, ContributionsState>(
        listener: (context, state) {
          if (state is ContributionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ContributionsLoading) {
            return const AppLoader(message: 'Loading contributions...');
          } else if (state is ContributionsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ContributionsBloc>().add(
                    LoadContributionsEvent(groupId: widget.groupId),
                  ),
            );
          } else if (state is ContributionsLoaded) {
            if (state.contributions.isEmpty) {
              return AppEmptyState(
                title: 'No Contributions Recorded',
                subtitle: 'No weekly savings contributions recorded for this group yet.',
                icon: Icons.payments_outlined,
                actionLabel: canRecord ? 'Record First Contribution' : null,
                onAction: canRecord
                    ? () => RecordContributionDialog.show(context, widget.groupId)
                    : null,
              );
            }

            final double total = state.contributions.fold(0.0, (sum, c) => sum + c.amount);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ContributionsBloc>().add(
                      LoadContributionsEvent(groupId: widget.groupId),
                    );
              },
              child: Column(
                children: [
                  // Total summary header
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Contributions', style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(total),
                              style: AppTextStyles.headingSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.contributions.length} Records',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.contributions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = state.contributions[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: const Icon(Icons.payments_outlined,
                                  color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              item.memberName ?? 'Group Member',
                              style: AppTextStyles.headingSmall.copyWith(fontSize: 14),
                            ),
                            subtitle: Text(
                              'Week ending: ${DateFormatter.format(item.weekEnding)}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: Text(
                              '+${CurrencyFormatter.format(item.amount)}',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
