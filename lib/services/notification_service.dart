import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _lastOverloadState = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized != null && initialized) {
      _isInitialized = true;
    }

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestAndroidPermissions();
    }
  }

  /// Request Android notification permissions (Android 13+)
  Future<void> _requestAndroidPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse _) {}

  /// Show overload notification
  Future<void> showOverloadNotification({
    required double currentWeight,
    required double maxWeight,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Prevent duplicate notifications
    if (_lastOverloadState == true) {
      return;
    }

    _lastOverloadState = true;

    const androidDetails = AndroidNotificationDetails(
      'overload_channel',
      'Overload Notifications',
      channelDescription: 'Notifikasi ketika berat mobil melebihi batas maksimal',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '⚠️ OVERLOAD DETECTED!',
      'Berat mobil ${currentWeight.toStringAsFixed(1)} gram melebihi batas maksimal ${maxWeight.toStringAsFixed(1)} gram',
      notificationDetails,
    );
  }

  /// Show recovery notification (when overload is resolved)
  Future<void> showRecoveryNotification({
    required double currentWeight,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Only show recovery if we previously showed overload
    if (_lastOverloadState == false) {
      return;
    }

    _lastOverloadState = false;

    const androidDetails = AndroidNotificationDetails(
      'overload_channel',
      'Overload Notifications',
      channelDescription: 'Notifikasi ketika berat mobil melebihi batas maksimal',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: false,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '✅ Overload Resolved',
      'Berat mobil kembali normal: ${currentWeight.toStringAsFixed(1)} gram',
      notificationDetails,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    _lastOverloadState = false;
  }
}

