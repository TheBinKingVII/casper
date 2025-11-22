import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goscale/providers/control_provider.dart';
import 'package:goscale/providers/device_provider.dart';
import 'package:goscale/providers/settings_provider.dart';
import 'package:goscale/models/device_status_model.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  Timer? _statusTimer;
  DeviceStatusModel? _deviceStatus;
  double _currentWeight = 0.0;
  double _maxWeight = 5000.0;

  @override
  void initState() {
    super.initState();
    // Load status pertama kali dan setup auto-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeviceStatus();
      _loadMaxWeight();
      // Auto-refresh setiap 1 detik
      _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _loadDeviceStatus();
      });
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeviceStatus() async {
    final deviceProvider = context.read<DeviceProvider>();
    if (!deviceProvider.isConnected) {
      debugPrint(
        'ControllerScreen: Device not connected, skipping status load',
      );
      return;
    }

    try {
      debugPrint('ControllerScreen: Loading device status...');
      final status = await deviceProvider.loadDeviceStatus();
      if (status != null && mounted) {
        debugPrint(
          'ControllerScreen: Status loaded - currentWeight: ${status.currentWeight}, isOverload: ${status.isOverload}',
        );
        setState(() {
          _deviceStatus = status;
          _currentWeight = status.currentWeight;
        });

        // Check overload with max weight for notification
        final settingsProvider = context.read<SettingsProvider>();
        final maxWeight = settingsProvider.maxWeight ?? _maxWeight;
        await deviceProvider.checkOverloadWithMaxWeight(maxWeight);
      } else {
        debugPrint('ControllerScreen: Status is null or widget not mounted');
      }
    } catch (e) {
      debugPrint('ControllerScreen: Error loading device status: $e');
    }
  }

  Future<void> _loadMaxWeight() async {
    final settingsProvider = context.read<SettingsProvider>();
    final deviceProvider = context.read<DeviceProvider>();
    if (deviceProvider.isConnected) {
      try {
        await settingsProvider.loadMaxWeight(deviceId: deviceProvider.deviceId);
        if (mounted && settingsProvider.maxWeight != null) {
          setState(() {
            _maxWeight = settingsProvider.maxWeight!;
          });
        } else if (mounted && settingsProvider.errorMessage != null) {
          // Log error tapi tetap gunakan nilai default
          debugPrint(
            'ControllerScreen: Error loading max weight: ${settingsProvider.errorMessage}',
          );
        }
      } catch (e) {
        debugPrint('ControllerScreen: Exception loading max weight: $e');
        // Tetap gunakan nilai default jika ada error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Column(
        children: [
          // Top Section - Weight Display
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Status Indicator - Fixed at top
                  Padding(
                    padding: EdgeInsets.only(
                      top: isSmallScreen ? 16.0 : 24.0,
                      left: isSmallScreen ? 16.0 : 24.0,
                      right: isSmallScreen ? 16.0 : 24.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Overload Warning
                        if (_deviceStatus?.isOverload == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'OVERLOAD!',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        // Status Indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: (_deviceStatus?.motorEnabled ?? false)
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (_deviceStatus?.motorEnabled ?? false)
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          (_deviceStatus?.motorEnabled ?? false)
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (_deviceStatus?.motorEnabled ?? false)
                                        ? 'Aktif'
                                        : 'Nonaktif',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16.0 : 24.0,
                        vertical: isSmallScreen ? 16.0 : 10.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Weight Display
                          Text(
                            'Berat Mobil',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          // Current Weight
                          Consumer<DeviceProvider>(
                            builder: (context, deviceProv, _) {
                              final currentWeight =
                                  _deviceStatus?.currentWeight ??
                                  _currentWeight;
                              final isOverload =
                                  _deviceStatus?.isOverload ?? false;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentWeight.toStringAsFixed(1),
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          color: isOverload
                                              ? Colors.red.shade300
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 48 : 64,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: isSmallScreen ? 12 : 16,
                                    ),
                                    child: Text(
                                      ' gram',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: isSmallScreen ? 18 : 22,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          // Weight Progress Bar
                          Consumer2<DeviceProvider, SettingsProvider>(
                            builder: (context, deviceProv, settingsProv, _) {
                              final maxWeight =
                                  settingsProv.maxWeight ?? _maxWeight;
                              final currentWeight =
                                  _deviceStatus?.currentWeight ??
                                  _currentWeight;
                              final isOverload =
                                  _deviceStatus?.isOverload ?? false;
                              final progress = maxWeight > 0
                                  ? (currentWeight / maxWeight).clamp(0.0, 1.0)
                                  : 0.0;

                              return Column(
                                children: [
                                  Container(
                                    width: screenWidth * 0.8,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isOverload
                                                ? [
                                                    Colors.red,
                                                    Colors.red.withOpacity(0.8),
                                                  ]
                                                : [
                                                    Colors.white,
                                                    Colors.white.withOpacity(
                                                      0.8,
                                                    ),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Weight Info
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '0 gram',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        '${maxWeight.toInt()} gram',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          // Additional Info Cards
                          Consumer2<DeviceProvider, SettingsProvider>(
                            builder: (context, deviceProv, settingsProv, _) {
                              final maxWeight =
                                  settingsProv.maxWeight ?? _maxWeight;
                              final currentWeight =
                                  _deviceStatus?.currentWeight ??
                                  _currentWeight;
                              final capacity = maxWeight > 0
                                  ? ((currentWeight / maxWeight) * 100)
                                        .toStringAsFixed(1)
                                  : '0.0';

                              return Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.straighten,
                                      label: 'Berat Maks',
                                      value: '${maxWeight.toInt()} gram',
                                      theme: theme,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.percent,
                                      label: 'Kapasitas',
                                      value: '$capacity%',
                                      theme: theme,
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Section - Controls
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 300;
                  return Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    child: Row(
                      children: [
                        // D-pad Section
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kontrol',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 12 : 20),
                                // Up Button (Forward)
                                Consumer<ControlProvider>(
                                  builder: (context, cp, _) {
                                    return DpadButton(
                                      icon: Icons.keyboard_arrow_up,
                                      onPressed: cp.isLoading
                                          ? null
                                          : () {
                                              _handleForward(context);
                                            },
                                      theme: theme,
                                      size: isCompact ? 50 : 60,
                                    );
                                  },
                                ),
                                SizedBox(height: isCompact ? 6 : 8),
                                // Stop Button (Center)
                                Consumer<ControlProvider>(
                                  builder: (context, cp, _) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: cp.isLoading
                                            ? null
                                            : () {
                                                _handleStop(context);
                                              },
                                        borderRadius: BorderRadius.circular(
                                          (isCompact ? 50 : 60) / 2,
                                        ),
                                        child: Container(
                                          width: isCompact ? 50 : 60,
                                          height: isCompact ? 50 : 60,
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .errorContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.stop,
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                            size: isCompact ? 20 : 24,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: isCompact ? 6 : 8),
                                // Down Button (Reverse)
                                Consumer<ControlProvider>(
                                  builder: (context, cp, _) {
                                    return DpadButton(
                                      icon: Icons.keyboard_arrow_down,
                                      onPressed: cp.isLoading
                                          ? null
                                          : () {
                                              _handleReverse(context);
                                            },
                                      theme: theme,
                                      size: isCompact ? 50 : 60,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1,
                          margin: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                        // Speed Control Section
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kecepatan',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 16 : 24),
                                // Speed Control Container
                                Consumer<ControlProvider>(
                                  builder: (context, cp, _) {
                                    return Container(
                                      padding: EdgeInsets.all(
                                        isCompact ? 16 : 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.colorScheme.secondary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.speed,
                                            size: isCompact ? 36 : 48,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          SizedBox(height: isCompact ? 12 : 16),
                                          Text(
                                            '${cp.currentSpeed}%',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                          ),
                                          SizedBox(height: isCompact ? 12 : 16),
                                          Slider(
                                            value: cp.currentSpeed.toDouble(),
                                            min: 0,
                                            max: 100,
                                            divisions: 20,
                                            label: '${cp.currentSpeed}%',
                                            onChanged: (value) {
                                              cp.setSpeed(value.toInt());
                                            },
                                            activeColor:
                                                theme.colorScheme.secondary,
                                          ),
                                          SizedBox(height: isCompact ? 6 : 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  cp.setSpeed(80);
                                                },
                                                child: const Text('80%'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  cp.setSpeed(100);
                                                },
                                                child: const Text('100%'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForward(BuildContext context) async {
    final controlProvider = context.read<ControlProvider>();
    final deviceProvider = context.read<DeviceProvider>();

    if (!deviceProvider.isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftarkan perangkat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await controlProvider.forward(
      deviceId: deviceProvider.deviceId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perintah maju berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMsg =
          controlProvider.errorMessage ?? 'Gagal mengirim perintah maju';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReverse(BuildContext context) async {
    final controlProvider = context.read<ControlProvider>();
    final deviceProvider = context.read<DeviceProvider>();

    if (!deviceProvider.isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftarkan perangkat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await controlProvider.reverse(
      deviceId: deviceProvider.deviceId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perintah mundur berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMsg =
          controlProvider.errorMessage ?? 'Gagal mengirim perintah mundur';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleStop(BuildContext context) async {
    final controlProvider = context.read<ControlProvider>();
    final deviceProvider = context.read<DeviceProvider>();

    if (!deviceProvider.isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftarkan perangkat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await controlProvider.stop(
      deviceId: deviceProvider.deviceId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perintah stop berhasil dikirim'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMsg =
          controlProvider.errorMessage ?? 'Gagal mengirim perintah stop';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final bool isSmallScreen;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 24),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 11 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DpadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ThemeData theme;
  final double size;

  const DpadButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.theme,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    )
                  : null,
              color: isEnabled
                  ? null
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              size: size * 0.53,
            ),
          ),
        ),
      ),
    );
  }
}
