import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingDayController = TextEditingController(text: 'Sunday');
  final _weeklyContributionController = TextEditingController(text: '5000');
  final _sharePriceController = TextEditingController(text: '10000');
  final _fineDefaultAmountController = TextEditingController(text: '2000');
  final _loanInterestRateController = TextEditingController(text: '10');

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _meetingDayController.dispose();
    _weeklyContributionController.dispose();
    _sharePriceController.dispose();
    _fineDefaultAmountController.dispose();
    _loanInterestRateController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<GroupsBloc>().add(
        CreateGroupEvent(
          name: _nameController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          meetingDay: _meetingDayController.text.trim().isEmpty ? null : _meetingDayController.text.trim(),
          weeklyContribution: double.tryParse(_weeklyContributionController.text.trim()),
          sharePrice: double.tryParse(_sharePriceController.text.trim()),
          fineDefaultAmount: double.tryParse(_fineDefaultAmountController.text.trim()),
          loanInterestRate: double.tryParse(_loanInterestRateController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
      ),
      body: BlocListener<GroupsBloc, GroupsState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            context.pop();
          } else if (state is GroupsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Group Information',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  labelText: 'Group Name *',
                  hintText: 'e.g. Upendo VICOBA Group',
                  prefixIcon: Icons.group_work_outlined,
                  validator: (val) => Validators.required(val, 'Group name is required'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationController,
                  labelText: 'Location / Ward / District',
                  hintText: 'e.g. Kinondoni, Dar es Salaam',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _meetingDayController,
                  labelText: 'Meeting Day',
                  hintText: 'e.g. Sunday, Weekly at 4:00 PM',
                  prefixIcon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 24),
                Text(
                  'Financial Rules & Policies',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Set the baseline contribution amounts, share value, and interest rates.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _weeklyContributionController,
                        labelText: 'Weekly Contribution (TZS)',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _sharePriceController,
                        labelText: 'Share Price (TZS)',
                        prefixIcon: Icons.pie_chart_outline,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _fineDefaultAmountController,
                        labelText: 'Default Fine (TZS)',
                        prefixIcon: Icons.gavel_outlined,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _loanInterestRateController,
                        labelText: 'Loan Interest Rate (%)',
                        prefixIcon: Icons.percent,
                        keyboardType: TextInputType.number,
                        validator: Validators.positiveNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<GroupsBloc, GroupsState>(
                  builder: (context, state) {
                    final isLoading = state is GroupsLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _onSubmit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create VICOBA Group'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
