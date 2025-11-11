class SettingsModel {
  final double maxWeight;
  final String? deviceId;

  const SettingsModel({
    required this.maxWeight,
    this.deviceId,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? json;
    return SettingsModel(
      maxWeight: (data['max_weight'] as num?)?.toDouble() ?? 0.0,
      deviceId: data['device_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_weight': maxWeight,
      if (deviceId != null) 'device_id': deviceId,
    };
  }
}

