import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goscale/providers/device_provider.dart';
import 'package:goscale/services/api_service.dart';
import 'package:goscale/models/telemetry_log_model.dart';
import 'package:goscale/utils/helpers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiServices _api = ApiServices();
  List<TelemetryLogModel> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _limit = 100;
  int _offset = 0;
  bool _hasMore = true;
  Timer? _autoRefreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogs();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted) return;
      final deviceProvider = context.read<DeviceProvider>();
      if (!deviceProvider.isConnected) return;
      _loadLogs(refresh: true, silent: true);
    });
  }

  Future<void> _loadLogs({bool refresh = false, bool silent = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _offset = 0;
      _hasMore = true;
      if (!silent) {
        _logs = [];
      }
    }

    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      _isLoading = true;
      _errorMessage = null;
    }

    try {
      final deviceProvider = context.read<DeviceProvider>();
      final deviceId = deviceProvider.deviceId;

      final response = await _api.getTelemetry(
        deviceId: deviceId,
        limit: _limit,
        offset: _offset,
      );

      if (mounted) {
        // Handle different response structures
        List<dynamic>? dataList;

        if (response['data'] != null) {
          if (response['data'] is List) {
            dataList = response['data'] as List<dynamic>;
          } else if (response['data'] is Map) {
            // Some APIs wrap data in { data: { items: [...] } }
            final dataMap = response['data'] as Map<String, dynamic>;
            if (dataMap['items'] is List) {
              dataList = dataMap['items'] as List<dynamic>;
            } else if (dataMap['data'] is List) {
              dataList = dataMap['data'] as List<dynamic>;
            }
          }
        }

        if (dataList != null) {
          final newLogs = dataList
              .map((json) {
                try {
                  return TelemetryLogModel.fromJson(
                    json as Map<String, dynamic>,
                  );
                } catch (e) {
                  return null;
                }
              })
              .whereType<TelemetryLogModel>()
              .toList();

          if (mounted) {
            setState(() {
              if (refresh) {
                _logs = newLogs;
              } else {
                _logs.addAll(newLogs);
              }
              _hasMore = newLogs.length == _limit;
              _offset += newLogs.length;
              _isLoading = false;
            });
          } else {
            _isLoading = false;
          }
        } else if (response['success'] == false) {
          if (mounted) {
            setState(() {
              _errorMessage =
                  response['error'] as String? ?? 'Gagal memuat log';
              _isLoading = false;
            });
          } else {
            _isLoading = false;
          }
        } else {
          // Empty response or unknown structure
          if (mounted) {
            setState(() {
              if (refresh) {
                _logs = [];
              }
              _hasMore = false;
              _isLoading = false;
            });
          } else {
            _isLoading = false;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshLogs() async {
    await _loadLogs(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Berat'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !deviceProvider.isConnected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.device_unknown, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Device tidak terhubung',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungkan device terlebih dahulu',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null && _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshLogs,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _logs.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data log',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshLogs,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _logs.length) {
                    if (_hasMore && !_isLoading) {
                      _loadLogs();
                    }
                    return _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  final log = _logs[index];
                  return _buildLogCard(context, theme, log);
                },
              ),
            ),
    );
  }

  Widget _buildLogCard(
    BuildContext context,
    ThemeData theme,
    TelemetryLogModel log,
  ) {
    final isOverload = log.isOverload;
    final weight = log.weight;
    final timestamp = log.timestamp;
    final formattedDate = Helpers.formatDateTime(
      timestamp,
      format: 'dd/MM/yyyy HH:mm:ss',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverload ? Colors.red : Colors.green,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${weight.toStringAsFixed(1)} g',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOverload ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOverload ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOverload ? Colors.red[300]! : Colors.green[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOverload ? Icons.warning : Icons.check_circle,
                        size: 16,
                        color: isOverload ? Colors.red[700] : Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverload ? 'Overload' : 'Normal',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isOverload
                              ? Colors.red[700]
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (log.deviceId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.devices, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Device: ${log.deviceId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
