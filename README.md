# ⏰ Cycle Alarm

A cycle-based pattern alarm clock for Android, built with Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 💡 Overview

Standard mobile alarm clocks force you into a weekly calendar routine (e.g. *“Every Monday, Wednesday, Friday”*). For **shift workers, healthcare professionals, rotating rosters, workout routines, and multi-day study splits**, life does not run on a simple 7-day repeat.

**Cycle Alarm** solves this by letting you define repeating **$N$-day cycles**:
* Example: **3 days ON, 1 day OFF**, repeat indefinitely.
* Example: **4 days ON, 2 days OFF**, repeat indefinitely.

You choose when the cycle starts, how weekends are handled, custom ringtones, and snooze intervals.

---

## ✨ Features

- 🔄 **Custom Cycle Patterns**: Define total cycle length ($N$) and active ringing days ($K$).
- 📅 **Flexible Weekend Rules**:
  - **Skip ringing on weekends**: Alarm stays quiet on Saturday and Sunday.
  - **Count vs. Pause weekends**:
    - *Count toward cycle*: Weekends advance the cycle counter (rings resume when the cycle hits weekday ON days).
    - *Pause cycle*: Saturday and Sunday freeze the cycle, resuming on Monday.
- 📆 **Custom Day 1 Reference Date**: Pick any past or future date as Day 1 of the cycle.
- 🎵 **Custom Ringtone Support**: Choose your own audio file from device storage via file picker.
- 💤 **Customizable Snooze**: Quick snooze presets (5, 10, 15, or 20 minutes).
- 📱 **Full-Screen Alarm Experience**: Wake-screen alarm with animated bell, pulsating visual cues, and haptic vibration pattern.
- 🔔 **Android Exact Alarms & Reboot Persistence**:
  - Uses native Android `AlarmManager` exact wakeup alarms.
  - Alarms automatically reschedule upon device reboot (`RECEIVE_BOOT_COMPLETED`).
- 🌙 **Modern Dark UI**: OLED-friendly dark theme with visual cycle tracking pills.
- ⚡ **Offline & Fast**: Powered by Hive local embedded NoSQL storage — no internet required.

---

## 🛠️ Architecture & Tech Stack

```
cycle_alarm/
├── android/                        # Android native configurations & manifests
│   └── app/src/main/
│       └── AndroidManifest.xml     # Alarm, boot, notification, and wakelock permissions
├── lib/
│   ├── main.dart                   # Application entry point & service initialization
│   ├── models/
│   │   ├── alarm_model.dart        # Core alarm entity & cycle calculation algorithms
│   │   └── alarm_model.g.dart      # Generated Hive type adapter
│   ├── services/
│   │   ├── alarm_storage.dart      # Hive local database repository
│   │   ├── alarm_scheduler.dart    # AndroidAlarmManager scheduling & background isolate callback
│   │   └── notification_service.dart # Notification channels & cancellation handling
│   ├── screens/
│   │   ├── home_screen.dart        # Alarm dashboard with cycle visualizers
│   │   ├── create_edit_alarm_screen.dart # Alarm configuration & pattern builder
│   │   └── active_alarm_screen.dart # Fullscreen ringing interface with snooze/dismiss
│   └── utils/
│       └── app_theme.dart          # Colors, typography, and Material 3 theme data
├── pubspec.yaml                    # Project dependencies
└── SETUP_GUIDE.md                  # Step-by-step setup and build guide
```

### Key Libraries

* **Local Storage**: [`hive`](https://pub.dev/packages/hive) & [`hive_flutter`](https://pub.dev/packages/hive_flutter)
* **Background Scheduling**: [`android_alarm_manager_plus`](https://pub.dev/packages/android_alarm_manager_plus)
* **Notifications**: [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)
* **Audio & Vibrations**: [`just_audio`](https://pub.dev/packages/just_audio) & [`vibration`](https://pub.dev/packages/vibration)
* **File Picker**: [`file_picker`](https://pub.dev/packages/file_picker)

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.0.0`)
* [Android Studio](https://developer.android.com/studio) or Android SDK (API level 21+)
* Physical Android device or Android Emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ProVerted/Cycle-alarm.git
   cd Cycle-alarm
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on a connected device:**
   ```bash
   flutter run
   ```

4. **Build release APK:**
   ```bash
   flutter build apk --release
   ```
   The generated APK will be available at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

For a detailed step-by-step walkthrough, refer to [SETUP_GUIDE.md](SETUP_GUIDE.md).

---

## 🔒 Permissions Used

Cycle Alarm requires standard Android alarm and notification permissions:
* `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`: Ensures the alarm fires with second-level precision.
* `WAKE_LOCK`: Wakes the screen when the alarm fires.
* `RECEIVE_BOOT_COMPLETED`: Automatically re-schedules pending alarms when the phone restarts.
* `POST_NOTIFICATIONS`: Displays alarm banners and status notifications on Android 13+.
* `USE_FULL_SCREEN_INTENT`: Launches the full-screen alarm overlay even when locked.
* `VIBRATE`: Triggers haptic pulse patterns while ringing.
* `READ_EXTERNAL_STORAGE` / `READ_MEDIA_AUDIO`: Allows picking custom alarm tones from device storage.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
