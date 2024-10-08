class Task {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String eventType;
  final String eventColor;
  final String eventFor;
  final String? roleId;
  bool isActive; 

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    required this.eventColor,
    required this.eventFor,
    this.roleId,
    required this.isActive,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['event_title'],
      description: json['event_description'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      eventType: json['event_type'],
      eventColor: json['event_color'],
      eventFor: json['event_for'].toString(),
      roleId: json['role_id'],
      isActive: json['is_active'].toLowerCase() == 'yes',
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? startDate,
    String? endDate,
    String? eventType,
    String? eventColor,
    String? eventFor,
    String? roleId,
    bool? isActive,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      eventType: eventType ?? this.eventType,
      eventColor: eventColor ?? this.eventColor,
      eventFor: eventFor ?? this.eventFor,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
    );
  }
}
