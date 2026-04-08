import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: const [
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: AppTheme.muted,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Personalize how Prescription Buddy supports you.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: 24),
          SectionHeader('Notifications', trailing: 'Live'),
          GlassCard(
            child: Column(
              children: [
                _ToggleRow(
                  title: 'Dose reminders',
                  subtitle: 'Timely alerts with follow-up nudges',
                  enabled: true,
                ),
                _Divider(),
                _ToggleRow(
                  title: 'Price drop alerts',
                  subtitle: 'Notify when a better offer appears',
                  enabled: true,
                ),
                _Divider(),
                _ToggleRow(
                  title: 'Caregiver backup',
                  subtitle: 'Message a trusted contact if missed',
                  enabled: false,
                ),
              ],
            ),
          ),
          SizedBox(height: 22),
          SectionHeader('Privacy', trailing: 'Protected'),
          GlassCard(
            child: Column(
              children: [
                _PanelRow(
                  title: 'Face ID for launch',
                  subtitle: 'Required after 3 minutes away',
                  trailing: Icon(Icons.face_rounded, color: AppTheme.emerald),
                ),
                SizedBox(height: 14),
                _PanelRow(
                  title: 'Health data access',
                  subtitle: 'Medication schedule shared with Apple Health',
                  trailing: _Tag(
                    label: 'Limited',
                    color: AppTheme.goldSoft,
                    textColor: Color(0xFF9A6B14),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22),
          SectionHeader('Support', trailing: 'Always on'),
          GlassCard(
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.headset_mic_rounded,
                  label: 'Chat with medication concierge',
                  iconBg: Color(0xFFD8F1EB),
                  iconColor: AppTheme.emerald,
                ),
                _Divider(),
                _ActionRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Release notes & trust center',
                  iconBg: Color(0xFFFFF1D8),
                  iconColor: Color(0xFF9A6B14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 54,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: enabled ? AppTheme.emerald : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
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

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: const Color(0x1F64748B),
    );
  }
}
