class LastTelemetryModel {
  final String id;
  final double weight;
  final bool isOverload;
  final DateTime timestamp;
  final String deviceId;

  const LastTelemetryModel({
    required this.id,
    required this.weight,
    required this.isOverload,
    required this.timestamp,
    required this.deviceId,
  });

  factory LastTelemetryModel.fromJson(Map<String, dynamic> json) {
    return LastTelemetryModel(
      id: json['id'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      isOverload: json['is_overload'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      deviceId: json['device_id'] as String? ?? '',
    );
  }
}

class DeviceStatusModel {
  final String deviceId;
  final double currentWeight;
  final bool isOverload;
  final bool motorEnabled;
  final bool alarmEnabled;
  final DateTime? lastUpdate;
  final LastTelemetryModel? lastTelemetry;

  const DeviceStatusModel({
    required this.deviceId,
    required this.currentWeight,
    required this.isOverload,
    required this.motorEnabled,
    required this.alarmEnabled,
    this.lastUpdate,
    this.lastTelemetry,
  });

  factory DeviceStatusModel.fromJson(Map<String, dynamic> json) {
    // some APIs wrap data in { success, data: {...} }
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? json;
    
    LastTelemetryModel? lastTelemetry;
    if (data['last_telemetry'] != null) {
      lastTelemetry = LastTelemetryModel.fromJson(
        data['last_telemetry'] as Map<String, dynamic>,
      );
    }
    
    return DeviceStatusModel(
      deviceId: data['device_id'] as String? ?? '',
      currentWeight: (data['current_weight'] as num?)?.toDouble() ?? 0.0,
      isOverload: data['is_overload'] as bool? ?? false,
      motorEnabled: data['motor_enabled'] as bool? ?? false,
      alarmEnabled: (data['alarm_active'] as bool?) ??
          (data['alarm_enabled'] as bool?) ??
          false,
      lastUpdate: (data['last_update'] as String?) != null
          ? DateTime.tryParse(data['last_update'] as String)
          : null,
      lastTelemetry: lastTelemetry,
    );
  }
}

