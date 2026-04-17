class Partner {
  final String firstName;
  final String lastName;
  final int mobileNo;
  final String email;
  final int bankAccountNo;
  final String bankName;
  final String bankAccountType;

  Partner({
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.email,
    required this.bankAccountNo,
    required this.bankName,
    required this.bankAccountType,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      firstName: json['first_name'],
      lastName: json['last_name'],
      mobileNo: json['mobile_no'],
      email: json['email'],
      bankAccountNo: json['bank_account_no'],
      bankName: json['bank_name'],
      bankAccountType: json['bank_account_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'mobile_no': mobileNo,
      'email': email,
      'bank_account_no': bankAccountNo,
      'bank_name': bankName,
      'bank_account_type': bankAccountType,
    };
  }
}
