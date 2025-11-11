class DeviceStatusModel {
  final String deviceId;
  final double currentWeight;
  final bool isOverload;
  final bool motorEnabled;
  final bool alarmEnabled;
  final DateTime? lastUpdate;

  const DeviceStatusModel({
    required this.deviceId,
    required this.currentWeight,
    required this.isOverload,
    required this.motorEnabled,
    required this.alarmEnabled,
    this.lastUpdate,
  });

  factory DeviceStatusModel.fromJson(Map<String, dynamic> json) {
    // some APIs wrap data in { success, data: {...} }
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? json;
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
    );
  }
}

