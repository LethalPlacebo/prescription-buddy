class MedicationPriceOffer {
  const MedicationPriceOffer({
    required this.id,
    required this.medicationName,
    required this.storeName,
    required this.priceLabel,
    required this.sourceLabel,
    required this.lastUpdatedLabel,
    this.isOtc = false,
    this.genericName,
    this.sourceType = 'admin_manual',
    this.cmsPlanType,
    this.cmsContractId,
    this.cmsPlanId,
  });

  final String id;
  final String medicationName;
  final String storeName;
  final String priceLabel;
  final String sourceLabel;
  final String lastUpdatedLabel;
  final bool isOtc;
  final String? genericName;
  final String sourceType;
  final String? cmsPlanType;
  final String? cmsContractId;
  final String? cmsPlanId;

  MedicationPriceOffer copyWith({
    String? id,
    String? medicationName,
    String? storeName,
    String? priceLabel,
    String? sourceLabel,
    String? lastUpdatedLabel,
    bool? isOtc,
    String? genericName,
    String? sourceType,
    String? cmsPlanType,
    String? cmsContractId,
    String? cmsPlanId,
  }) {
    return MedicationPriceOffer(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      storeName: storeName ?? this.storeName,
      priceLabel: priceLabel ?? this.priceLabel,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      lastUpdatedLabel: lastUpdatedLabel ?? this.lastUpdatedLabel,
      isOtc: isOtc ?? this.isOtc,
      genericName: genericName ?? this.genericName,
      sourceType: sourceType ?? this.sourceType,
      cmsPlanType: cmsPlanType ?? this.cmsPlanType,
      cmsContractId: cmsContractId ?? this.cmsContractId,
      cmsPlanId: cmsPlanId ?? this.cmsPlanId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationName': medicationName,
      'storeName': storeName,
      'priceLabel': priceLabel,
      'sourceLabel': sourceLabel,
      'lastUpdatedLabel': lastUpdatedLabel,
      'isOtc': isOtc,
      'genericName': genericName,
      'sourceType': sourceType,
      'cmsPlanType': cmsPlanType,
      'cmsContractId': cmsContractId,
      'cmsPlanId': cmsPlanId,
      'searchName': medicationName.toLowerCase(),
    };
  }

  factory MedicationPriceOffer.fromMap(String id, Map<String, dynamic> map) {
    return MedicationPriceOffer(
      id: id,
      medicationName: map['medicationName']?.toString() ?? '',
      storeName: map['storeName']?.toString() ?? '',
      priceLabel: map['priceLabel']?.toString() ?? '',
      sourceLabel: map['sourceLabel']?.toString() ?? '',
      lastUpdatedLabel: map['lastUpdatedLabel']?.toString() ?? '',
      isOtc: map['isOtc'] as bool? ?? false,
      genericName: map['genericName']?.toString(),
      sourceType: map['sourceType']?.toString() ?? 'admin_manual',
      cmsPlanType: map['cmsPlanType']?.toString(),
      cmsContractId: map['cmsContractId']?.toString(),
      cmsPlanId: map['cmsPlanId']?.toString(),
    );
  }

  static List<MedicationPriceOffer> starterOffers() {
    return const [
      MedicationPriceOffer(
        id: 'metformin-cvs',
        medicationName: 'Metformin ER 500mg',
        genericName: 'Metformin',
        storeName: 'CVS Pharmacy',
        priceLabel: '\$12.40',
        sourceLabel: 'Source: Admin-managed quarterly price',
        lastUpdatedLabel: 'Last updated Apr 8, 2026',
      ),
      MedicationPriceOffer(
        id: 'metformin-walgreens',
        medicationName: 'Metformin ER 500mg',
        genericName: 'Metformin',
        storeName: 'Walgreens',
        priceLabel: '\$13.10',
        sourceLabel: 'Source: Admin-managed quarterly price',
        lastUpdatedLabel: 'Last updated Apr 8, 2026',
      ),
      MedicationPriceOffer(
        id: 'ibuprofen-target',
        medicationName: 'Ibuprofen 200mg',
        genericName: 'Ibuprofen',
        storeName: 'Target Pharmacy',
        priceLabel: '\$8.99',
        sourceLabel: 'Source: Admin-managed OTC price',
        lastUpdatedLabel: 'Last updated Apr 8, 2026',
        isOtc: true,
      ),
    ];
  }
}
