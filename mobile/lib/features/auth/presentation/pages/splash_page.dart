import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shown while [AuthBloc] resolves the persisted session. Navigation away from
/// here is handled by the router's redirect once auth state settles.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.account_balance_rounded,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('VICOBA',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    color: AppColors.primary)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
