class CancelReason {
  final int id;
  final String name;
  final String description;

  CancelReason({
    required this.id,
    required this.name,
    this.description = '',
  });
}

// Sample reasons, these would typically come from the API
final List<CancelReason> cancelReasons = [
  CancelReason(id: 1, name: 'Бригада занята'),
  CancelReason(id: 2, name: 'Дальняя локация'),
  CancelReason(id: 3, name: 'Технические проблемы'),
  CancelReason(id: 4, name: 'Нет соответствующего специалиста'),
  CancelReason(id: 5, name: 'Другая причина'),
];