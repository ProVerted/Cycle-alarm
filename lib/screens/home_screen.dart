import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/alarm_model.dart';
import '../services/alarm_scheduler.dart';
import '../services/alarm_storage.dart';
import '../utils/app_theme.dart';
import 'create_edit_alarm_screen.dart';
import 'active_alarm_screen.dart';
import 'dart:isolate';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmModel> _alarms = [];
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _listenForAlarmFire();
  }

  void _listenForAlarmFire() {
    // Register port so background isolate can signal the UI
    IsolateNameServer.registerPortWithName(_port.sendPort, 'alarm_ui_port');
    _port.listen((alarmId) {
      final alarm = AlarmStorage.getById(alarmId as String);
      if (alarm != null && mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ActiveAlarmScreen(alarm: alarm),
        ));
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('alarm_ui_port');
    _port.close();
    super.dispose();
  }

  void _loadAlarms() {
    setState(() {
      _alarms = AlarmStorage.getAll()
        ..sort((a, b) {
          final aNext = a.nextRingDate();
          final bNext = b.nextRingDate();
          if (aNext == null) return 1;
          if (bNext == null) return -1;
          return aNext.compareTo(bNext);
        });
    });
  }

  Future<void> _toggleAlarm(AlarmModel alarm) async {
    alarm.isEnabled = !alarm.isEnabled;
    await AlarmStorage.save(alarm);
    if (alarm.isEnabled) {
      await AlarmScheduler.scheduleAlarm(alarm);
    } else {
      await AlarmScheduler.cancelAlarm(alarm);
    }
    _loadAlarms();
  }

  Future<void> _deleteAlarm(AlarmModel alarm) async {
    await AlarmScheduler.cancelAlarm(alarm);
    await AlarmStorage.delete(alarm.id);
    _loadAlarms();
  }

  void _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditAlarmScreen()),
    );
    _loadAlarms();
  }

  void _openEdit(AlarmModel alarm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CreateEditAlarmScreen(existing: alarm)),
    );
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cycle Alarm'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              DateFormat('EEE, MMM d').format(DateTime.now()),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: _alarms.isEmpty ? _buildEmpty() : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Alarm'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_add,
              size: 80, color: AppTheme.accent.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No alarms yet',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Tap + to create your first cycle alarm',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _alarms.length,
      itemBuilder: (context, i) => _AlarmCard(
        alarm: _alarms[i],
        onToggle: () => _toggleAlarm(_alarms[i]),
        onEdit: () => _openEdit(_alarms[i]),
        onDelete: () => _deleteAlarm(_alarms[i]),
      ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlarmCard({
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nextRing = alarm.nextRingDate();
    final nextStr = nextRing != null
        ? DateFormat('EEE, MMM d').format(nextRing)
        : 'No upcoming ring';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarm.label.isEmpty ? 'Alarm' : alarm.label,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alarm.timeString,
                            style: TextStyle(
                              color: alarm.isEnabled
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                              fontSize: 44,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: alarm.isEnabled, onChanged: (_) => onToggle()),
                  ],
                ),
                const SizedBox(height: 8),
                _CycleVisualizer(alarm: alarm),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.event,
                        size: 13, color: AppTheme.accent.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      alarm.isEnabled ? 'Next: $nextStr' : 'Alarm off',
                      style: TextStyle(
                        color: alarm.isEnabled
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alarm.cycleDescription,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: AppTheme.danger),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual dots showing the ON/OFF cycle pattern
class _CycleVisualizer extends StatelessWidget {
  final AlarmModel alarm;
  const _CycleVisualizer({required this.alarm});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayPos = alarm.cyclePositionFor(today);

    return Row(
      children: List.generate(alarm.cycleTotalDays, (i) {
        final isOn = i < alarm.cycleOnDays;
        final isCurrent = i == todayPos;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isOn
                ? AppTheme.onDay.withOpacity(isCurrent ? 1 : 0.4)
                : AppTheme.offDay.withOpacity(isCurrent ? 0.8 : 0.3),
            borderRadius: BorderRadius.circular(6),
            border: isCurrent
                ? Border.all(color: AppTheme.accentSecondary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color: isOn ? Colors.white : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight:
                    isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}
