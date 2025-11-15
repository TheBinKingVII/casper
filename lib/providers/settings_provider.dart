import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:goscale/services/api_service.dart';
import 'package:goscale/shared/device_prefs.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({ApiServices? api}) : _api = api ?? ApiServices();

  final ApiServices _api;

  bool _isLoading = false;
  bool _isUpdating = false;
  double? _maxWeight;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  double? get maxWeight => _maxWeight;
  String? get errorMessage => _errorMessage;

  Future<void> loadMaxWeight({String? deviceId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = deviceId ?? await DevicePrefs.getDeviceId();
      final resp = await _api.getMaxWeight(deviceId: id);
      final data = (resp['data'] as Map?)?.cast<String, dynamic>() ?? resp;
      _maxWeight = (data['max_weight'] as num?)?.toDouble();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateMaxWeight({
    required double value,
    String? deviceId,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      var id = deviceId ?? await DevicePrefs.getDeviceId();

      // Trim whitespace jika ada
      if (id != null) {
        id = id.trim();
      }

      // Debug logging
      if (id != null) {
        debugPrint('UpdateMaxWeight - Device ID: "$id" (length: ${id.length})');
      } else {
        debugPrint(
          'UpdateMaxWeight - Device ID: null (will update global setting)',
        );
      }

      // Pastikan device_id tidak kosong string setelah trim
      if (id != null && id.isEmpty) {
        _isUpdating = false;
        _errorMessage = 'Device ID tidak valid';
        notifyListeners();
        return false;
      }

      // Validasi panjang device_id (maksimal 100 karakter)
      if (id != null && id.length > 100) {
        _isUpdating = false;
        _errorMessage =
            'Device ID terlalu panjang (${id.length} karakter, maksimal 100 karakter): "${id.substring(0, id.length > 50 ? 50 : id.length)}..."';
        notifyListeners();
        return false;
      }

      final resp = await _api.updateMaxWeight(maxWeight: value, deviceId: id);

      // Handle response structure: { "success": true, "data": { "success": true, "max_weight": 600.0, "device_id": "esp32_001" } }
      final success = (resp['success'] as bool?) ?? false;

      if (!success) {
        _isUpdating = false;
        _errorMessage =
            resp['error'] as String? ?? 'Gagal mengupdate berat maksimal';
        notifyListeners();
        return false;
      }

      final data = (resp['data'] as Map?)?.cast<String, dynamic>();
      if (data != null) {
        _maxWeight = (data['max_weight'] as num?)?.toDouble() ?? value;
      } else {
        _maxWeight = value;
      }

      _isUpdating = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isUpdating = false;

      // Cek apakah ada error message dari server
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        String? serverError;

        // Handle berbagai format error response
        if (errorData is Map<String, dynamic>) {
          serverError =
              errorData['error'] as String? ??
              errorData['message'] as String? ??
              errorData['detail'] as String?;
        } else if (errorData is String) {
          serverError = errorData;
        }

        // Debug logging
        debugPrint('Server error response: $errorData');

        // Handle database error messages
        if (serverError != null) {
          if (serverError.contains('value too long') ||
              serverError.contains('character varying')) {
            _errorMessage =
                'Data terlalu panjang. Pastikan Device ID tidak melebihi 100 karakter.\n\nError detail: $serverError';
          } else {
            _errorMessage = serverError;
          }
        } else {
          _errorMessage =
              'Server error: ${e.response?.statusCode}\n\nResponse: $errorData';
        }
      } else {
        _errorMessage = 'Network error: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isUpdating = false;
      final errorStr = e.toString();

      // Handle database error messages
      if (errorStr.contains('value too long') ||
          errorStr.contains('character varying')) {
        _errorMessage =
            'Data terlalu panjang. Pastikan Device ID tidak melebihi 100 karakter.';
      } else {
        _errorMessage = errorStr;
      }

      notifyListeners();
      return false;
    }
  }
}
