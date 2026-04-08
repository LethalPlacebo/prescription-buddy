import 'package:flutter/material.dart';

import '../models/prescription_record.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({
    required this.prescriptions,
    required this.onUpdatePrescription,
    super.key,
  });

  static const List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  final List<PrescriptionRecord> prescriptions;
  final void Function(int index, PrescriptionRecord updated)
      onUpdatePrescription;

  @override
  Widget build(BuildContext context) {
    if (prescriptions.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: const [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REMINDERS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                    color: AppTheme.muted,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'No reminders yet.',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 10),
                Text(
                  'Add prescriptions on the home screen to manage reminder schedules here.',
                ),
              ],
            ),
          ),
        ],
      );
    }

    final nextReminder = prescriptions.first;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'REMINDERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DarkHero(
                reminder: nextReminder,
                repeatText: repeatLabel(nextReminder.repeatDays),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeader('Today', trailing: '${prescriptions.length} active'),
        GlassCard(
          child: Column(
            children: List.generate(prescriptions.length, (index) {
              final reminder = prescriptions[index];
              return Column(
                children: [
                  _ReminderCard(
                    reminder: reminder,
                    repeatText: repeatLabel(reminder.repeatDays),
                    onTap: () =>
                        _editReminderSchedule(context, index, reminder),
                  ),
                  if (index != prescriptions.length - 1)
                    const SizedBox(height: 14),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Future<void> _editReminderSchedule(
    BuildContext context,
    int index,
    PrescriptionRecord reminder,
  ) async {
    final initialHour = _hour12(reminder.reminderTime.hour);
    int selectedHour = initialHour == 0 ? 12 : initialHour;
    int selectedMinute = reminder.reminderTime.minute;
    bool isAm = reminder.reminderTime.hour < 12;
    final selectedDays = <String>{...reminder.repeatDays};

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F4EC),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 54,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        reminder.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                          'Choose when the reminder should appear and which days it repeats.'),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeSelector(
                              label: 'Hour',
                              value: '$selectedHour',
                              onDecrement: () {
                                setModalState(() {
                                  selectedHour =
                                      selectedHour == 1 ? 12 : selectedHour - 1;
                                });
                              },
                              onIncrement: () {
                                setModalState(() {
                                  selectedHour =
                                      selectedHour == 12 ? 1 : selectedHour + 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimeSelector(
                              label: 'Minute',
                              value: selectedMinute.toString().padLeft(2, '0'),
                              onDecrement: () {
                                setModalState(() {
                                  selectedMinute = selectedMinute == 0
                                      ? 59
                                      : selectedMinute - 1;
                                });
                              },
                              onIncrement: () {
                                setModalState(() {
                                  selectedMinute = selectedMinute == 59
                                      ? 0
                                      : selectedMinute + 1;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _AmPmButton(
                                label: 'AM',
                                active: isAm,
                                onTap: () => setModalState(() => isAm = true),
                              ),
                            ),
                            Expanded(
                              child: _AmPmButton(
                                label: 'PM',
                                active: !isAm,
                                onTap: () => setModalState(() => isAm = false),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Repeats on',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: weekdays.map((day) {
                          final active = selectedDays.contains(day);
                          return _DayChip(
                            label: day,
                            active: active,
                            onTap: () {
                              setModalState(() {
                                if (active) {
                                  if (selectedDays.length > 1) {
                                    selectedDays.remove(day);
                                  }
                                } else {
                                  selectedDays.add(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Save schedule',
                        onPressed: () {
                          final hour24 = isAm
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final updated = reminder.copyWith(
                            reminderTime: TimeOfDay(
                              hour: hour24,
                              minute: selectedMinute,
                            ),
                            repeatDays: selectedDays,
                          );
                          onUpdatePrescription(index, updated);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${updated.title} set for ${formatTime(updated.reminderTime)} • ${repeatLabel(updated.repeatDays)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static int _hour12(int hour24) {
    final hour = hour24 % 12;
    return hour == 0 ? 12 : hour;
  }

  static String formatTime(TimeOfDay time) {
    final hour = _hour12(time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String repeatLabel(Set<String> days) {
    if (days.length == weekdays.length) return 'Repeats daily';
    final ordered = weekdays.where(days.contains).toList();
    return ordered.join(', ');
  }
}

class _DarkHero extends StatelessWidget {
  const _DarkHero({
    required this.reminder,
    required this.repeatText,
  });

  final PrescriptionRecord reminder;
  final String repeatText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next alert',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        RemindersScreen.formatTime(reminder.reminderTime),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _DarkPill(text: 'Tap cards to adjust'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${reminder.title} • $repeatText',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.repeatText,
    required this.onTap,
  });

  final PrescriptionRecord reminder;
  final String repeatText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.reminderLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: reminder.reminderLabelColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reminder.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: reminder.reminderTimeBackground,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      RemindersScreen.formatTime(reminder.reminderTime),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Text(repeatText)),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.emerald),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final String value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppTheme.emerald : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppTheme.emerald : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
