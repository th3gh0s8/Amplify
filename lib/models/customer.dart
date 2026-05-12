class Customer {
  final int? id;
  final int partnerId;
  final String companyName;
  final String companyAddress;
  final String companyNumber;
  final String adminName;
  final String adminNumber;
  final String companyArea;
  final String companyField;
  final String remarks;
  final String additionalFeatures;
  final String status;
  final String reference;
  final String preferredLang;
  final String? packageName;
  final String? additionalPackages;
  final double? discount;

  Customer({
    this.id,
    required this.partnerId,
    required this.companyName,
    required this.companyAddress,
    required this.companyNumber,
    required this.adminName,
    required this.adminNumber,
    required this.companyArea,
    required this.companyField,
    required this.remarks,
    required this.additionalFeatures,
    this.status = 'Pending',
    this.reference = '',
    this.preferredLang = 'English',
    this.packageName,
    this.additionalPackages,
    this.discount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Aggressively convert every potential numeric field to string
    String safeString(dynamic val) => (val ?? '').toString();
    int safeInt(dynamic val) => int.tryParse(val?.toString() ?? '0') ?? 0;

    return Customer(
      id: int.tryParse(json['ID']?.toString() ?? ''),
      partnerId: safeInt(json['partnerTb']),
      companyName: safeString(json['com_name']),
      companyAddress: safeString(json['com_address']),
      companyNumber: safeString(json['com_number']),
      adminName: safeString(json['admin_name']),
      adminNumber: safeString(json['admin_number']),
      companyArea: safeString(json['com_area']),
      companyField: safeString(json['com_field']),
      remarks: safeString(json['remarks']),
      additionalFeatures: safeString(json['additional_features']),
      status: (json['display_status'] ?? json['status'] ?? 'PENDING').toString().toUpperCase(),
      reference: safeString(json['reference']),
      preferredLang: safeString(json['preferred_lang']).isEmpty ? 'English' : safeString(json['preferred_lang']),
      packageName: safeString(json['package_name']),
      additionalPackages: safeString(json['additional_packages']),
      discount: double.tryParse(json['discount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerTb': partnerId,
      'com_name': companyName,
      'com_address': companyAddress,
      'com_number': companyNumber,
      'admin_name': adminName,
      'admin_number': adminNumber,
      'com_area': companyArea,
      'com_field': companyField,
      'remarks': remarks,
      'additional_features': additionalFeatures,
      'reference': reference,
      'preferred_lang': preferredLang,
      'package_name': packageName,
      'additional_packages': additionalPackages,
      'discount': discount,
    };
  }
}
