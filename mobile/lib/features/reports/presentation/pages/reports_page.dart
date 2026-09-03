import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ReportsPage extends StatefulWidget {
  final String groupId;

  const ReportsPage({super.key, required this.groupId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadGroupFinancialSummary(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GroupFinancialSummaryLoaded) {
            final summary = state.summary;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Group Summary', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  _buildReportCard('Total Contributions', summary.totalContributions, Colors.teal),
                  _buildReportCard('Total Shares', summary.totalShares, Colors.indigo),
                  _buildReportCard('Total Fines', summary.totalFines, Colors.amber),
                  _buildReportCard('Loan Repayments', summary.totalRepayments, Colors.green),
                  _buildReportCard('Loan Disbursements', summary.totalDisbursements, Colors.orange),
                  _buildReportCard('Group Expenses', summary.totalExpenses, Colors.red),
                  const Divider(height: 32),
                  _buildReportCard(
                    'Available Balance',
                    summary.availableBalance,
                    Colors.blue,
                    isMain: true,
                  ),
                ],
              ),
            );
          } else if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Loading report...'));
        },
      ),
    );
  }

  Widget _buildReportCard(String title, double amount, Color color, {bool isMain = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.analytics, color: color),
        title: Text(title),
        trailing: Text(
          'TSH ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isMain ? 18 : 16,
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            color: isMain ? color : null,
          ),
        ),
      ),
    );
  }
}
