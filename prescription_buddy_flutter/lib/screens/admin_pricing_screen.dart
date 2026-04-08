import 'package:flutter/material.dart';

import '../models/medication_price_offer.dart';
import '../services/pricing_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class AdminPricingScreen extends StatefulWidget {
  const AdminPricingScreen({super.key});

  @override
  State<AdminPricingScreen> createState() => _AdminPricingScreenState();
}

class _AdminPricingScreenState extends State<AdminPricingScreen> {
  final PricingRepository _repository = PricingRepository();
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    _seedFuture = _repository.seedStarterOffersIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      child: FutureBuilder<void>(
        future: _seedFuture,
        builder: (context, seedSnapshot) {
          return StreamBuilder<List<MedicationPriceOffer>>(
            stream: _repository.watchOffers(),
            initialData: const <MedicationPriceOffer>[],
            builder: (context, snapshot) {
              final offers = snapshot.data ?? const <MedicationPriceOffer>[];

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TopPill(
                          icon: Icons.lock_rounded,
                          label: 'Admin console',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'Manage source-based medication pricing and keep last updated labels current.',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF111827),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => _openOfferEditor(context),
                              child: const Text('Add offer'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _Metric(
                                label: 'Offers',
                                value: offers.length.toString(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Metric(
                                label: 'Rx',
                                value: offers
                                    .where((offer) => !offer.isOtc)
                                    .length
                                    .toString(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Metric(
                                label: 'OTC',
                                value: offers
                                    .where((offer) => offer.isOtc)
                                    .length
                                    .toString(),
                                background: AppTheme.goldSoft,
                                labelColor: const Color(0xFF9A6B14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(
                    'Editable pricing rows',
                    trailing: 'Live Firestore',
                  ),
                  GlassCard(
                    child: offers.isEmpty
                        ? const Text('No pricing offers available yet.')
                        : Column(
                            children: List.generate(offers.length, (index) {
                              final offer = offers[index];
                              return Column(
                                children: [
                                  _EditorCard(
                                    offer: offer,
                                    onEdit: () =>
                                        _openOfferEditor(context, offer: offer),
                                    onDelete: () =>
                                        _deleteOffer(context, offer),
                                  ),
                                  if (index != offers.length - 1)
                                    const SizedBox(height: 14),
                                ],
                              );
                            }),
                          ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(
                    'Schema notes',
                    trailing: 'Future-ready',
                  ),
                  const GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin-managed today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Each pricing offer stores medication name, store name, price label, source label, and last updated label. CMS plan import fields are already reserved for later.',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openOfferEditor(
    BuildContext context, {
    MedicationPriceOffer? offer,
  }) async {
    final medicationController = TextEditingController(
      text: offer?.medicationName ?? '',
    );
    final genericController = TextEditingController(
      text: offer?.genericName ?? '',
    );
    final storeController = TextEditingController(text: offer?.storeName ?? '');
    final priceController =
        TextEditingController(text: offer?.priceLabel ?? '');
    final sourceController = TextEditingController(
      text: offer?.sourceLabel ?? 'Source: Admin-managed quarterly price',
    );
    final updatedController = TextEditingController(
      text: offer?.lastUpdatedLabel ?? 'Last updated Apr 8, 2026',
    );
    var isOtc = offer?.isOtc ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF9F4EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                offer == null ? 'Add pricing offer' : 'Edit pricing offer',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogField(
                      controller: medicationController,
                      label: 'Medication name',
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: genericController,
                      label: 'Generic name',
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: storeController,
                      label: 'Store name',
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: priceController,
                      label: 'Price label',
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: sourceController,
                      label: 'Source label',
                    ),
                    const SizedBox(height: 12),
                    _DialogField(
                      controller: updatedController,
                      label: 'Last updated label',
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isOtc,
                      onChanged: (value) {
                        setModalState(() => isOtc = value);
                      },
                      title: const Text('Over-the-counter medication'),
                      activeThumbColor: AppTheme.emerald,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                  ),
                  onPressed: () async {
                    final medicationName = medicationController.text.trim();
                    final storeName = storeController.text.trim();
                    if (medicationName.isEmpty || storeName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Medication name and store name are required.'),
                        ),
                      );
                      return;
                    }

                    final nextOffer = (offer ??
                            MedicationPriceOffer(
                              id: _buildOfferId(medicationName, storeName),
                              medicationName: medicationName,
                              storeName: storeName,
                              priceLabel: '',
                              sourceLabel: '',
                              lastUpdatedLabel: '',
                            ))
                        .copyWith(
                      medicationName: medicationName,
                      genericName: _nullIfEmpty(genericController.text),
                      storeName: storeName,
                      priceLabel: _normalizedPrice(priceController.text.trim()),
                      sourceLabel: sourceController.text.trim(),
                      lastUpdatedLabel: updatedController.text.trim(),
                      isOtc: isOtc,
                    );

                    await _repository.saveOffer(nextOffer);
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${nextOffer.medicationName} saved'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteOffer(
    BuildContext context,
    MedicationPriceOffer offer,
  ) async {
    await _repository.deleteOffer(offer.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${offer.medicationName} deleted')));
  }

  String _buildOfferId(String medicationName, String storeName) {
    final base = '${medicationName.trim()}-${storeName.trim()}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return base.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : base;
  }

  String? _nullIfEmpty(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  String _normalizedPrice(String value) {
    if (value.isEmpty) {
      return '\$--';
    }
    return value.startsWith('\$') ? value : '\$$value';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.background = Colors.white,
    this.labelColor = AppTheme.muted,
  });

  final String label;
  final String value;
  final Color background;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.offer,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationPriceOffer offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.medicationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(offer.storeName),
                    if ((offer.genericName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        offer.genericName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      offer.isOtc ? AppTheme.goldSoft : const Color(0xFFD8F1EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  offer.isOtc ? 'OTC' : 'RX',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: offer.isOtc
                        ? const Color(0xFF9A6B14)
                        : AppTheme.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _EditorMetric(label: 'Price', value: offer.priceLabel),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EditorMetric(
                  label: 'Updated',
                  value:
                      offer.lastUpdatedLabel.replaceFirst('Last updated ', ''),
                  background: const Color(0xFFFFF1D8),
                  labelColor: const Color(0xFF9A6B14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              offer.sourceLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.emerald,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    side: BorderSide(
                      color: AppTheme.muted.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onDelete,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB54747),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditorMetric extends StatelessWidget {
  const _EditorMetric({
    required this.label,
    required this.value,
    this.background = const Color(0xFFF8FAFC),
    this.labelColor = AppTheme.muted,
  });

  final String label;
  final String value;
  final Color background;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
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
