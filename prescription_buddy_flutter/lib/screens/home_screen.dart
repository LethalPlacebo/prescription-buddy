import 'package:flutter/material.dart';

import '../models/prescription_record.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.prescriptions,
    required this.onOpenPrescription,
    required this.onAddPrescription,
    required this.onUpdatePrescription,
    required this.onDeletePrescription,
    super.key,
  });

  final List<PrescriptionRecord> prescriptions;
  final VoidCallback onOpenPrescription;
  final Future<void> Function(PrescriptionRecord record) onAddPrescription;
  final void Function(int index, PrescriptionRecord updated)
      onUpdatePrescription;
  final void Function(int index, PrescriptionRecord record)
      onDeletePrescription;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _showAddPrescriptionDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppTheme.muted),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search or add a prescription',
                            style: TextStyle(color: AppTheme.muted),
                          ),
                        ),
                        _CircleAction(icon: Icons.add_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Search medications, organize your list, and keep every dose on schedule.',
              ),
              const SizedBox(height: 14),
              _MetricCard(
                label: 'Active meds',
                value: prescriptions.length.toString(),
                hint: 'Manage prescriptions and reminders in one place',
                hintColor: AppTheme.emerald,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Your prescriptions', trailing: 'Tap to manage'),
        GlassCard(
          child: Column(
            children: List.generate(prescriptions.length, (index) {
              final item = prescriptions[index];
              return Column(
                children: [
                  _ListItem(
                    data: item,
                    onTap: () => _showPrescriptionActions(context, index, item),
                  ),
                  if (index != prescriptions.length - 1) const _ThinDivider(),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Future<void> _showPrescriptionActions(
    BuildContext context,
    int index,
    PrescriptionRecord item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F4EC),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                  Row(
                    children: [
                      _MedicationIcon(
                        icon: item.icon,
                        background: item.iconBg,
                        foreground: item.iconColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(item.subtitle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ActionSheetButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit prescription',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showEditDialog(context, index, item);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionSheetButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete prescription',
                    foreground: const Color(0xFFB54747),
                    background: const Color(0xFFFFE8E6),
                    onTap: () {
                      Navigator.of(context).pop();
                      onDeletePrescription(index, item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.title} deleted')),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionSheetButton(
                    icon: Icons.close_rounded,
                    label: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddPrescriptionDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final priceController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F4EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Add prescription',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: titleController,
                label: 'Prescription name',
              ),
              const SizedBox(height: 12),
              _DialogField(
                controller: subtitleController,
                label: 'Details or pharmacy',
              ),
              const SizedBox(height: 12),
              _DialogField(
                controller: priceController,
                label: 'Price',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.emerald),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a prescription name to add it.'),
                    ),
                  );
                  return;
                }

                final details = subtitleController.text.trim().isEmpty
                    ? '30 tablets - Local pharmacy'
                    : subtitleController.text.trim();
                final price = priceController.text.trim().isEmpty
                    ? '\$--'
                    : priceController.text.trim();

                final record = PrescriptionRecord(
                  id: _buildRecordId(title),
                  icon: Icons.medication_rounded,
                  iconBg: const Color(0xFFE8F4EF),
                  iconColor: AppTheme.emerald,
                  title: title,
                  subtitle: details,
                  price: price.startsWith('\$') ? price : '\$$price',
                  note: 'Newly added',
                  reminderLabel: 'Morning',
                  reminderTime: const TimeOfDay(hour: 9, minute: 0),
                  repeatDays: const {
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  },
                  reminderTimeBackground: const Color(0xFFD8F1EB),
                  sortOrder: prescriptions.length,
                );

                await onAddPrescription(record);
                if (!context.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title added')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _buildRecordId(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${slug.isEmpty ? 'prescription' : slug}-$timestamp';
  }

  Future<void> _showEditDialog(
    BuildContext context,
    int index,
    PrescriptionRecord item,
  ) async {
    final titleController = TextEditingController(text: item.title);
    final subtitleController = TextEditingController(text: item.subtitle);
    final priceController = TextEditingController(text: item.price);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F4EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'Edit prescription',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(controller: titleController, label: 'Name'),
              const SizedBox(height: 12),
              _DialogField(controller: subtitleController, label: 'Details'),
              const SizedBox(height: 12),
              _DialogField(controller: priceController, label: 'Price'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.emerald),
              onPressed: () {
                onUpdatePrescription(
                  index,
                  item.copyWith(
                    title: titleController.text,
                    subtitle: subtitleController.text,
                    price: priceController.text,
                  ),
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${titleController.text} updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
    this.hintColor = AppTheme.muted,
  });

  final String label;
  final String value;
  final String hint;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.emerald,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _MedicationIcon extends StatelessWidget {
  const _MedicationIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: foreground, size: 26),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.data,
    required this.onTap,
  });

  final PrescriptionRecord data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              _MedicationIcon(
                icon: data.icon,
                background: data.iconBg,
                foreground: data.iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(data.subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.note,
                    style: TextStyle(
                      fontSize: 12,
                      color: data.noteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz_rounded, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheetButton extends StatelessWidget {
  const _ActionSheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foreground = AppTheme.ink,
    this.background = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x1F64748B));
  }
}
