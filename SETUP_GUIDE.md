# 🔔 Cycle Alarm — Complete Setup Guide
### Your step-by-step guide to building and installing the APK

---

## 📦 STEP 1 — Install Flutter SDK

1. Go to: https://flutter.dev/docs/get-started/install
2. Choose **Windows** (or Mac/Linux if that's your computer)
3. Download the `.zip` file and **extract** it to `C:\flutter` (Windows) or `~/flutter` (Mac/Linux)
4. Add Flutter to your PATH:
   - **Windows:** Search "Environment Variables" → Edit `PATH` → Add `C:\flutter\bin`
   - **Mac/Linux:** Add `export PATH="$PATH:$HOME/flutter/bin"` to your `~/.bashrc` or `~/.zshrc`
5. Open a **new terminal** and type:
   ```
   flutter --version
   ```
   You should see a version number. ✅

---

## 🤖 STEP 2 — Install Android Studio

1. Download from: https://developer.android.com/studio
2. Run the installer — use all default settings
3. When it opens, click **"More Actions" → SDK Manager**
4. Under **SDK Platforms**, check: `Android 14 (API 34)` and `Android 5.0 (API 21)`
5. Under **SDK Tools**, check:
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools
6. Click **Apply** and let it download

---

## 📱 STEP 3 — Set Up Your Android Phone

Since you want this on YOUR phone (not an emulator):

1. On your Android phone, go to **Settings → About Phone**
2. Tap **"Build Number"** 7 times rapidly — you'll see "Developer mode enabled"
3. Go back to **Settings → Developer Options**
4. Enable **"USB Debugging"** ✅
5. Connect your phone to your computer with a USB cable
6. On your phone, a popup will ask "Allow USB Debugging?" — tap **Allow**
7. In your terminal, type:
   ```
   flutter devices
   ```
   Your phone should appear in the list ✅

---

## 📁 STEP 4 — Get the Project Files

1. Create a folder called `cycle_alarm` somewhere on your computer (e.g. `C:\Projects\cycle_alarm`)
2. Copy ALL the files I gave you into that folder, maintaining the folder structure:
   ```
   cycle_alarm/
   ├── pubspec.yaml
   ├── lib/
   │   ├── main.dart
   │   ├── models/
   │   │   ├── alarm_model.dart
   │   │   └── alarm_model.g.dart
   │   ├── services/
   │   │   ├── alarm_storage.dart
   │   │   ├── alarm_scheduler.dart
   │   │   └── notification_service.dart
   │   ├── screens/
   │   │   ├── home_screen.dart
   │   │   ├── create_edit_alarm_screen.dart
   │   │   └── active_alarm_screen.dart
   │   └── utils/
   │       └── app_theme.dart
   └── android/
       ├── build.gradle
       ├── settings.gradle
       ├── gradle.properties
       └── app/
           ├── build.gradle
           └── src/main/
               └── AndroidManifest.xml
   ```

---

## 🔧 STEP 5 — Open Terminal in Project Folder

1. Open your terminal / command prompt
2. Navigate to the project:
   ```
   cd C:\Projects\cycle_alarm
   ```
   (or wherever you put it)

---

## 📥 STEP 6 — Install Dependencies

Run this command:
```
flutter pub get
```
This downloads all the packages listed in `pubspec.yaml`. Wait for it to complete ✅

---

## ✅ STEP 7 — Check Everything is OK

Run:
```
flutter doctor
```
This checks your setup. Don't worry if you see ⚠️ for Xcode (that's for iPhone, we don't need it). You just need the Android items to show ✅.

---

## 🔨 STEP 8 — Build the APK

Run:
```
flutter build apk --release
```
This compiles the app into an `.apk` file. It may take 3-5 minutes the first time.

When done, your APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 STEP 9 — Install on Your Phone

**Option A — Via USB (easiest):**
```
flutter install
```
This installs directly to your connected phone.

**Option B — Copy the APK:**
1. Copy `app-release.apk` to your phone (via USB, Google Drive, email, etc.)
2. On your phone, go to **Settings → Security → Install Unknown Apps**
3. Enable it for your file manager / browser
4. Tap the `.apk` file on your phone and install it

---

## ⚠️ STEP 10 — Grant Permissions on First Launch

When the app opens for the first time, it will ask for:
- **Notification permission** — tap Allow ✅
- **Exact Alarm permission** — tap Allow ✅ (Android 12+)
- **Schedule Exact Alarm** — In Settings, find "Cycle Alarm" and enable "Alarms & Reminders"

---

## 🎵 STEP 11 — Add Your Audio File

When creating an alarm, tap **"Choose from device"** under Alarm Sound, and pick any `.mp3` or `.ogg` file from your phone's storage.

---

## 🆘 Common Issues & Fixes

| Problem | Fix |
|---|---|
| `flutter: command not found` | PATH not set correctly — redo Step 1 |
| Phone not showing in `flutter devices` | Re-plug USB, re-allow USB debugging |
| Build fails with SDK error | Re-run `flutter doctor`, install missing SDK items |
| App installed but alarms don't fire | Grant "Alarms & Reminders" permission in phone settings |
| No sound on alarm | Check phone isn't in silent mode; pick an audio file in alarm settings |

---

## 💬 Need Help?

If you hit any errors, copy the full error message and share it — I'll help you fix it! 💙
