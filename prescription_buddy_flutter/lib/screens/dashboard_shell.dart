import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/medication_price_offer.dart';
import '../models/prescription_record.dart';
import '../models/user_settings.dart';
import '../services/notification_service.dart';
import '../services/pricing_repository.dart';
import '../services/user_settings_repository.dart';
import '../theme/app_theme.dart';
import '../services/prescription_repository.dart';
import '../widgets/ui_components.dart';
import 'admin_pricing_screen.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'prescription_detail_screen.dart';
import 'pricing_screen.dart';
import 'profile_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final PrescriptionRepository _repository = PrescriptionRepository();
  final PricingRepository _pricingRepository = PricingRepository();
  final UserSettingsRepository _settingsRepository = UserSettingsRepository();

  int _currentIndex = 0;
  late final Stream<List<PrescriptionRecord>> _prescriptionsStream;
  late final Stream<List<MedicationPriceOffer>> _pricingOffersStream;
  late final Stream<UserSettings> _settingsStream;
  StreamSubscription<List<PrescriptionRecord>>? _reminderSyncSubscription;
  StreamSubscription<UserSettings>? _settingsSubscription;
  StreamSubscription<User?>? _authTokenSubscription;
  List<PrescriptionRecord> _latestPrescriptions = const [];
  bool _doseRemindersEnabled = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _prescriptionsStream = _repository.watchPrescriptions();
    _pricingOffersStream = _pricingRepository.watchOffers();
    _settingsStream = _settingsRepository.watchSettings();
    unawaited(_seedPricingOffers());
    _reminderSyncSubscription = _prescriptionsStream.listen((prescriptions) {
      _latestPrescriptions = prescriptions;
      unawaited(_syncNotifications());
    });
    _settingsSubscription = _settingsStream.listen((settings) {
      _doseRemindersEnabled = settings.doseRemindersEnabled;
      unawaited(_syncNotifications());
    });
    _authTokenSubscription = FirebaseAuth.instance.idTokenChanges().listen((_) {
      unawaited(_refreshAdminState());
    });
    unawaited(_refreshAdminState(forceRefresh: true));
  }

  @override
  void dispose() {
    _reminderSyncSubscription?.cancel();
    _settingsSubscription?.cancel();
    _authTokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const ScreenTemplate(
        child: Center(
          child: GlassCard(
            child: Text(
              'Please sign in again to load your prescriptions.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ScreenTemplate(
      bottomBar: AppBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      child: StreamBuilder<List<MedicationPriceOffer>>(
        stream: _pricingOffersStream,
        initialData: const <MedicationPriceOffer>[],
        builder: (context, snapshot) {
          final pricingOffers = snapshot.data ?? const <MedicationPriceOffer>[];

          return StreamBuilder<List<PrescriptionRecord>>(
            stream: _prescriptionsStream,
            initialData: const <PrescriptionRecord>[],
            builder: (context, prescriptionSnapshot) {
              if (prescriptionSnapshot.hasError) {
                return const _DashboardMessage(
                  message:
                      'We could not sync prescriptions right now. Please verify your Firestore database is created and available.',
                );
              }

              final prescriptions =
                  prescriptionSnapshot.data ?? const <PrescriptionRecord>[];
              final pricedPrescriptions = prescriptions
                  .map((item) => _applyPricing(item, pricingOffers))
                  .toList();

              final screens = <Widget>[
                HomeScreen(
                  prescriptions: pricedPrescriptions,
                  availableOffers: pricingOffers,
                  onOpenPrescription: _openPrescription,
                  onAddPrescription: _addPrescription,
                  onUpdatePrescription: _updatePrescription,
                  onDeletePrescription: _deletePrescription,
                ),
                RemindersScreen(
                  prescriptions: pricedPrescriptions,
                  onUpdatePrescription: _updatePrescription,
                ),
                const PricingScreen(),
                ProfileScreen(
                  onOpenSettings: _openSettings,
                  onOpenAdmin: _openAdmin,
                  onSignOut: _signOut,
                  showAdminConsole: _isAdmin,
                ),
              ];

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: screens[_currentIndex],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _seedPricingOffers() async {
    try {
      await _pricingRepository
          .seedStarterOffersIfEmpty()
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pricing data could not be seeded right now.'),
        ),
      );
    }
  }

  Future<void> _syncNotifications() {
    return NotificationService.instance.syncPrescriptionReminders(
      _latestPrescriptions,
      enabled: _doseRemindersEnabled,
    );
  }

  Future<void> _refreshAdminState({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdTokenResult(forceRefresh);
    final isAdmin = token?.claims?['admin'] == true;
    if (!mounted) {
      return;
    }
    setState(() => _isAdmin = isAdmin);
  }

  PrescriptionRecord _applyPricing(
    PrescriptionRecord record,
    List<MedicationPriceOffer> offers,
  ) {
    final matches = offers.where((offer) {
      final medication = _normalize(record.title);
      final offerName = _normalize(offer.medicationName);
      return offerName.contains(medication) || medication.contains(offerName);
    }).toList();

    if (matches.isEmpty) {
      return record;
    }

    final bestMatch = matches.first;
    return record.copyWith(
      price: bestMatch.priceLabel,
      note: bestMatch.storeName,
      noteColor: AppTheme.emerald,
    );
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  void _openPrescription() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrescriptionDetailScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(settingsRepository: _settingsRepository),
      ),
    );
  }

  void _openAdmin() {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This account does not have admin access.'),
        ),
      );
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AdminPricingScreen()));
  }

  Future<void> _updatePrescription(
      int index, PrescriptionRecord updated) async {
    try {
      await _repository.updatePrescription(updated);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes right now.')),
      );
    }
  }

  Future<void> _addPrescription(PrescriptionRecord record) async {
    try {
      await _repository.addPrescription(record);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add this prescription yet.')),
      );
    }
  }

  Future<void> _deletePrescription(int index, PrescriptionRecord record) async {
    try {
      await _repository.deletePrescription(record.id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this prescription.')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out right now.')),
      );
    }
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.notifications_rounded, label: 'Reminders'),
      (icon: Icons.account_balance_wallet_rounded, label: 'Pricing'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xEE171717),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38111B2A),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          final item = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.11)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: selected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
