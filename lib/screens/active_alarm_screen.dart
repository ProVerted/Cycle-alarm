import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';

import '../models/alarm_model.dart';
import '../services/alarm_scheduler.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class ActiveAlarmScreen extends StatefulWidget {
  final AlarmModel alarm;
  const ActiveAlarmScreen({super.key, required this.alarm});

  @override
  State<ActiveAlarmScreen> createState() => _ActiveAlarmScreenState();
}

class _ActiveAlarmScreenState extends State<ActiveAlarmScreen>
    with TickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _pulseController;
  late AnimationController _ringController;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _clockTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));

    _startAudio();
    _startVibration();
  }

  Future<void> _startAudio() async {
    _player = AudioPlayer();
    try {
      if (widget.alarm.audioPath != null) {
        await _player.setFilePath(widget.alarm.audioPath!);
      } else {
        // Fallback: use a bundled asset if no file chosen
        await _player.setAsset('assets/sounds/default_alarm.mp3');
      }
      _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (_) {
      // Ignore audio errors gracefully
    }
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        pattern: [0, 500, 300, 500, 300, 1000],
        repeat: 0,
      );
    }
  }

  Future<void> _dismiss() async {
    await _stopAll();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _snooze() async {
    await _stopAll();
    await AlarmScheduler.snooze(widget.alarm);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Snoozed for ${widget.alarm.snoozeDurationMinutes} minutes'),
          backgroundColor: AppTheme.surface,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _stopAll() async {
    await _player.stop();
    await _player.dispose();
    Vibration.cancel();
    final intId = widget.alarm.id.hashCode.abs() % 100000;
    await NotificationService.cancelNotification(intId);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _clockTimer?.cancel();
    _player.dispose();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // prevent back button
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Date
              Text(
                DateFormat('EEEE, MMMM d').format(_now),
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              // Live clock
              Text(
                DateFormat('HH:mm').format(_now),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 80,
                  fontWeight: FontWeight.w100,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(height: 4),

              // Alarm label
              Text(
                widget.alarm.label.isEmpty ? 'Alarm' : widget.alarm.label,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 48),

              // Animated bell icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.15),
                  child: AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) => Transform.rotate(
                      angle: (_ringController.value - 0.5) * 0.3,
                      child: Icon(
                        Icons.notifications_active,
                        size: 100,
                        color: AppTheme.accent
                            .withOpacity(0.7 + _pulseController.value * 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Cycle info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  widget.alarm.cycleDescription,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Snooze + Dismiss buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    // Snooze
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _snooze,
                        icon: const Icon(Icons.snooze, color: AppTheme.accent),
                        label: Text(
                          'SNOOZE\n${widget.alarm.snoozeDurationMinutes}m',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.accent, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: AppTheme.accent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Dismiss
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _dismiss,
                        icon: const Icon(Icons.alarm_off, color: Colors.white),
                        label: const Text(
                          'DISMISS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danger,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
