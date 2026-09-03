import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../injection_container.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _tokenRequested = false;

  AuthRepository get _repo => sl<AuthRepository>();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  Future<void> _requestToken() async {
    if (Validators.email(_emailController.text) != null) {
      _snack('Enter a valid email', error: true);
      return;
    }
    setState(() => _loading = true);
    final result = await _repo.forgotPassword(_emailController.text.trim());
    setState(() => _loading = false);
    result.fold(
      (f) => _snack(f.message, error: true),
      (token) {
        setState(() {
          _tokenRequested = true;
          if (token != null) _tokenController.text = token;
        });
        _snack(token != null
            ? 'Reset token generated (dev mode). Set a new password below.'
            : 'If that email exists, a reset token was sent.');
      },
    );
  }

  Future<void> _reset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final result = await _repo.resetPassword(
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );
    setState(() => _loading = false);
    result.fold(
      (f) => _snack(f.message, error: true),
      (_) {
        _snack('Password reset. Please sign in.');
        if (mounted) context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _requestToken,
                  child: const Text('Send reset token'),
                ),
                if (_tokenRequested) ...[
                  const Divider(height: 32),
                  AppTextField(
                    controller: _tokenController,
                    labelText: 'Reset Token',
                    prefixIcon: Icons.vpn_key_outlined,
                    validator: (v) => Validators.required(v, 'Enter the reset token'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _passwordController,
                    labelText: 'New Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (v) => Validators.password(v, 6),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _reset,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Set new password'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
