import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Service to manage desktop window state, specifically overlay and kiosk mode
/// for reminders, including native Wayland / Hyprland compatibility on Linux.
class WindowService {
  static final WindowService _instance = WindowService._internal();

  /// Factory constructor providing a singleton instance of [WindowService].
  factory WindowService() => _instance;

  WindowService._internal();

  /// Checks if running on Linux platform.
  bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Checks if the current environment is running Hyprland or has `hyprctl` available.
  Future<bool> isHyprlandAvailable() async {
    if (!isLinux) return false;

    if (Platform.environment.containsKey('HYPRLAND_INSTANCE_SIGNATURE')) {
      return true;
    }

    try {
      final result = await Process.run('which', ['hyprctl']);
      if (result.exitCode == 0) {
        return true;
      }
    } catch (_) {
      // 'which' check failed or unavailable
    }

    try {
      final result = await Process.run('hyprctl', ['version']);
      if (result.exitCode == 0) {
        return true;
      }
    } catch (_) {
      // hyprctl check failed
    }

    return false;
  }

  /// Puts the application window in overlay/fullscreen mode.
  ///
  /// Calls `windowManager` to show, restore, focus, set always-on-top, and make full screen.
  /// On Linux under Hyprland, executes `hyprctl` to focus the window class and superimpose it
  /// over the active workspace.
  Future<void> enterOverlayMode() async {
    try {
      await windowManager.show();
      await windowManager.restore();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setFullScreen(true);
    } catch (e) {
      debugPrint('WindowService: Error configuring windowManager for overlay: $e');
    }

    if (await isHyprlandAvailable()) {
      try {
        await Process.run('hyprctl', ['dispatch', 'focuswindow', 'class:concepts_reminder']);
        await Process.run('hyprctl', ['dispatch', 'fullscreen', '1']);
      } catch (e) {
        debugPrint('WindowService: Error executing hyprctl commands on enterOverlayMode: $e');
      }
    }
  }

  /// Exits overlay mode, resetting full screen and always-on-top flags.
  ///
  /// On Linux under Hyprland, runs `hyprctl dispatch fullscreen 0`.
  Future<void> exitOverlayMode() async {
    try {
      await windowManager.setFullScreen(false);
      await windowManager.setAlwaysOnTop(false);
    } catch (e) {
      debugPrint('WindowService: Error resetting windowManager after overlay: $e');
    }

    if (await isHyprlandAvailable()) {
      try {
        await Process.run('hyprctl', ['dispatch', 'fullscreen', '0']);
      } catch (e) {
        debugPrint('WindowService: Error executing hyprctl commands on exitOverlayMode: $e');
      }
    }
  }
}
