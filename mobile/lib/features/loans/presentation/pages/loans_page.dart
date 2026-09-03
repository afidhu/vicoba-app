import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../bloc/loans_bloc.dart';
import '../bloc/loans_event.dart';
import '../bloc/loans_state.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';
import '../../../members/domain/entities/member.dart';

class LoansPage extends StatefulWidget {
  final String groupId;

  const LoansPage({super.key, required this.groupId});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  @override
  void initState() {
    super.initState();
    context.read<LoansBloc>().add(LoadLoans(widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Loans')),
      body: BlocConsumer<LoansBloc, LoansState>(
        listener: (context, state) {
          if (state is LoanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loan action successful')),
            );
          }
        },
        builder: (context, state) {
          if (state is LoansLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoansLoaded) {
            return ListView.builder(
              itemCount: state.loans.length,
              itemBuilder: (context, index) {
                final loan = state.loans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    title: Text(loan.memberName),
                    subtitle: Text(
                      'Principal: TSH ${loan.principalAmount.toStringAsFixed(0)}',
                    ),
                    trailing: _buildStatusChip(loan.status),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Interest Rate: ${loan.interestRate}%'),
                            Text(
                              'Total Repayable: TSH ${loan.totalRepayable.toStringAsFixed(0)}',
                            ),
                            Text(
                              'Outstanding: TSH ${loan.outstandingAmount.toStringAsFixed(0)}',
                            ),
                            Text(
                              'Due Date: ${loan.dueDate != null ? DateFormat('yyyy-MM-dd').format(loan.dueDate!) : '—'}',
                            ),
                            const SizedBox(height: 16),
                            if (loan.status == 'PENDING' &&
                                Permissions.canManageLoans(
                                    context.watch<ActiveGroupCubit>().state.role))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        context.read<LoansBloc>().add(
                                          RejectLoan(loan.id, widget.groupId),
                                        ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        context.read<LoansBloc>().add(
                                          ApproveLoan(loan.id, widget.groupId),
                                        ),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No loans found.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRequestLoanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'ACTIVE':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _showRequestLoanDialog(BuildContext context) {
    final amountController = TextEditingController();
    Member? selectedMember;
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<MembersBloc, MembersState>(
              builder: (context, state) {
                if (state is MembersLoaded) {
                  return DropdownButtonFormField<Member>(
                    decoration: const InputDecoration(labelText: 'Member'),
                    items: state.members
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text(m.name)),
                        )
                        .toList(),
                    onChanged: (m) => selectedMember = m,
                  );
                }
                return const Text('Loading members...');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount (TSH)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDueDate)}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDueDate = picked;
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
              if (selectedMember != null && amountController.text.isNotEmpty) {
                this.context.read<LoansBloc>().add(
                  RequestLoan(
                    groupId: widget.groupId,
                    memberId: selectedMember!.id,
                    principalAmount: double.parse(amountController.text),
                    dueDate: selectedDueDate,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
