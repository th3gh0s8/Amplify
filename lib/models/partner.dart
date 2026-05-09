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
    return Partner(
      id: json['ID']?.toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      cCode: json['c_code']?.toString(),
      mobileNo: json['mobile_no']?.toString() ?? '',
      email: json['email'] ?? '',
      bankAccountNo: json['bank_account_no']?.toString() ?? '',
      bankName: json['bank_name'] ?? '',
      bankBranch: json['bank_ac_branch'] ?? '',
      remarks: json['remarks'] ?? '',
      partnerType: json['partner_type'],
      nicNumber: json['nic_number'],
      businessName: json['business_name'],
      businessType: json['business_type'],
      addressLine1: json['address_line1'],
      city: json['city'],
      taxId: json['tax_id'],
      website: json['website'],
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
