class ControlLogModel {
  final String id;
  final String deviceId;
  final Map<String, dynamic> command;
  final DateTime timestamp;
  final String? source;

  const ControlLogModel({
    required this.id,
    required this.deviceId,
    required this.command,
    required this.timestamp,
    this.source,
  });

  factory ControlLogModel.fromJson(Map<String, dynamic> json) {
    return ControlLogModel(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      command: (json['command'] as Map?)?.cast<String, dynamic>() ??
          (json['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      source: json['source']?.toString(),
    );
  }
}

