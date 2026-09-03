import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../../domain/entities/meeting.dart';
import '../bloc/meetings_bloc.dart';
import '../bloc/meetings_event.dart';
import '../bloc/meetings_state.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';

class MeetingsPage extends StatefulWidget {
  final String groupId;

  const MeetingsPage({super.key, required this.groupId});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingsBloc>().add(LoadMeetings(widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Meetings')),
      body: BlocConsumer<MeetingsBloc, MeetingsState>(
        listener: (context, state) {
          if (state is MeetingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting updated successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is MeetingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MeetingsLoaded) {
            return ListView.builder(
              itemCount: state.meetings.length,
              itemBuilder: (context, index) {
                final meeting = state.meetings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.event)),
                    title: Text(meeting.title),
                    subtitle: Text(
                      '${DateFormat('yyyy-MM-dd HH:mm').format(meeting.meetingDate)} | ${meeting.location ?? 'No location'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAttendanceDialog(context, meeting.id),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No meetings found.'));
        },
      ),
      floatingActionButton: Permissions.canManageMeetings(
              context.watch<ActiveGroupCubit>().state.role)
          ? FloatingActionButton(
              onPressed: () => _showCreateMeetingDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateMeetingDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Schedule Meeting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}',
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time != null && mounted) {
                    setState(() {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              this.context.read<MeetingsBloc>().add(
                CreateMeeting(
                  groupId: widget.groupId,
                  title: titleController.text,
                  meetingDate: selectedDate,
                  location: locationController.text,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, String meetingId) {
    final canManage = Permissions.canManageMeetings(
      context.read<ActiveGroupCubit>().state.role,
    );
    // In a real app, this would be a separate page or a more complex dialog
    // For now, we'll fetch the meeting details (which includes attendance)
    // and show a simplified attendance recording UI.
    context.read<MeetingsBloc>().add(LoadMeetingDetails(widget.groupId, meetingId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        builder: (_, scrollController) =>
            BlocBuilder<MeetingsBloc, MeetingsState>(
              builder: (context, state) {
                if (state is MeetingDetailsLoaded) {
                  final meeting = state.meeting;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Attendance: ${meeting.title}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        Expanded(
                          child: BlocBuilder<MembersBloc, MembersState>(
                            builder: (context, memberState) {
                              if (memberState is MembersLoaded) {
                                return ListView.builder(
                                  controller: scrollController,
                                  itemCount: memberState.members.length,
                                  itemBuilder: (context, index) {
                                    final member = memberState.members[index];
                                    final attendance = meeting.attendance
                                        ?.firstWhere(
                                          (a) => a.memberId == member.id,
                                          orElse: () => const MeetingAttendance(
                                            id: '',
                                            meetingId: '',
                                            memberId: '',
                                            status: 'PRESENT',
                                          ),
                                        );

                                    return ListTile(
                                      title: Text(member.name),
                                      trailing: DropdownButton<String>(
                                        value: attendance?.status == 'ABSENT'
                                            ? 'ABSENT'
                                            : 'PRESENT',
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'PRESENT',
                                            child: Text('Present'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'ABSENT',
                                            child: Text('Absent'),
                                          ),
                                        ],
                                        onChanged: !canManage
                                            ? null
                                            : (val) {
                                          if (val != null) {
                                            context.read<MeetingsBloc>().add(
                                              RecordAttendance(
                                                meetingId: meetingId,
                                                groupId: widget.groupId,
                                                attendance: [
                                                  {
                                                    'memberId': member.id,
                                                    'present': val == 'PRESENT',
                                                  },
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
      ),
    );
  }
}
