import 'package:goscale/core/constants.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = AppConstants.baseUrl;
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  /// -------------------------------
  /// 1. Health Check
  /// -------------------------------
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get('/health');
    return response.data;
  }

  /// -------------------------------
  /// 2. Device Registration
  /// -------------------------------
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    String? name,
    String? location,
  }) async {
    final response = await _dio.post(
      '/devices/register',
      data: {
        'device_id': deviceId,
        if (name != null) 'name': name,
        if (location != null) 'location': location,
      },
    );
    return response.data;
  }

  /// -------------------------------
  /// 3. Get Device Status
  /// -------------------------------
  Future<Map<String, dynamic>> getDeviceStatus(String deviceId) async {
    final response = await _dio.get('/devices/$deviceId/status');
    return response.data;
  }

  /// -------------------------------
  /// 4. Get Max Weight Setting
  /// -------------------------------
  Future<Map<String, dynamic>> getMaxWeight() async {
    final response = await _dio.get('/settings');
    return response.data;
  }

  /// -------------------------------
  /// 5. Update Max Weight Setting
  /// -------------------------------
  Future<Map<String, dynamic>> updateMaxWeight({
    required double maxWeight,
    String? deviceId,
  }) async {
    final response = await _dio.post(
      '/settings',
      data: {
        'max_weight': maxWeight,
        if (deviceId != null) 'device_id': deviceId,
      },
    );
    return response.data;
  }

  /// -------------------------------
  /// 6. Get Telemetry (Weight Logs)
  /// -------------------------------
  Future<Map<String, dynamic>> getTelemetry({
    String? deviceId,
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/telemetry',
      queryParameters: {
        if (deviceId != null) 'device_id': deviceId,
        'limit': limit,
        'offset': offset,
      },
    );
    return response.data;
  }

  /// -------------------------------
  /// 7. Get Events (Overload & Recovery)
  /// -------------------------------
  Future<Map<String, dynamic>> getEvents({
    String? deviceId,
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/events',
      queryParameters: {
        if (deviceId != null) 'device_id': deviceId,
        'limit': limit,
        'offset': offset,
      },
    );
    return response.data;
  }

  /// -------------------------------
  /// 8. Send Control Command
  /// -------------------------------
  Future<Map<String, dynamic>> sendControlCommand({
    required String deviceId,
    bool? motorEnabled,
    bool? alarmEnabled,
    String? direction, // "forward", "reverse", "stop"
    int? speed,
  }) async {
    final data = {
      'device_id': deviceId,
      if (motorEnabled != null) 'motor_enabled': motorEnabled,
      if (alarmEnabled != null) 'alarm_enabled': alarmEnabled,
      if (direction != null) 'direction': direction,
      if (speed != null) 'speed': speed,
    };

    final response = await _dio.post('/control', data: data);
    return response.data;
  }

  /// -------------------------------
  /// 9. Get Control Logs
  /// -------------------------------
  Future<Map<String, dynamic>> getControlLogs({
    String? deviceId,
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/control-log',
      queryParameters: {
        if (deviceId != null) 'device_id': deviceId,
        'limit': limit,
        'offset': offset,
      },
    );
    return response.data;
  }
}
