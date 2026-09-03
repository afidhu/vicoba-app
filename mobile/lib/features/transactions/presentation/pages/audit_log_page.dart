import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../injection_container.dart';

/// Read-only audit trail for a group (GET /groups/:id/transactions/audit-log).
class AuditLogPage extends StatefulWidget {
  final String groupId;
  const AuditLogPage({super.key, required this.groupId});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final res = await sl<DioClient>().dio.get(ApiConstants.auditLog(widget.groupId));
    return res.data as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load audit log:\n${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No audit records yet.'));
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final log = logs[i] as Map<String, dynamic>;
              final when = DateTime.tryParse(log['createdAt']?.toString() ?? '');
              return ListTile(
                dense: true,
                title: Text('${log['action']} · ${log['entity']}'),
                subtitle: Text([
                  if (log['user']?['name'] != null) 'by ${log['user']['name']}',
                  if (when != null) DateFormat('MMM dd, yyyy HH:mm').format(when),
                ].join('  •  ')),
              );
            },
          );
        },
      ),
    );
  }
}
