import 'package:flutter/foundation.dart';
import 'package:goscale/services/api_service.dart';
import 'package:goscale/services/notification_service.dart';
import 'package:goscale/shared/device_prefs.dart';
import 'package:goscale/models/device_status_model.dart';

class DeviceProvider extends ChangeNotifier {
  DeviceProvider({ApiServices? api}) : _api = api ?? ApiServices();

  final ApiServices _api;
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastRegisterResult;
  String? _deviceId;
  DeviceStatusModel? _deviceStatus;
  bool _lastOverloadState = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastRegisterResult => _lastRegisterResult;
  String? get deviceId => _deviceId;
  bool get isConnected => (_deviceId != null && _deviceId!.isNotEmpty);
  DeviceStatusModel? get deviceStatus => _deviceStatus;

  Future<void> init() async {
    _deviceId = await DevicePrefs.getDeviceId();
    notifyListeners();
  }

  Future<bool> registerDevice({
    required String deviceId,
    String? name,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validasi panjang device_id (maksimal 100 karakter)
    if (deviceId.length > 100) {
      _isLoading = false;
      _errorMessage = 'Device ID terlalu panjang (maksimal 100 karakter)';
      notifyListeners();
      return false;
    }

    try {
      final result = await _api.registerDevice(
        deviceId: deviceId,
        name: name,
        location: location,
      );
      _lastRegisterResult = result;
      if ((result['success'] as bool?) ?? false) {
        _deviceId = deviceId;
        await DevicePrefs.setDeviceId(deviceId);
      }
      _isLoading = false;
      notifyListeners();
      return (result['success'] as bool?) ?? true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _deviceId = null;
    _deviceStatus = null;
    await DevicePrefs.clearDeviceId();
    notifyListeners();
  }

  Future<DeviceStatusModel?> loadDeviceStatus() async {
    if (!isConnected || _deviceId == null) {
      _deviceStatus = null;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getDeviceStatus(_deviceId!);
      _deviceStatus = DeviceStatusModel.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return _deviceStatus;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Check overload status and show notification with max weight (called from controller screen)
  Future<void> checkOverloadWithMaxWeight(double maxWeight) async {
    if (_deviceStatus != null) {
      final isOverload = _deviceStatus!.isOverload;
      final currentWeight = _deviceStatus!.currentWeight;

      if (isOverload != _lastOverloadState) {
        _lastOverloadState = isOverload;

        if (isOverload) {
          await _notificationService.showOverloadNotification(
            currentWeight: currentWeight,
            maxWeight: maxWeight,
          );
        } else {
          await _notificationService.showRecoveryNotification(
            currentWeight: currentWeight,
          );
        }
      }
    }
  }
}
