import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication_price_offer.dart';
import '../models/prescription_record.dart';

class PricingRepository {
  PricingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _offersCollection =>
      _firestore.collection('pricing_offers');

  Stream<List<MedicationPriceOffer>> watchOffers() {
    return _offersCollection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationPriceOffer.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<MedicationPriceOffer>> watchOffersForQuery(
    String query, {
    int limit = 8,
  }) {
    final normalized = _normalizeQuery(query);
    if (normalized.isEmpty) {
      return Stream.value(const <MedicationPriceOffer>[]);
    }

    return _offersCollection
        .orderBy('searchName')
        .startAt([normalized])
        .endAt(['$normalized\uf8ff'])
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationPriceOffer.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<MedicationPriceOffer>> watchOffersForPrescriptions(
    List<PrescriptionRecord> prescriptions, {
    int limitPerMedication = 40,
  }) {
    final terms = prescriptions
        .map((record) => _primarySearchTerm(record.title))
        .where((term) => term.isNotEmpty)
        .toSet()
        .toList();

    if (terms.isEmpty) {
      return Stream.value(const <MedicationPriceOffer>[]);
    }

    final controller = StreamController<List<MedicationPriceOffer>>();
    final latestByTerm = <String, List<MedicationPriceOffer>>{};
    final subscriptions = <StreamSubscription<List<MedicationPriceOffer>>>[];

    void emitMerged() {
      final merged = <String, MedicationPriceOffer>{};
      for (final offers in latestByTerm.values) {
        for (final offer in offers) {
          merged[offer.id] = offer;
        }
      }

      final sorted = merged.values.toList()
        ..sort((a, b) {
          final medicationCompare =
              a.medicationName.compareTo(b.medicationName);
          if (medicationCompare != 0) {
            return medicationCompare;
          }

          final priceCompare = _numericPrice(a.priceLabel)
              .compareTo(_numericPrice(b.priceLabel));
          if (priceCompare != 0) {
            return priceCompare;
          }

          return a.storeName.compareTo(b.storeName);
        });
      controller.add(sorted);
    }

    for (final term in terms) {
      final sub = watchOffersForQuery(term, limit: limitPerMedication).listen(
        (offers) {
          latestByTerm[term] = offers;
          emitMerged();
        },
        onError: controller.addError,
      );
      subscriptions.add(sub);
    }

    controller.onCancel = () async {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }

  Future<void> seedStarterOffersIfEmpty() async {
    final existing = await _offersCollection.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final offer in MedicationPriceOffer.starterOffers()) {
      batch.set(_offersCollection.doc(offer.id), offer.toMap());
    }
    await batch.commit();
  }

  Future<void> saveOffer(MedicationPriceOffer offer) {
    return _offersCollection.doc(offer.id).set(offer.toMap());
  }

  Future<void> deleteOffer(String id) {
    return _offersCollection.doc(id).delete();
  }

  String _normalizeQuery(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  String _primarySearchTerm(String title) {
    final normalized = _normalizeQuery(title);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.split(' ').first;
  }

  double _numericPrice(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        double.infinity;
  }
}
