class EventModel {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;
  final String deviceId;

  const EventModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.deviceId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deviceId: json['device_id']?.toString() ?? '',
    );
  }
}

