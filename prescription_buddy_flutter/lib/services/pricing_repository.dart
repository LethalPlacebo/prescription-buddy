import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication_price_offer.dart';

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
}
