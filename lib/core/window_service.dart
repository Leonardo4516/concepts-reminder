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
  /// On Linux under Hyprland, executes `hyprctl eval` to move the window to the active workspace,
  /// bring it to top, focus it, and ensure fullscreen coverage.
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
        const enterScript = '''
local active_ws = hl.get_active_workspace()
local ws_id = active_ws and active_ws.id or 1
local wins = hl.get_windows()
for _, w in ipairs(wins) do
  local c = w.class or ""
  local t = w.title or ""
  if string.find(c, "concepts_reminder") or string.find(t, "concepts_reminder") then
    local target = "address:" .. tostring(w.address)
    hl.dsp.window.move({ workspace = ws_id, window = target })
    hl.dsp.focus({ window = target })
    hl.dsp.window.bring_to_top({ window = target })
    if w.fullscreen == 0 then
      hl.dsp.window.fullscreen()
    end
    return "OK"
  end
end
return "NOT_FOUND"
''';
        final res = await Process.run('hyprctl', ['eval', enterScript]);
        if (res.exitCode != 0) {
          debugPrint('WindowService: hyprctl eval failed with exit code \${res.exitCode}: \${res.stderr}');
        }
      } catch (e) {
        debugPrint('WindowService: Error executing hyprctl eval on enterOverlayMode: $e');
      }
    }
  }

  /// Exits overlay mode, restoring window state and toggling off Hyprland fullscreen if needed.
  Future<void> exitOverlayMode() async {
    try {
      await windowManager.setFullScreen(false);
      await windowManager.setAlwaysOnTop(false);
    } catch (e) {
      debugPrint('WindowService: Error resetting windowManager after overlay: $e');
    }

    if (await isHyprlandAvailable()) {
      try {
        const exitScript = '''
local wins = hl.get_windows()
for _, w in ipairs(wins) do
  local c = w.class or ""
  local t = w.title or ""
  if string.find(c, "concepts_reminder") or string.find(t, "concepts_reminder") then
    local target = "address:" .. tostring(w.address)
    if w.fullscreen ~= 0 then
      hl.dsp.focus({ window = target })
      hl.dsp.window.fullscreen()
    end
    return "OK"
  end
end
return "NOT_FOUND"
''';
        final res = await Process.run('hyprctl', ['eval', exitScript]);
        if (res.exitCode != 0) {
          debugPrint('WindowService: hyprctl eval exit failed with exit code \${res.exitCode}: \${res.stderr}');
        }
      } catch (e) {
        debugPrint('WindowService: Error executing hyprctl eval on exitOverlayMode: $e');
      }
    }
  }
}
