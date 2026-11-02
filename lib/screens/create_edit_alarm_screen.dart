import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/alarm_model.dart';
import '../services/alarm_scheduler.dart';
import '../services/alarm_storage.dart';
import '../utils/app_theme.dart';

class CreateEditAlarmScreen extends StatefulWidget {
  final AlarmModel? existing;
  const CreateEditAlarmScreen({super.key, this.existing});

  @override
  State<CreateEditAlarmScreen> createState() =>
      _CreateEditAlarmScreenState();
}

class _CreateEditAlarmScreenState extends State<CreateEditAlarmScreen> {
  late TextEditingController _labelCtrl;
  late int _hour;
  late int _minute;
  late int _cycleTotalDays;
  late int _cycleOnDays;
  late bool _skipWeekends;
  late bool _weekendsCountTowardCycle;
  late DateTime _startDate;
  late int _snoozeDuration;
  String? _audioPath;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _hour = e?.hour ?? 7;
    _minute = e?.minute ?? 0;
    _cycleTotalDays = e?.cycleTotalDays ?? 4;
    _cycleOnDays = e?.cycleOnDays ?? 3;
    _skipWeekends = e?.skipWeekends ?? true;
    _weekendsCountTowardCycle = e?.weekendsCountTowardCycle ?? true;
    _startDate = e?.cycleStartDate ?? DateTime.now();
    _snoozeDuration = e?.snoozeDurationMinutes ?? 10;
    _audioPath = e?.audioPath;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _audioPath = result.files.single.path);
    }
  }

  Future<void> _save() async {
    if (_cycleOnDays > _cycleTotalDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ON days cannot exceed total cycle days')),
      );
      return;
    }

    final alarm = AlarmModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      label: _labelCtrl.text.trim().isEmpty ? 'Alarm' : _labelCtrl.text.trim(),
      hour: _hour,
      minute: _minute,
      cycleTotalDays: _cycleTotalDays,
      cycleOnDays: _cycleOnDays,
      isEnabled: _isEditing ? widget.existing!.isEnabled : true,
      skipWeekends: _skipWeekends,
      weekendsCountTowardCycle: _weekendsCountTowardCycle,
      cycleStartDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
      audioPath: _audioPath,
      snoozeDurationMinutes: _snoozeDuration,
    );

    await AlarmStorage.save(alarm);
    await AlarmScheduler.scheduleAlarm(alarm);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Alarm' : 'New Alarm'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE',
                style: TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Time picker ──────────────────────────────────────────────
          _Section(
            child: GestureDetector(
              onTap: _pickTime,
              child: Center(
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 72,
                    fontWeight: FontWeight.w100,
                    letterSpacing: -3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Label ────────────────────────────────────────────────────
          _Section(
            child: TextField(
              controller: _labelCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
                prefixIcon:
                    Icon(Icons.label_outline, color: AppTheme.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Cycle configuration ──────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Cycle Pattern'),
                const SizedBox(height: 12),
                _NumberStepper(
                  label: 'Total days in cycle',
                  value: _cycleTotalDays,
                  min: 2,
                  max: 30,
                  onChanged: (v) => setState(() {
                    _cycleTotalDays = v;
                    if (_cycleOnDays > v) _cycleOnDays = v - 1;
                  }),
                ),
                const SizedBox(height: 12),
                _NumberStepper(
                  label: 'Days alarm is ON',
                  value: _cycleOnDays,
                  min: 1,
                  max: _cycleTotalDays - 1,
                  onChanged: (v) => setState(() => _cycleOnDays = v),
                ),
                const SizedBox(height: 16),
                _CyclePreview(
                    total: _cycleTotalDays, on: _cycleOnDays),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Weekend settings ─────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Weekend Behaviour'),
                _SwitchRow(
                  label: 'Skip ringing on weekends',
                  subtitle: 'Alarm won\'t ring on Sat & Sun',
                  value: _skipWeekends,
                  onChanged: (v) => setState(() => _skipWeekends = v),
                ),
                if (_skipWeekends) ...[
                  const Divider(color: AppTheme.cardBorder),
                  _SwitchRow(
                    label: 'Weekends count toward cycle',
                    subtitle: _weekendsCountTowardCycle
                        ? 'Sat & Sun advance the day counter (alarm just won\'t ring)'
                        : 'Sat & Sun are ignored — cycle only advances on weekdays',
                    value: _weekendsCountTowardCycle,
                    onChanged: (v) =>
                        setState(() => _weekendsCountTowardCycle = v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Start date ───────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Cycle Start Date'),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Day 1 = ${DateFormat('EEE, MMM d, yyyy').format(_startDate)}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(
                          () => _startDate = DateTime.now()),
                      child: const Text('Today',
                          style: TextStyle(color: AppTheme.accent)),
                    ),
                    TextButton(
                      onPressed: _pickStartDate,
                      child: const Text('Pick date',
                          style: TextStyle(color: AppTheme.accent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Snooze ───────────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Snooze Duration'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [5, 10, 15, 20].map((min) {
                    final selected = _snoozeDuration == min;
                    return GestureDetector(
                      onTap: () => setState(() => _snoozeDuration = min),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.accent
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.accent
                                : AppTheme.cardBorder,
                          ),
                        ),
                        child: Text(
                          '${min}m',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Audio file ───────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Alarm Sound'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.audiotrack,
                      color: AppTheme.accent),
                  title: Text(
                    _audioPath != null
                        ? _audioPath!.split('/').last
                        : 'No file selected',
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Tap to choose from device',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  onTap: _pickAudio,
                  trailing: _audioPath != null
                      ? GestureDetector(
                          onTap: () => setState(() => _audioPath = null),
                          child: const Icon(Icons.close,
                              color: AppTheme.textSecondary, size: 18),
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── Save button ──────────────────────────────────────────────
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('SAVE ALARM',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title:
            Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
        subtitle:
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        value: value,
        onChanged: onChanged,
      );
}

class _NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15)),
          ),
          _StepBtn(
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$value',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onTap != null
                ? AppTheme.accent.withOpacity(0.15)
                : AppTheme.offDay.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: onTap != null
                  ? AppTheme.accent
                  : AppTheme.textSecondary,
              size: 18),
        ),
      );
}

class _CyclePreview extends StatelessWidget {
  final int total;
  final int on;

  const _CyclePreview({required this.total, required this.on});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PREVIEW',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(total, (i) {
              final isOn = i < on;
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isOn
                      ? AppTheme.accent.withOpacity(0.3)
                      : AppTheme.offDay.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOn ? AppTheme.accent : AppTheme.offDay,
                  ),
                ),
                child: Center(
                  child: Text(
                    isOn ? '🔔' : '🔕',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Rings $on day${on > 1 ? 's' : ''}, silent ${total - on} day${total - on > 1 ? 's' : ''}, then repeats forever',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      );
}
