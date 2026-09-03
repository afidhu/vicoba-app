import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';

class TransactionsPage extends StatefulWidget {
  final String groupId;

  const TransactionsPage({super.key, required this.groupId});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionsBloc>().add(LoadTransactions(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            return ListView.separated(
              itemCount: state.transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = state.transactions[index];
                final isNegative = tx.type == 'LOAN_DISBURSEMENT' || tx.type == 'EXPENSE';
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isNegative ? Colors.red.shade50 : Colors.green.shade50,
                    child: Icon(
                      isNegative ? Icons.arrow_outward : Icons.arrow_downward,
                      color: isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(tx.type.replaceAll('_', ' ')),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tx.memberName != null) Text('Member: ${tx.memberName}'),
                      Text(DateFormat('MMM dd, yyyy HH:mm').format(tx.transactionDate)),
                    ],
                  ),
                  trailing: Text(
                    '${isNegative ? "-" : "+"} TSH ${tx.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No transactions found.'));
        },
      ),
    );
  }
}
