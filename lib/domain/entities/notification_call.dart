// Model class for incoming push notification call data
class NotificationCall {
  final int id;
  final String occassionName;
  final bool isUnknownPatient;
  final String address;
  final String patientName;
  final String callerPhone;
  final String patientPhone;
  final String setupDate;
  final int brigadeId;
  final List<int> employeeIds;
  final bool isCancelled;

  NotificationCall({
    required this.id,
    required this.occassionName,
    required this.isUnknownPatient,
    required this.address,
    required this.patientName,
    required this.callerPhone,
    required this.patientPhone,
    required this.setupDate,
    required this.brigadeId,
    required this.employeeIds,
    this.isCancelled = false,
  });

  factory NotificationCall.fromJson(Map<String, dynamic> json, List<int> employeeIds, bool isCancelled) {
    final callData = json;

    return NotificationCall(
      id: callData['id'],
      occassionName: callData['idOccassionNavName'] ?? 'Не указано',
      isUnknownPatient: callData['isUnknownPatient'] ?? false,
      address: callData['addressFull'] ?? 'Адрес не указан',
      patientName: callData['fullName'] ?? 'Пациент не известен',
      callerPhone: callData['phoneCaller'] ?? '',
      patientPhone: callData['phonePatient'] ?? '',
      setupDate: callData['strbrigadeSetupDate'] ?? '',
      brigadeId: callData['brigadeId'] ?? 0,
      employeeIds: employeeIds,
      isCancelled: isCancelled,
    );
  }
}