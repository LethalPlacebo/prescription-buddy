import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrescriptionRecord {
  const PrescriptionRecord({
    required this.id,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.note,
    required this.reminderLabel,
    required this.reminderTime,
    required this.repeatDays,
    this.noteColor = AppTheme.muted,
    this.reminderLabelColor = AppTheme.muted,
    this.reminderTimeBackground = Colors.white,
    this.sortOrder = 0,
  });

  final String id;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String price;
  final String note;
  final Color noteColor;
  final String reminderLabel;
  final Color reminderLabelColor;
  final TimeOfDay reminderTime;
  final Set<String> repeatDays;
  final Color reminderTimeBackground;
  final int sortOrder;

  PrescriptionRecord copyWith({
    String? id,
    IconData? icon,
    Color? iconBg,
    Color? iconColor,
    String? title,
    String? subtitle,
    String? price,
    String? note,
    Color? noteColor,
    String? reminderLabel,
    Color? reminderLabelColor,
    TimeOfDay? reminderTime,
    Set<String>? repeatDays,
    Color? reminderTimeBackground,
    int? sortOrder,
  }) {
    return PrescriptionRecord(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      iconColor: iconColor ?? this.iconColor,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      note: note ?? this.note,
      noteColor: noteColor ?? this.noteColor,
      reminderLabel: reminderLabel ?? this.reminderLabel,
      reminderLabelColor: reminderLabelColor ?? this.reminderLabelColor,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatDays: repeatDays ?? this.repeatDays,
      reminderTimeBackground:
          reminderTimeBackground ?? this.reminderTimeBackground,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'iconBg': iconBg.toARGB32(),
      'iconColor': iconColor.toARGB32(),
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'note': note,
      'noteColor': noteColor.toARGB32(),
      'reminderLabel': reminderLabel,
      'reminderLabelColor': reminderLabelColor.toARGB32(),
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'repeatDays': repeatDays.toList(),
      'reminderTimeBackground': reminderTimeBackground.toARGB32(),
      'sortOrder': sortOrder,
    };
  }

  factory PrescriptionRecord.fromMap(String id, Map<String, dynamic> map) {
    final repeatDays =
        (map['repeatDays'] as List<dynamic>? ?? const <dynamic>[])
            .map((day) => day.toString())
            .toSet();

    return PrescriptionRecord(
      id: id,
      icon: IconData(
        (map['iconCodePoint'] as num?)?.toInt() ??
            Icons.medication_rounded.codePoint,
        fontFamily: map['iconFontFamily']?.toString() ??
            Icons.medication_rounded.fontFamily,
        fontPackage: map['iconFontPackage']?.toString(),
      ),
      iconBg: Color(
        (map['iconBg'] as num?)?.toInt() ?? const Color(0xFFE8F4EF).toARGB32(),
      ),
      iconColor: Color(
        (map['iconColor'] as num?)?.toInt() ?? AppTheme.emerald.toARGB32(),
      ),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      noteColor: Color(
        (map['noteColor'] as num?)?.toInt() ?? AppTheme.muted.toARGB32(),
      ),
      reminderLabel: map['reminderLabel']?.toString() ?? 'Reminder',
      reminderLabelColor: Color(
        (map['reminderLabelColor'] as num?)?.toInt() ??
            AppTheme.muted.toARGB32(),
      ),
      reminderTime: TimeOfDay(
        hour: (map['reminderHour'] as num?)?.toInt() ?? 9,
        minute: (map['reminderMinute'] as num?)?.toInt() ?? 0,
      ),
      repeatDays: repeatDays.isEmpty
          ? {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'}
          : repeatDays,
      reminderTimeBackground: Color(
        (map['reminderTimeBackground'] as num?)?.toInt() ??
            Colors.white.toARGB32(),
      ),
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static List<PrescriptionRecord> starterRecords() {
    return const [
      PrescriptionRecord(
        id: 'metformin-er',
        icon: Icons.medication_liquid_rounded,
        iconBg: Color(0xFFFFF1D8),
        iconColor: Color(0xFF9A6B14),
        title: 'Metformin ER',
        subtitle: '30 tablets - CVS nearby',
        price: '\$12.40',
        note: 'Save 28%',
        noteColor: AppTheme.emerald,
        reminderLabel: 'Morning',
        reminderLabelColor: AppTheme.emerald,
        reminderTime: TimeOfDay(hour: 11, minute: 30),
        repeatDays: {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'},
        reminderTimeBackground: Color(0xFFD8F1EB),
        sortOrder: 0,
      ),
      PrescriptionRecord(
        id: 'lisinopril',
        icon: Icons.local_pharmacy_rounded,
        iconBg: Color(0xFFD8F1EB),
        iconColor: AppTheme.emerald,
        title: 'Lisinopril',
        subtitle: '90 tablets - Walgreens',
        price: '\$9.90',
        note: 'Stable pricing',
        reminderLabel: 'Afternoon',
        reminderTime: TimeOfDay(hour: 14, minute: 0),
        repeatDays: {'Mon', 'Wed', 'Fri'},
        reminderTimeBackground: Color(0xFFFFF1D8),
        sortOrder: 1,
      ),
      PrescriptionRecord(
        id: 'ozempic',
        icon: Icons.water_drop_rounded,
        iconBg: Color(0xFFF6D8D6),
        iconColor: Color(0xFFB54747),
        title: 'Ozempic',
        subtitle: '1 pen - Capsule Pharmacy',
        price: '\$892',
        note: '2 lower offers',
        noteColor: Color(0xFF9A6B14),
        reminderLabel: 'Evening',
        reminderLabelColor: AppTheme.muted,
        reminderTime: TimeOfDay(hour: 18, minute: 30),
        repeatDays: {'Tue', 'Thu', 'Sat'},
        reminderTimeBackground: Color(0xFFFFE8E6),
        sortOrder: 2,
      ),
    ];
  }
}
