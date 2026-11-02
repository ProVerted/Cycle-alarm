import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_model.dart';

class AlarmStorage {
  static const String _boxName = 'alarms';
  static Box<AlarmModel>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmModelAdapter());
    _box = await Hive.openBox<AlarmModel>(_boxName);
  }

  static Box<AlarmModel> get box {
    if (_box == null) throw Exception('AlarmStorage not initialised');
    return _box!;
  }

  static List<AlarmModel> getAll() => box.values.toList();

  static Future<void> save(AlarmModel alarm) async {
    await box.put(alarm.id, alarm);
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }

  static AlarmModel? getById(String id) => box.get(id);
}
