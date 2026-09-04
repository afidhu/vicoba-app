import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/members_bloc.dart';
import '../bloc/members_event.dart';

class AddMemberDialog extends StatefulWidget {
  final String groupId;

  const AddMemberDialog({super.key, required this.groupId});

  static Future<void> show(BuildContext context, String groupId) {
    return showDialog(
      context: context,
      builder: (context) => AddMemberDialog(groupId: groupId),
    );
  }

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = AppConstants.roleMember;
  bool _createLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MembersBloc>().add(
        AddMemberEvent(
          groupId: widget.groupId,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          role: _selectedRole,
          email: _createLogin ? _emailController.text.trim() : null,
          password: _createLogin ? _passwordController.text : null,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Register Member', style: AppTextStyles.headingSmall),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Register a member with their phone number and role.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: 'Member Full Name *',
                hintText: 'e.g. Maria Joseph',
                prefixIcon: Icons.person_outline,
                validator: (val) => Validators.required(val, 'Name is required'),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneController,
                labelText: 'Phone Number (Unique)',
                hintText: '+255 712 345 678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 14),
              AppDropdown<String>(
                value: _selectedRole,
                labelText: 'Group Role',
                prefixIcon: Icons.badge_outlined,
                items: const [
                  DropdownMenuItem(value: AppConstants.roleMember, child: Text('Member')),
                  DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Chairperson / Admin')),
                  DropdownMenuItem(value: AppConstants.roleTreasurer, child: Text('Treasurer')),
                  DropdownMenuItem(value: AppConstants.roleSecretary, child: Text('Secretary')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRole = val);
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Create a login for this member', style: AppTextStyles.bodyMedium),
                subtitle: const Text(
                  'Lets them sign in to the app with an email and password.',
                  style: AppTextStyles.caption,
                ),
                value: _createLogin,
                onChanged: (val) => setState(() => _createLogin = val),
              ),
              if (_createLogin) ...[
                const SizedBox(height: 8),
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address *',
                  hintText: 'member@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => _createLogin ? Validators.email(val) : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password *',
                  hintText: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: (val) => _createLogin ? Validators.password(val, 6) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ],
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
          child: const Text('Register Member'),
        ),
      ],
    );
  }
}
