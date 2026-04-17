class WebCode {
  final int id;
  final int uId;
  final int otpCode;
  final DateTime time;
  final int status;

  WebCode({
    required this.id,
    required this.uId,
    required this.otpCode,
    required this.time,
    required this.status,
  });

  factory WebCode.fromJson(Map<String, dynamic> json) {
    return WebCode(
      id: json['ID'],
      uId: json['u_Id'],
      otpCode: json['otp_code'],
      time: DateTime.parse(json['time']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'u_Id': uId,
      'otp_code': otpCode,
      'time': time.toIso8601String(),
      'status': status,
    };
  }
}
