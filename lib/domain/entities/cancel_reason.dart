class CancelReason {
  final int id;
  final String name;
  final String description;

  CancelReason({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory CancelReason.fromJson(Map<String, dynamic> json) {
    return CancelReason(
      id: json['id'] as int,
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
    );
  }
}