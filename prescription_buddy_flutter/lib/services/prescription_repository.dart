import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription_record.dart';

class PrescriptionRepository {
  PrescriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collectionForUser(String uid) {
    return _firestore.collection('users').doc(uid).collection('prescriptions');
  }

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user available.');
    }
    return uid;
  }

  Stream<List<PrescriptionRecord>> watchPrescriptions() {
    return _collectionForUser(_currentUid).orderBy('sortOrder').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PrescriptionRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updatePrescription(PrescriptionRecord record) {
    return _collectionForUser(_currentUid).doc(record.id).set(record.toMap());
  }

  Future<void> addPrescription(PrescriptionRecord record) {
    return _collectionForUser(_currentUid).doc(record.id).set(record.toMap());
  }

  Future<void> deletePrescription(String id) {
    return _collectionForUser(_currentUid).doc(id).delete();
  }
}
