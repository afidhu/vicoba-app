import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
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
              icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
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
              onRetry: () => context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId)),
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
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Members: ${state.members.length}',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Active: ${state.members.where((m) => m.isActive).length}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredMembers.isEmpty
                      ? AppEmptyState(
                          title: _searchQuery.isEmpty ? 'No Members Registered' : 'No Results Found',
                          subtitle: _searchQuery.isEmpty
                              ? 'The group does not have any members registered yet.'
                              : 'No member matches "$_searchQuery".',
                          icon: Icons.person_search_outlined,
                          actionLabel:
                              (_searchQuery.isEmpty && canManage) ? 'Register Member' : null,
                          onAction: (_searchQuery.isEmpty && canManage)
                              ? () => AddMemberDialog.show(context, widget.groupId)
                              : null,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredMembers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final member = filteredMembers[index];

                              return Card(
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    member.name,
                                                    style: AppTextStyles.headingSmall,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                RoleBadge(role: member.role),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (member.phone != null) ...[
                                                  const Icon(Icons.phone_outlined,
                                                      size: 13, color: AppColors.textMuted),
                                                  const SizedBox(width: 4),
                                                  Text(member.phone!,
                                                      style: AppTextStyles.bodySmall),
                                                  const SizedBox(width: 12),
                                                ],
                                                const Icon(Icons.pie_chart_outline,
                                                    size: 13, color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${member.shareHoldings} shares',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
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
                                    ],
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
}
