import 'package:flutter/material.dart';

import '../models/medication_price_offer.dart';
import '../services/pricing_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final PricingRepository _repository = PricingRepository();
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    _seedFuture = _repository.seedStarterOffersIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
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
                        icon: Icons.savings_rounded,
                        label: 'Quarterly price data',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Medication pricing',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Prices are source-based and last updated labels are shown on every offer. This schema is admin-managed today and ready for future CMS import fields.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionHeader('Available offers',
                    trailing: 'Source-labeled'),
                GlassCard(
                  child: offers.isEmpty
                      ? const Text(
                          'No pricing offers available yet.',
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
