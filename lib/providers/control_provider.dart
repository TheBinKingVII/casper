import 'package:flutter/foundation.dart';
import 'package:goscale/services/api_service.dart';
import 'package:goscale/shared/device_prefs.dart';

class ControlProvider extends ChangeNotifier {
  ControlProvider({ApiServices? api}) : _api = api ?? ApiServices();

  final ApiServices _api;

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastDirection;
  int _currentSpeed = 100;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastDirection => _lastDirection;
  int get currentSpeed => _currentSpeed;

  void setSpeed(int speed) {
    _currentSpeed = speed.clamp(0, 100);
    notifyListeners();
  }

  Future<bool> sendControlCommand({
    required String direction, // "forward", "reverse", "stop"
    int? speed,
    String? deviceId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastDirection = direction;
    notifyListeners();

    try {
      final id = deviceId ?? await DevicePrefs.getDeviceId();
      if (id == null || id.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Device ID tidak ditemukan. Silakan daftarkan perangkat terlebih dahulu.';
        notifyListeners();
        return false;
      }

      final finalSpeed = speed ?? _currentSpeed;
      final result = await _api.sendControlCommand(
        deviceId: id,
        direction: direction,
        speed: direction == 'stop' ? null : finalSpeed,
      );

      _isLoading = false;
      final success = (result['success'] as bool?) ?? true;
      if (!success) {
        _errorMessage = result['error'] as String? ?? 'Gagal mengirim perintah kontrol';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> forward({int? speed, String? deviceId}) async {
    return sendControlCommand(
      direction: 'forward',
      speed: speed ?? 100,
      deviceId: deviceId,
    );
  }

  Future<bool> reverse({int? speed, String? deviceId}) async {
    return sendControlCommand(
      direction: 'reverse',
      speed: speed ?? 80,
      deviceId: deviceId,
    );
  }

  Future<bool> stop({String? deviceId}) async {
    return sendControlCommand(
      direction: 'stop',
      deviceId: deviceId,
    );
  }

  Future<bool> left({int? speed, String? deviceId}) async {
    return sendControlCommand(
      direction: 'left',
      speed: speed ?? 100,
      deviceId: deviceId,
    );
  }

  Future<bool> right({int? speed, String? deviceId}) async {
    return sendControlCommand(
      direction: 'right',
      speed: speed ?? 100,
      deviceId: deviceId,
    );
  }
}

