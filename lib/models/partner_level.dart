class PartnerLevel {
  final String levelName;
  final int minCustomers;
  final int profitPrMonthly;
  final int profitPrOneTime;

  PartnerLevel({
    required this.levelName,
    required this.minCustomers,
    required this.profitPrMonthly,
    required this.profitPrOneTime,
  });

  factory PartnerLevel.fromJson(Map<String, dynamic> json) {
    return PartnerLevel(
      levelName: json['level_name'],
      minCustomers: json['min_coustomers'],
      profitPrMonthly: json['profitPr_monthly'],
      profitPrOneTime: json['profitPr_oneTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_name': levelName,
      'min_coustomers': minCustomers,
      'profitPr_monthly': profitPrMonthly,
      'profitPr_oneTime': profitPrOneTime,
    };
  }
}
