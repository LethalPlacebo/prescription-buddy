import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/user_settings_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.settingsRepository,
    super.key,
  });

  final UserSettingsRepository settingsRepository;

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      child: StreamBuilder<UserSettings>(
        stream: settingsRepository.watchSettings(),
        initialData: const UserSettings(),
        builder: (context, snapshot) {
          final settings = snapshot.data ?? const UserSettings();

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Personalize how Prescription Buddy supports you.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader('Notifications', trailing: 'Live'),
              GlassCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      title: 'Dose reminders',
                      subtitle: 'Timely alerts with follow-up nudges',
                      value: settings.doseRemindersEnabled,
                      onChanged: (value) async {
                        await settingsRepository.setDoseRemindersEnabled(value);
                      },
                    ),
                    const _Divider(),
                    _ToggleRow(
                      title: 'Price drop alerts',
                      subtitle: 'Notify when a better offer appears',
                      value: settings.priceDropAlertsEnabled,
                      onChanged: (value) async {
                        await settingsRepository.setPriceDropAlertsEnabled(
                          value,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

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
        Switch.adaptive(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppTheme.emerald,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFD1D5DB),
          onChanged: onChanged,
        ),
      ],
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
