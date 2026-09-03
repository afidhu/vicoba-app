import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';
import '../../../members/domain/entities/member.dart';
import '../../domain/entities/fine.dart';
import '../bloc/fines_bloc.dart';
import '../bloc/fines_event.dart';
import '../bloc/fines_state.dart';

class FinesPage extends StatefulWidget {
  final String groupId;

  const FinesPage({super.key, required this.groupId});

  @override
  State<FinesPage> createState() => _FinesPageState();
}

class _FinesPageState extends State<FinesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FinesBloc>().add(LoadFines(widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ActiveGroupCubit>().state.role;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Fines')),
      body: BlocConsumer<FinesBloc, FinesState>(
        listener: (context, state) {
          if (state is FineActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FinesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FinesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FinesLoaded) {
            if (state.fines.isEmpty) {
              return const Center(child: Text('No fines recorded.'));
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Unpaid fines: TSH ${state.unpaidTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.fines.length,
                    itemBuilder: (context, index) {
                      final fine = state.fines[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(fine.status),
                          child: const Icon(Icons.gavel, color: Colors.white),
                        ),
                        title: Text(fine.memberName ?? 'Member'),
                        subtitle: Text(
                          '${fine.reason}\n${DateFormat('yyyy-MM-dd').format(fine.issuedAt)}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('TSH ${fine.amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(fine.status.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 11, color: _statusColor(fine.status))),
                          ],
                        ),
                        onTap: (fine.status == FineStatus.unpaid &&
                                Permissions.canUpdateFineStatus(role))
                            ? () => _showStatusSheet(context, fine)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Loading fines...'));
        },
      ),
      floatingActionButton: Permissions.canCreateFine(role)
          ? FloatingActionButton(
              onPressed: () => _showRecordFineDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Color _statusColor(FineStatus s) {
    switch (s) {
      case FineStatus.paid:
        return Colors.green;
      case FineStatus.waived:
        return Colors.blueGrey;
      case FineStatus.unpaid:
        return Colors.orange;
    }
  }

  void _showStatusSheet(BuildContext context, Fine fine) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as paid'),
              onTap: () {
                context.read<FinesBloc>().add(UpdateFineStatus(
                      groupId: widget.groupId,
                      fineId: fine.id,
                      status: FineStatus.paid,
                    ));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.blueGrey),
              title: const Text('Waive fine'),
              onTap: () {
                context.read<FinesBloc>().add(UpdateFineStatus(
                      groupId: widget.groupId,
                      fineId: fine.id,
                      status: FineStatus.waived,
                    ));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordFineDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final amountController = TextEditingController();
    Member? selectedMember;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record Fine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<MembersBloc, MembersState>(
              builder: (context, state) {
                if (state is MembersLoaded) {
                  return DropdownButtonFormField<Member>(
                    decoration: const InputDecoration(labelText: 'Member'),
                    items: state.members
                        .where((m) => m.isActive)
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m.name)))
                        .toList(),
                    onChanged: (m) => selectedMember = m,
                  );
                }
                return const Text('Loading members...');
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (optional — group default used if empty)',
              ),
              keyboardType: TextInputType.number,
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
              if (selectedMember != null && reasonController.text.trim().isNotEmpty) {
                this.context.read<FinesBloc>().add(RecordFine(
                      groupId: widget.groupId,
                      memberId: selectedMember!.id,
                      reason: reasonController.text.trim(),
                      amount: double.tryParse(amountController.text.trim()),
                    ));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
