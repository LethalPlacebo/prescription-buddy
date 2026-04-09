import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onOpenSettings,
    required this.onOpenAdmin,
    required this.onSignOut,
    required this.showAdminConsole,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAdmin;
  final VoidCallback onSignOut;
  final bool showAdminConsole;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'Prescription Buddy Member';
    final email = (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!.trim()
        : 'No email available';

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onSignOut,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.emerald,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Account actions', trailing: 'Secure'),
        GlassCard(
          child: Column(
            children: [
              GestureDetector(
                onTap: onOpenSettings,
                child: const _MenuAction(
                  icon: Icons.settings_rounded,
                  label: 'Notification preferences',
                  iconBg: Color(0xFFD8F1EB),
                  iconColor: AppTheme.emerald,
                ),
              ),
              if (showAdminConsole) ...[
                const _Separator(),
                GestureDetector(
                  onTap: onOpenAdmin,
                  child: const _MenuAction(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Open admin pricing console',
                    iconBg: Color(0xFFF6D8D6),
                    iconColor: Color(0xFFB54747),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.muted,
          size: 18,
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: const Color(0x1F64748B),
    );
  }
}
