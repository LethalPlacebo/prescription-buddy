import 'package:flutter/material.dart';

import '../models/medication_price_offer.dart';
import '../models/prescription_record.dart';
import '../services/pricing_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.prescriptions,
    required this.repository,
    required this.onOpenPrescription,
    required this.onAddPrescription,
    required this.onUpdatePrescription,
    required this.onDeletePrescription,
    super.key,
  });

  final List<PrescriptionRecord> prescriptions;
  final PricingRepository repository;
  final VoidCallback onOpenPrescription;
  final Future<void> Function(PrescriptionRecord record) onAddPrescription;
  final void Function(int index, PrescriptionRecord updated)
      onUpdatePrescription;
  final void Function(int index, PrescriptionRecord record)
      onDeletePrescription;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppTheme.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.trim()),
                        decoration: const InputDecoration(
                          hintText: 'Search prescriptions by name',
                          hintStyle: TextStyle(color: AppTheme.muted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.muted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Search medications by name and add them directly from the pricing database.',
              ),
              const SizedBox(height: 14),
              _MetricCard(
                label: 'Active meds',
                value: widget.prescriptions.length.toString(),
                hint: 'Track prescriptions and reminders in one place',
                hintColor: AppTheme.emerald,
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Matching medications',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.muted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<MedicationPriceOffer>>(
                  stream: widget.repository.watchOffersForQuery(_searchQuery),
                  initialData: const <MedicationPriceOffer>[],
                  builder: (context, snapshot) {
                    final suggestions = _buildSuggestions(
                      snapshot.data ?? const <MedicationPriceOffer>[],
                    );
                    if (suggestions.isEmpty) {
                      return const _EmptySearchState();
                    }

                    return Column(
                      children: List.generate(suggestions.length, (index) {
                        final suggestion = suggestions[index];
                        return Column(
                          children: [
                            _SearchResultRow(
                              suggestion: suggestion,
                              onTap: () => _addSuggestedMedication(suggestion),
                            ),
                            if (index != suggestions.length - 1)
                              const _ThinDivider(),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Your prescriptions', trailing: 'Tap to manage'),
        GlassCard(
          child: widget.prescriptions.isEmpty
              ? const _EmptyTrackedState()
              : Column(
                  children: List.generate(widget.prescriptions.length, (index) {
                    final item = widget.prescriptions[index];
                    return Column(
                      children: [
                        _ListItem(
                          data: item,
                          onTap: () =>
                              _showPrescriptionActions(context, index, item),
                        ),
                        if (index != widget.prescriptions.length - 1)
                          const _ThinDivider(),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }

  List<_MedicationSuggestion> _buildSuggestions(
    List<MedicationPriceOffer> offers,
  ) {
    final seen = <String>{};
    final suggestions = <_MedicationSuggestion>[];

    for (final offer in offers) {
      final normalizedName = _normalize(offer.medicationName);
      if (seen.contains(normalizedName)) {
        continue;
      }

      seen.add(normalizedName);
      suggestions.add(
        _MedicationSuggestion(
          medicationName: offer.medicationName,
          storeName: offer.storeName,
          priceLabel: offer.priceLabel,
        ),
      );

      if (suggestions.length == 8) {
        break;
      }
    }

    return suggestions;
  }

  Future<void> _addSuggestedMedication(_MedicationSuggestion suggestion) async {
    final alreadyTracked = widget.prescriptions.any(
      (record) =>
          _normalize(record.title) == _normalize(suggestion.medicationName),
    );

    if (alreadyTracked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${suggestion.medicationName} is already in your list.'),
        ),
      );
      return;
    }

    final record = PrescriptionRecord(
      id: _buildRecordId(suggestion.medicationName),
      icon: Icons.medication_rounded,
      iconBg: const Color(0xFFE8F4EF),
      iconColor: AppTheme.emerald,
      title: suggestion.medicationName,
      subtitle: 'Tracked from ${suggestion.storeName}',
      price: suggestion.priceLabel,
      note: suggestion.storeName,
      noteColor: AppTheme.emerald,
      reminderLabel: 'Morning',
      reminderTime: const TimeOfDay(hour: 9, minute: 0),
      repeatDays: const {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'},
      reminderTimeBackground: const Color(0xFFD8F1EB),
      sortOrder: widget.prescriptions.length,
    );

    await widget.onAddPrescription(record);
    if (!mounted) {
      return;
    }

    _searchController.clear();
    setState(() => _searchQuery = '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${suggestion.medicationName} added')),
    );
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
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
                      widget.onDeletePrescription(index, item);
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
                widget.onUpdatePrescription(
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

class _MedicationSuggestion {
  const _MedicationSuggestion({
    required this.medicationName,
    required this.storeName,
    required this.priceLabel,
  });

  final String medicationName;
  final String storeName;
  final String priceLabel;
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

class _EmptyTrackedState extends StatelessWidget {
  const _EmptyTrackedState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.manage_search_rounded,
            color: AppTheme.emerald,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search for prescriptions to keep track of them here.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Try a broader medication name to see matching options from the database.',
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.suggestion,
    required this.onTap,
  });

  final _MedicationSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppTheme.emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.medicationName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${suggestion.storeName} • ${suggestion.priceLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.emerald,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
