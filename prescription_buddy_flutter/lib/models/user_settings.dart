class UserSettings {
  const UserSettings({
    this.doseRemindersEnabled = true,
    this.priceDropAlertsEnabled = true,
  });

  final bool doseRemindersEnabled;
  final bool priceDropAlertsEnabled;

  UserSettings copyWith({
    bool? doseRemindersEnabled,
    bool? priceDropAlertsEnabled,
  }) {
    return UserSettings(
      doseRemindersEnabled: doseRemindersEnabled ?? this.doseRemindersEnabled,
      priceDropAlertsEnabled:
          priceDropAlertsEnabled ?? this.priceDropAlertsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doseRemindersEnabled': doseRemindersEnabled,
      'priceDropAlertsEnabled': priceDropAlertsEnabled,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    return UserSettings(
      doseRemindersEnabled: map?['doseRemindersEnabled'] as bool? ?? true,
      priceDropAlertsEnabled: map?['priceDropAlertsEnabled'] as bool? ?? true,
    );
  }
}
