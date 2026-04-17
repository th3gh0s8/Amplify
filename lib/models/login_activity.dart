class LoginActivity {
  final int id;
  final int uId;
  final String actType;
  final DateTime time;
  final int status;

  LoginActivity({
    required this.id,
    required this.uId,
    required this.actType,
    required this.time,
    required this.status,
  });

  factory LoginActivity.fromJson(Map<String, dynamic> json) {
    return LoginActivity(
      id: json['id'],
      uId: json['u_id'],
      actType: json['act_type'],
      time: DateTime.parse(json['time']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'u_id': uId,
      'act_type': actType,
      'time': time.toIso8601String(),
      'status': status,
    };
  }
}
