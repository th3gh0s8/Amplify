class Partner {
  final String? id;
  final String firstName;
  final String lastName;
  final String? cCode;
  final String mobileNo;
  final String email;
  final String bankAccountNo;
  final String bankName;
  final String bankBranch;
  final String remarks;
  final String? partnerType;
  final String? nicNumber;
  final String? businessName;
  final String? businessType;
  final String? addressLine1;
  final String? city;
  final String? taxId;
  final String? website;

  Partner({
    this.id,
    required this.firstName,
    required this.lastName,
    this.cCode,
    required this.mobileNo,
    required this.email,
    required this.bankAccountNo,
    required this.bankName,
    required this.bankBranch,
    required this.remarks,
    this.partnerType,
    this.nicNumber,
    this.businessName,
    this.businessType,
    this.addressLine1,
    this.city,
    this.taxId,
    this.website,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert any value to a non-null string
    String s(dynamic val) => (val ?? '').toString();

    return Partner(
      id: json['ID']?.toString(),
      firstName: s(json['first_name']),
      lastName: s(json['last_name']),
      cCode: json['c_code']?.toString(),
      mobileNo: s(json['mobile_no']),
      email: s(json['email']),
      bankAccountNo: s(json['bank_account_no']),
      bankName: s(json['bank_name']),
      bankBranch: s(json['bank_ac_branch']),
      remarks: s(json['remarks']),
      partnerType: json['partner_type']?.toString(),
      nicNumber: json['nic_number']?.toString(),
      businessName: json['business_name']?.toString(),
      businessType: json['business_type']?.toString(),
      addressLine1: json['address_line1']?.toString(),
      city: json['city']?.toString(),
      taxId: json['tax_id']?.toString(),
      website: json['website']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'c_code': cCode,
      'mobile_no': mobileNo,
      'email': email,
      'bank_account_no': bankAccountNo,
      'bank_name': bankName,
      'bank_ac_branch': bankBranch,
      'remarks': remarks,
      'partner_type': partnerType,
      'nic_number': nicNumber,
      'business_name': businessName,
      'business_type': businessType,
      'address_line1': addressLine1,
      'city': city,
      'tax_id': taxId,
      'website': website,
    };
  }
}
