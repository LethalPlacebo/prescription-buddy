import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_settings.dart';

class UserSettingsRepository {
  UserSettingsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user available.');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Stream<UserSettings> watchSettings() {
    return _userDoc(_currentUid).snapshots().map(
          (snapshot) => UserSettings.fromMap(snapshot.data()),
        );
  }

  Future<void> setDoseRemindersEnabled(bool value) {
    return _userDoc(_currentUid).set(
      {'doseRemindersEnabled': value},
      SetOptions(merge: true),
    );
  }

  Future<void> setPriceDropAlertsEnabled(bool value) {
    return _userDoc(_currentUid).set(
      {'priceDropAlertsEnabled': value},
      SetOptions(merge: true),
    );
  }
}
