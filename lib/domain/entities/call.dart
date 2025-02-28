class Call {
  final String id;
  final String patientName;
  final String address;
  final DateTime timestamp;
  final String callReason;
  final String callType;
  final String status;

  Call({
    required this.id,
    required this.patientName,
    required this.address,
    required this.timestamp,
    required this.callReason,
    required this.callType,
    required this.status,
  });
}