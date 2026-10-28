import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'models.dart';

/// Browser notifications. Works while the tab or installed PWA is open.
/// Web apps cannot fire notifications when fully closed without a push
/// server, so the Settings screen tells the user to keep the PWA pinned.
class Reminders {
  Reminders._();
  static final Reminders instance = Reminders._();

  Timer? _timer;
  final Set<String> _firedToday = {};
  String _firedDay = '';

  bool get supported {
    try {
      return globalContext.getProperty('Notification'.toJS).isDefinedAndNotNull;
    } catch (_) {
      return false;
    }
  }

  String get permission {
    if (!supported) return 'unsupported';
    try {
      return web.Notification.permission;
    } catch (_) {
      return 'unsupported';
    }
  }

  Future<String> requestPermission() async {
    if (!supported) return 'unsupported';
    try {
      final result = await web.Notification.requestPermission().toDart;
      return result.toDart;
    } catch (e) {
      debugPrint('permission request failed: $e');
      return 'denied';
    }
  }

  void show(String title, String body) {
    if (permission != 'granted') return;
    try {
      web.Notification(title, web.NotificationOptions(body: body, icon: 'icons/Icon-192.png'));
    } catch (e) {
      debugPrint('notification failed: $e');
    }
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
    _tick();
  }

  void _tick() {
    final s = AppState.instance;
    if (!s.remindersOn || permission != 'granted') return;
    final now = DateTime.now();
    final key = dayKey(now);
    if (key != _firedDay) {
      _firedDay = key;
      _firedToday.clear();
    }
    final log = s.todayLog;

    void fire(String id, int h, int m, String title, String body) {
      if (_firedToday.contains(id)) return;
      final due = DateTime(now.year, now.month, now.day, h, m);
      // Fire within a 10-minute window after the due time so a late-opened
      // tab still gets it, but not hours later.
      if (now.isAfter(due) && now.difference(due).inMinutes < 10) {
        _firedToday.add(id);
        show(title, body);
      }
    }

    if (!log.done.contains(Habit.meditate)) {
      fire('morning', s.morningHour, s.morningMinute, 'Floor time',
          'One breath, eyes closed. Then 10 squats, 10 push-ups. 90 seconds.');
    }
    if (!log.done.contains(Habit.build)) {
      final task = s.todaysBuildTask;
      fire('build', s.buildHour, s.buildMinute, 'Build: 15 minutes',
          task.isEmpty ? 'Open the Build profile. Timer on.' : task);
    }
    if (!log.done.contains(Habit.nextAction)) {
      fire('evening', s.eveningHour, s.eveningMinute, 'Write tomorrow\'s line',
          'One line only. Then the phone goes outside the bedroom.');
    }
    // Sunday review nudge at 18:00.
    if (now.weekday == DateTime.sunday) {
      fire('review', 18, 0, 'Weekly review', 'Four questions. Ten minutes. Nothing else.');
    }
  }
}
