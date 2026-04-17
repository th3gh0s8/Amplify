class Invoice {
  final int id;
  final int brId;
  final int cusCode;
  final int cusTb;
  final String cusName;
  final int partnerTb;
  final int value;
  final int comPres;
  final int comAmount;
  final int paid;
  final int balance;
  final DateTime date;
  final String time;

  Invoice({
    required this.id,
    required this.brId,
    required this.cusCode,
    required this.cusTb,
    required this.cusName,
    required this.partnerTb,
    required this.value,
    required this.comPres,
    required this.comAmount,
    required this.paid,
    required this.balance,
    required this.date,
    required this.time,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['ID'],
      brId: json['br_id'],
      cusCode: json['cus_code'],
      cusTb: json['cus_tb'],
      cusName: json['cus_name'],
      partnerTb: json['partner_tb'],
      value: json['value'],
      comPres: json['com_pres'],
      comAmount: json['com_amount'],
      paid: json['paid'],
      balance: json['balance'],
      date: DateTime.parse(json['date']),
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'br_id': brId,
      'cus_code': cusCode,
      'cus_tb': cusTb,
      'cus_name': cusName,
      'partner_tb': partnerTb,
      'value': value,
      'com_pres': comPres,
      'com_amount': comAmount,
      'paid': paid,
      'balance': balance,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
    };
  }
}
