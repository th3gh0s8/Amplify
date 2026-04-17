class PayoutRequest {
  final int partnerId;
  final DateTime requestDate;
  final String requestTime;
  final int amount;
  final int status;
  final int receiptNo;

  PayoutRequest({
    required this.partnerId,
    required this.requestDate,
    required this.requestTime,
    required this.amount,
    required this.status,
    required this.receiptNo,
  });

  factory PayoutRequest.fromJson(Map<String, dynamic> json) {
    return PayoutRequest(
      partnerId: json['partner_id'],
      requestDate: DateTime.parse(json['request_date']),
      requestTime: json['request_time'],
      amount: json['amount'],
      status: json['status'],
      receiptNo: json['recipt_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partner_id': partnerId,
      'request_date': requestDate.toIso8601String().split('T')[0],
      'request_time': requestTime,
      'amount': amount,
      'status': status,
      'recipt_no': receiptNo,
    };
  }
}
