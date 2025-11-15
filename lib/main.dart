import 'package:flutter/material.dart';
import 'package:goscale/screens/main_screen.dart';
import 'core/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/device_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/control_provider.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceProvider>(
          create: (_) => DeviceProvider()..init(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<ControlProvider>(
          create: (_) => ControlProvider(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
