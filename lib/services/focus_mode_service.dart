import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymon/models/app_block_target.dart';

class FocusModeService {
  FocusModeService._();

  static final FocusModeService instance = FocusModeService._();

  static const MethodChannel _channel = MethodChannel('studymon/focus_mode');
  static const String _prefsKey = 'focus_blocked_packages_v1';

  static const List<AppBlockTarget> defaultTargets = <AppBlockTarget>[
    AppBlockTarget(label: 'Instagram', packageName: 'com.instagram.android'),
    AppBlockTarget(label: 'YouTube', packageName: 'com.google.android.youtube'),
    AppBlockTarget(label: 'TikTok', packageName: 'com.zhiliaoapp.musically'),
    AppBlockTarget(label: 'X', packageName: 'com.twitter.android'),
    AppBlockTarget(label: 'Facebook', packageName: 'com.facebook.katana'),
  ];

  Future<List<String>> loadBlockedPackages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ??
        defaultTargets.map((target) => target.packageName).toList();
  }

  Future<void> saveBlockedPackages(List<String> packages) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, packages);
  }

  bool get isSupported => Platform.isAndroid;

  Future<bool> hasUsagePermission() async {
    if (!isSupported) {
      return false;
    }

    final bool? result = await _channel.invokeMethod<bool>(
      'hasUsageStatsPermission',
    );
    return result ?? false;
  }

  Future<void> openUsageAccessSettings() async {
    if (!isSupported) {
      return;
    }

    await _channel.invokeMethod<void>('openUsageAccessSettings');
  }

  Future<void> startFocusMode(List<String> blockedPackages) async {
    if (!isSupported) {
      return;
    }

    await _channel.invokeMethod<void>('startFocusMode', <String, Object>{
      'blockedPackages': blockedPackages,
    });
  }

  Future<void> stopFocusMode() async {
    if (!isSupported) {
      return;
    }

    await _channel.invokeMethod<void>('stopFocusMode');
  }

  void setBlockedAppCallback(
    Future<void> Function(String packageName)? callback,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'blockedAppDetected' || callback == null) {
        return;
      }

      final String? packageName = call.arguments is Map
          ? (call.arguments as Map<dynamic, dynamic>)['package'] as String?
          : null;

      if (packageName == null || packageName.isEmpty) {
        return;
      }

      await callback(packageName);
    });
  }
}
