class TelemetryLogModel {
  final String id;
  final double weight;
  final bool isOverload;
  final DateTime timestamp;
  final String deviceId;

  const TelemetryLogModel({
    required this.id,
    required this.weight,
    required this.isOverload,
    required this.timestamp,
    required this.deviceId,
  });

  factory TelemetryLogModel.fromJson(Map<String, dynamic> json) {
    return TelemetryLogModel(
      id: json['id']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      isOverload: json['is_overload'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deviceId: json['device_id']?.toString() ?? '',
    );
  }
}

