import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/permissions.dart';
import '../../../groups/presentation/cubit/active_group_cubit.dart';
import '../bloc/shares_bloc.dart';
import '../bloc/shares_event.dart';
import '../bloc/shares_state.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_event.dart';
import '../../../members/presentation/bloc/members_state.dart';
import '../../../members/domain/entities/member.dart';

class SharesPage extends StatefulWidget {
  final String groupId;

  const SharesPage({super.key, required this.groupId});

  @override
  State<SharesPage> createState() => _SharesPageState();
}

class _SharesPageState extends State<SharesPage> {
  @override
  void initState() {
    super.initState();
    context.read<SharesBloc>().add(LoadShares(widget.groupId));
    context.read<MembersBloc>().add(LoadMembersEvent(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ActiveGroupCubit>().state.role;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Shares')),
      body: BlocConsumer<SharesBloc, SharesState>(
        listener: (context, state) {
          if (state is SharesBought) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shares purchased successfully')),
            );
          } else if (state is SharesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SharesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SharesLoaded) {
            final s = state.summary;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share price: TSH ${s.sharePrice.toStringAsFixed(0)}'),
                        const SizedBox(height: 4),
                        Text('Total shares: ${s.totalShares}'),
                        const SizedBox(height: 4),
                        Text(
                          'Group share capital: TSH ${s.totalShareCapital.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...s.breakdown.map(
                  (b) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.pie_chart, color: Colors.white),
                    ),
                    title: Text(b.name),
                    subtitle: Text('${b.shareHoldings} shares'),
                    trailing: Text(
                      'TSH ${b.shareValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No share data yet.'));
        },
      ),
      floatingActionButton: Permissions.canPurchaseShares(role)
          ? FloatingActionButton(
              onPressed: () => _showBuySharesDialog(context),
              child: const Icon(Icons.add_shopping_cart),
            )
          : null,
    );
  }

  void _showBuySharesDialog(BuildContext context) {
    final quantityController = TextEditingController();
    Member? selectedMember;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buy Shares'),
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
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
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
              final qty = int.tryParse(quantityController.text);
              if (selectedMember != null && qty != null && qty > 0) {
                this.context.read<SharesBloc>().add(
                  BuyShares(
                    groupId: widget.groupId,
                    memberId: selectedMember!.id,
                    quantity: qty,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}
