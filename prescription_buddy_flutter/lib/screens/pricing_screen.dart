import 'package:flutter/material.dart';

import '../models/medication_price_offer.dart';
import '../models/prescription_record.dart';
import '../services/pricing_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({
    required this.prescriptions,
    required this.repository,
    super.key,
  });

  final List<PrescriptionRecord> prescriptions;
  final PricingRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MedicationPriceOffer>>(
      stream: repository.watchOffersForPrescriptions(prescriptions),
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
                    icon: Icons.savings_rounded,
                    label: 'Quarterly price data',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Medication pricing',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prescriptions.isEmpty
                        ? 'Add a medication to your personal list and matching pricing options will appear here.'
                        : 'Pricing is now focused on the medications you already track, with alternate doses and pharmacies shown when available.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              prescriptions.isEmpty ? 'Your pricing' : 'Matching offers',
              trailing:
                  prescriptions.isEmpty ? 'Add meds first' : 'Source-labeled',
            ),
            GlassCard(
              child: prescriptions.isEmpty
                  ? const Text(
                      'Add medications to your personal list to see relevant prices here.',
                    )
                  : offers.isEmpty
                      ? const Text(
                          'No matching pricing offers were found for your current medications yet.',
                        )
                      : Column(
                          children: List.generate(offers.length, (index) {
                            final offer = offers[index];
                            return Column(
                              children: [
                                _OfferRow(offer: offer),
                                if (index != offers.length - 1)
                                  const _Divider(),
                              ],
                            );
                          }),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer});

  final MedicationPriceOffer offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
                    Text(
                      offer.medicationName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(offer.storeName),
                  ],
                ),
              ),
              Text(
                offer.priceLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            offer.sourceLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.emerald,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offer.lastUpdatedLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x1F64748B));
  }
}
