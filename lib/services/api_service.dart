import 'package:flutter/foundation.dart';
import 'package:goscale/core/constants.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = AppConstants.baseUrl;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );

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
    try {
      debugPrint('=== API getDeviceStatus Request ===');
      debugPrint('URL: $baseUrl/devices/$deviceId/status');
      debugPrint('Method: GET');

      final response = await _dio.get('/devices/$deviceId/status');

      debugPrint('=== API getDeviceStatus Response ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      debugPrint('=== API getDeviceStatus Error ===');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');

      if (e.response != null) {
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
      }

      debugPrint('Request URL: ${e.requestOptions.uri}');
      rethrow;
    }
  }

  /// -------------------------------
  /// 4. Get Max Weight Setting
  /// -------------------------------
  Future<Map<String, dynamic>> getMaxWeight({String? deviceId}) async {
    final response = await _dio.get(
      '/settings',
      queryParameters: {if (deviceId != null) 'device_id': deviceId},
    );
    return response.data;
  }

  /// -------------------------------
  /// 5. Update Max Weight Setting
  /// -------------------------------
  Future<Map<String, dynamic>> updateMaxWeight({
    required double maxWeight,
    String? deviceId,
  }) async {
    try {
      // Trim dan validasi device_id sebelum dikirim
      String? trimmedDeviceId;
      if (deviceId != null) {
        trimmedDeviceId = deviceId.trim();
        if (trimmedDeviceId.isEmpty) {
          trimmedDeviceId = null;
        } else if (trimmedDeviceId.length > 100) {
          throw Exception(
            'Device ID terlalu panjang (${trimmedDeviceId.length} karakter, maksimal 100)',
          );
        }
      }

      // Pastikan max_weight adalah number
      final requestData = <String, dynamic>{
        'max_weight': maxWeight,
        if (trimmedDeviceId != null && trimmedDeviceId.isNotEmpty)
          'device_id': trimmedDeviceId,
      };

      // Debug logging - termasuk headers untuk perbandingan dengan Postman
      debugPrint('=== API updateMaxWeight Request ===');
      debugPrint('URL: $baseUrl/settings');
      debugPrint('Method: POST');
      debugPrint('Request Body: $requestData');
      debugPrint('max_weight type: ${maxWeight.runtimeType}');
      debugPrint('max_weight value: $maxWeight');
      debugPrint('device_id: $trimmedDeviceId');

      final response = await _dio.post(
        '/settings',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Debug logging response
      debugPrint('=== API updateMaxWeight Response ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      // Debug logging error - detail untuk debugging
      debugPrint('=== API updateMaxWeight Error ===');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');

      if (e.response != null) {
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
        debugPrint('Response Headers: ${e.response?.headers}');
      }

      // Log request yang dikirim untuk debugging
      debugPrint('Request Headers: ${e.requestOptions.headers}');
      debugPrint('Request Data: ${e.requestOptions.data}');
      debugPrint('Request URL: ${e.requestOptions.uri}');

      // Jika server mengembalikan error response dengan body
      if (e.response != null && e.response?.data != null) {
        return e.response!.data as Map<String, dynamic>;
      }
      // Jika tidak ada response body, throw ulang
      rethrow;
    }
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
