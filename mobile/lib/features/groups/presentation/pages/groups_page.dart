import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../widgets/group_card.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupsBloc>().add(LoadGroupsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My VICOBA Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Create New Group',
            onPressed: () => context.pushNamed(RouteNames.createGroup),
          ),
        ],
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const AppLoader(message: 'Loading your groups...');
          } else if (state is GroupsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<GroupsBloc>().add(LoadGroupsEvent()),
            );
          } else if (state is GroupsLoaded) {
            if (state.groups.isEmpty) {
              return AppEmptyState(
                title: 'No Groups Found',
                subtitle: 'You are not a member of any VICOBA group yet. Create a group or ask your group chairperson to add you.',
                icon: Icons.groups_outlined,
                actionLabel: 'Create Group',
                onAction: () => context.pushNamed(RouteNames.createGroup),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GroupsBloc>().add(LoadGroupsEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  final isActive = state.activeGroup?.id == group.id;

                  return GroupCard(
                    group: group,
                    isActive: isActive,
                    onTap: () {
                      context.read<GroupsBloc>().add(
                        SelectActiveGroupEvent(
                          groupId: group.id,
                          groupName: group.name,
                        ),
                      );
                      context.pushNamed(
                        RouteNames.groupDetails,
                        pathParameters: {'groupId': group.id},
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
