import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/bloc/members_bloc.dart';
import '../../../members/presentation/bloc/members_state.dart';
import '../bloc/contributions_bloc.dart';
import '../bloc/contributions_event.dart';

class RecordContributionDialog extends StatefulWidget {
  final String groupId;

  const RecordContributionDialog({super.key, required this.groupId});

  static Future<void> show(BuildContext context, String groupId) {
    return showDialog(
      context: context,
      builder: (context) => RecordContributionDialog(groupId: groupId),
    );
  }

  @override
  State<RecordContributionDialog> createState() => _RecordContributionDialogState();
}

class _RecordContributionDialogState extends State<RecordContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedMemberId;
  DateTime _weekEnding = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMemberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a member')),
        );
        return;
      }

      context.read<ContributionsBloc>().add(
        RecordContributionEvent(
          groupId: widget.groupId,
          memberId: _selectedMemberId!,
          amount: _amountController.text.trim().isNotEmpty
              ? double.tryParse(_amountController.text.trim())
              : null,
          weekEnding: _weekEnding,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Record Contribution', style: AppTextStyles.headingSmall),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Record weekly savings for a group member.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              BlocBuilder<MembersBloc, MembersState>(
                builder: (context, state) {
                  List<Member> members = [];
                  if (state is MembersLoaded) {
                    members = state.members.where((m) => m.isActive).toList();
                  }

                  return AppDropdown<String>(
                    value: _selectedMemberId,
                    labelText: 'Select Member *',
                    prefixIcon: Icons.person_outline,
                    items: members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMemberId = val);
                    },
                    validator: (val) => val == null ? 'Select a member' : null,
                  );
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _amountController,
                labelText: 'Amount (Optional - leave empty for group default)',
                hintText: 'e.g. 5000',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    return Validators.positiveNumber(val);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, size: 20),
                title: const Text('Week Ending Date', style: AppTextStyles.bodySmall),
                subtitle: Text(
                  DateFormatter.format(_weekEnding),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _weekEnding,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _weekEnding = picked);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Record Savings'),
        ),
      ],
    );
  }
}
