import 'package:flutter/material.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  bool _isPowerOn = false;
  double _currentWeight = 1250.5; // Example weight in kg
  double _maxWeight = 5000.0; // Maximum weight capacity

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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isPowerOn
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPowerOn ? Colors.green : Colors.grey,
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
                                color: _isPowerOn ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isPowerOn ? 'Aktif' : 'Nonaktif',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        children: [
                          // Weight Display
                          Text(
                            'Berat Mobil',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          // Current Weight
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentWeight.toStringAsFixed(1),
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 48 : 64,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isSmallScreen ? 12 : 16,
                                ),
                                child: Text(
                                  ' kg',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: isSmallScreen ? 18 : 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 32),
                          // Weight Progress Bar
                          Container(
                            width: screenWidth * 0.8,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _currentWeight / _maxWeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Weight Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0 kg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '${_maxWeight.toInt()} kg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          // Additional Info Cards
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.straighten,
                                  label: 'Berat Maks',
                                  value: '${_maxWeight.toInt()} kg',
                                  theme: theme,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.percent,
                                  label: 'Kapasitas',
                                  value:
                                      '${((_currentWeight / _maxWeight) * 100).toStringAsFixed(1)}%',
                                  theme: theme,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
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
                                // Up Button
                                DpadButton(
                                  icon: Icons.keyboard_arrow_up,
                                  onPressed: () {
                                    _handleDirection('up');
                                  },
                                  theme: theme,
                                  size: isCompact ? 50 : 60,
                                ),
                                SizedBox(height: isCompact ? 6 : 8),
                                // Left, Center, Right Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DpadButton(
                                      icon: Icons.keyboard_arrow_left,
                                      onPressed: () {
                                        _handleDirection('left');
                                      },
                                      theme: theme,
                                      size: isCompact ? 50 : 60,
                                    ),
                                    SizedBox(width: isCompact ? 8 : 12),
                                    // Center indicator or stop button
                                    Container(
                                      width: isCompact ? 50 : 60,
                                      height: isCompact ? 50 : 60,
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.stop,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: isCompact ? 20 : 24,
                                      ),
                                    ),
                                    SizedBox(width: isCompact ? 8 : 12),
                                    DpadButton(
                                      icon: Icons.keyboard_arrow_right,
                                      onPressed: () {
                                        _handleDirection('right');
                                      },
                                      theme: theme,
                                      size: isCompact ? 50 : 60,
                                    ),
                                  ],
                                ),
                                SizedBox(height: isCompact ? 6 : 8),
                                // Down Button
                                DpadButton(
                                  icon: Icons.keyboard_arrow_down,
                                  onPressed: () {
                                    _handleDirection('down');
                                  },
                                  theme: theme,
                                  size: isCompact ? 50 : 60,
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
                        // Power Switch Section
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Power',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 16 : 24),
                                // Power Switch Container
                                Container(
                                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                                  decoration: BoxDecoration(
                                    color: _isPowerOn
                                        ? theme.colorScheme.secondaryContainer
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _isPowerOn
                                          ? theme.colorScheme.secondary
                                          : theme.colorScheme.outline,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isPowerOn
                                            ? Icons.power
                                            : Icons.power_off,
                                        size: isCompact ? 36 : 48,
                                        color: _isPowerOn
                                            ? theme.colorScheme.secondary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                      SizedBox(height: isCompact ? 12 : 16),
                                      Switch(
                                        value: _isPowerOn,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPowerOn = value;
                                          });
                                        },
                                        activeColor:
                                            theme.colorScheme.secondary,
                                      ),
                                      SizedBox(height: isCompact ? 6 : 8),
                                      Text(
                                        _isPowerOn ? 'ON' : 'OFF',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _isPowerOn
                                                  ? theme.colorScheme.secondary
                                                  : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
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

  void _handleDirection(String direction) {
    // Handle direction button press
    debugPrint('Direction: $direction');
    // You can add API calls or state management here
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
  final VoidCallback onPressed;
  final ThemeData theme;
  final double size;

  const DpadButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.theme,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.53),
        ),
      ),
    );
  }
}
