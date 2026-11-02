import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/alarm_storage.dart';
import 'services/alarm_scheduler.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar to dark icons on transparent background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialise all services
  await AlarmStorage.init();
  await AlarmScheduler.init();
  await NotificationService.init();

  runApp(const CycleAlarmApp());
}

class CycleAlarmApp extends StatelessWidget {
  const CycleAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
