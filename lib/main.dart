import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/farm_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/corrales_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmProvider()),
      ],
      child: const SmartFarmApp(),
    ),
  );
}

class SmartFarmApp extends StatefulWidget {
  const SmartFarmApp({super.key});

  @override
  State<SmartFarmApp> createState() => _SmartFarmAppState();
}

class _SmartFarmAppState extends State<SmartFarmApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFarm',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: _showSplash
          ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
          : const CorralesScreen(),
    );
  }
}