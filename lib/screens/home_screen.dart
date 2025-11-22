import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:goscale/providers/device_provider.dart';
import 'package:goscale/providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _maxWeightController = TextEditingController();
  double _maxWeight = 5000.0;

  // Device registration controllers
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceLocationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _maxWeightController.text = _maxWeight.toStringAsFixed(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceProv = context.read<DeviceProvider>();
      final settingsProv = context.read<SettingsProvider>();
      if (deviceProv.isConnected) {
        settingsProv.loadMaxWeight(deviceId: deviceProv.deviceId).then((_) {
          final value = settingsProv.maxWeight;
          if (value != null && mounted) {
            setState(() {
              _maxWeight = value;
              _maxWeightController.text = _maxWeight.toStringAsFixed(0);
            });
          } else if (mounted && settingsProv.errorMessage != null) {
            // Log error tapi tetap gunakan nilai default
            debugPrint(
              'HomeScreen: Error loading max weight: ${settingsProv.errorMessage}',
            );
          }
        }).catchError((e) {
          debugPrint('HomeScreen: Exception loading max weight: $e');
          // Tetap gunakan nilai default jika ada error
        });
      }
    });
  }

  @override
  void dispose() {
    _maxWeightController.dispose();
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _deviceLocationController.dispose();
    super.dispose();
  }

  void _showEditMaxWeightDialog() {
    _maxWeightController.text = _maxWeight.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final settingsProv = context.watch<SettingsProvider>();
        final deviceProv = context.read<DeviceProvider>();
        return AlertDialog(
          title: const Text('Ubah Berat Maksimal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _maxWeightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Berat Maksimal (gram)',
                  hintText: 'Masukkan berat maksimal (gram)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Berat maksimal saat ini: ${_maxWeight.toStringAsFixed(0)} gram',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: settingsProv.isUpdating
                  ? null
                  : () async {
                      final newWeight = double.tryParse(
                        _maxWeightController.text,
                      );
                      if (newWeight == null || newWeight <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan berat yang valid'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final ok = await settingsProv.updateMaxWeight(
                        value: newWeight,
                        deviceId: deviceProv.deviceId,
                      );
                      if (!mounted) return;

                      if (ok) {
                        setState(() {
                          _maxWeight = settingsProv.maxWeight ?? newWeight;
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berat maksimal berhasil diubah menjadi ${_maxWeight.toStringAsFixed(0)} gram',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        final msg =
                            settingsProv.errorMessage ??
                            'Gagal mengubah berat maksimal';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: Text(settingsProv.isUpdating ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Selamat Datang',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kelola pengaturan skala mobil Anda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Device Registration Section
                      Text(
                        'Registrasi Perangkat',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Consumer<DeviceProvider>(
                          builder: (context, deviceProvider, _) {
                            if (deviceProvider.isConnected) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.lightGreenAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Perangkat terhubung: ${deviceProvider.deviceId}',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: deviceProvider.isLoading
                                        ? null
                                        : () async {
                                            await deviceProvider.disconnect();
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Perangkat diputuskan. Silakan daftar ulang jika diperlukan.',
                                                ),
                                              ),
                                            );
                                          },
                                    icon: const Icon(Icons.link_off_outlined),
                                    label: const Text('Putuskan Koneksi'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _deviceIdController,
                                  decoration: const InputDecoration(
                                    labelText: 'Device ID',
                                    hintText: 'contoh: esp32_001',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.qr_code_2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _deviceNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama (opsional)',
                                    hintText: 'contoh: Timbangan Utama',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _deviceLocationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Lokasi (opsional)',
                                    hintText: 'contoh: Gudang A',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(
                                      Icons.location_on_outlined,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: deviceProvider.isLoading
                                            ? null
                                            : () async {
                                                final id = _deviceIdController
                                                    .text
                                                    .trim();
                                                if (id.isEmpty) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Device ID wajib diisi',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final ok = await deviceProvider
                                                    .registerDevice(
                                                      deviceId: id,
                                                      name:
                                                          _deviceNameController
                                                              .text
                                                              .trim(),
                                                      location:
                                                          _deviceLocationController
                                                              .text
                                                              .trim(),
                                                    );

                                                if (!mounted) return;

                                                if (ok) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Perangkat berhasil diregistrasi',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  final msg =
                                                      deviceProvider
                                                          .errorMessage ??
                                                      'Gagal registrasi perangkat';
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(msg),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                        icon: deviceProvider.isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator.adaptive(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                              )
                                            : const Icon(Icons.save_outlined),
                                        label: Text(
                                          deviceProvider.isLoading
                                              ? 'Mendaftar...'
                                              : 'Daftarkan Perangkat',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            48,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Settings Section (Max Weight) - only when connected
                      Consumer<DeviceProvider>(
                        builder: (context, dp, _) {
                          if (!dp.isConnected) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengaturan',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.link_off_outlined,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Hubungkan/daftarkan perangkat untuk mengatur berat maksimal',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pengaturan',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Consumer<SettingsProvider>(
                                    builder: (context, sp, _) {
                                      return IconButton(
                                        onPressed: () async {
                                          await sp.loadMaxWeight(
                                            deviceId: dp.deviceId,
                                          );
                                          if (!mounted) return;
                                          if (sp.maxWeight != null) {
                                            setState(() {
                                              _maxWeight = sp.maxWeight!;
                                              _maxWeightController.text =
                                                  _maxWeight.toStringAsFixed(0);
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Berat maksimal berhasil dimuat ulang',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else if (sp.errorMessage != null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(sp.errorMessage!),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        icon: sp.isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator.adaptive(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                              ),
                                        tooltip: 'Muat ulang berat maksimal',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Consumer<SettingsProvider>(
                                builder: (context, sp, _) {
                                  final displayWeight =
                                      sp.maxWeight ?? _maxWeight;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (!dp.isConnected) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Daftarkan perangkat terlebih dahulu',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          _showEditMaxWeightDialog();
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.straighten,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Berat Maksimal',
                                                      style: theme
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${displayWeight.toStringAsFixed(0)} gram',
                                                      style: theme
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ketuk untuk mengubah berat maksimal mobil',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
