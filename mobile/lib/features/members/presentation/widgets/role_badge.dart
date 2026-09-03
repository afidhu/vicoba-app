import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String display;

    switch (role.toUpperCase()) {
      case 'ADMIN':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        display = 'Chairperson (Admin)';
        break;
      case 'TREASURER':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        display = 'Treasurer';
        break;
      case 'SECRETARY':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        display = 'Secretary';
        break;
      case 'OWNER':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        display = 'Owner';
        break;
      case 'MEMBER':
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        display = 'Member';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
