import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Date key in yyyy-MM-dd form.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// The daily floor habits. Order matters for the UI.
enum Habit {
  meditate('Meditate', 'Floor: one breath, eyes closed. Target: 5 min.'),
  floorMove('Movement floor', '10 squats, 10 push-ups. 90 seconds. Never skipped.'),
  walk('Evening walk', '15 min after dinner. Call your partner during it.'),
  protein('Protein anchors', 'Did every roti-dal plate have an anchor? Yes or no.'),
  build('Build 15 min', 'Timer on, Build profile only, stop when it rings.'),
  nextAction('Wrote tomorrow\'s line', 'One line before 10 PM: "Tomorrow\'s 15 minutes is ___".');

  const Habit(this.label, this.hint);
  final String label;
  final String hint;
}

/// One day of logged habits.
class DayLog {
  DayLog({Set<Habit>? done, this.nextAction = '', this.workout20 = false})
    : done = done ?? {};

  final Set<Habit> done;
  String nextAction;
  bool workout20;

  Map<String, dynamic> toJson() => {
    'done': done.map((h) => h.name).toList(),
    'next': nextAction,
    'w20': workout20,
  };

  static DayLog fromJson(Map<String, dynamic> j) => DayLog(
    done: ((j['done'] as List?) ?? [])
        .map((n) => Habit.values.firstWhere((h) => h.name == n))
        .toSet(),
    nextAction: (j['next'] as String?) ?? '',
    workout20: (j['w20'] as bool?) ?? false,
  );
}

class WeightEntry {
  WeightEntry(this.date, this.kg);
  final DateTime date;
  final double kg;
  Map<String, dynamic> toJson() => {'d': dayKey(date), 'kg': kg};
  static WeightEntry fromJson(Map<String, dynamic> j) =>
      WeightEntry(DateTime.parse(j['d'] as String), (j['kg'] as num).toDouble());
}

/// One escape the user walks through the Pause Gate to reach.
class Escape {
  const Escape(this.id, this.label, this.url, this.waitSeconds);
  final String id;
  final String label;
  final String url;
  final int waitSeconds;
}

const escapes = [
  Escape('yt', 'YouTube', 'https://m.youtube.com/feed/subscriptions', 45),
  Escape('reddit', 'Reddit', 'https://www.reddit.com', 45),
  Escape('insta', 'Instagram', 'https://www.instagram.com', 60),
  Escape('game', 'Gaming session', '', 90),
];

class GateEvent {
  GateEvent(this.at, this.escapeId, this.wentThrough, this.reason);
  final DateTime at;
  final String escapeId;
  final bool wentThrough;
  final String reason;
  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'e': escapeId,
    'go': wentThrough,
    'r': reason,
  };
  static GateEvent fromJson(Map<String, dynamic> j) => GateEvent(
    DateTime.parse(j['at'] as String),
    j['e'] as String,
    j['go'] as bool,
    (j['r'] as String?) ?? '',
  );
}

/// A one-time friction setup step, with an optional link to the tool.
class FrictionStep {
  const FrictionStep(this.id, this.title, this.detail, {this.url});
  final String id;
  final String title;
  final String detail;
  final String? url;
}

const frictionSteps = [
  FrictionStep(
    'yt_logout',
    'Log out of YouTube everywhere',
    'No history, no recommendations, no autoplay. Delete the mobile app, use the browser.',
    url: 'https://www.youtube.com/logout',
  ),
  FrictionStep(
    'yt_unhook',
    'Install Unhook on desktop browser',
    'Kills home feed, sidebar and end-screen suggestions.',
    url: 'https://unhook.app/',
  ),
  FrictionStep(
    'cold_turkey',
    'Cold Turkey: 30-second wait screen on youtube.com',
    'A delay, not a wall. Walls get torn down at midnight.',
    url: 'https://getcoldturkey.com/',
  ),
  FrictionStep(
    'game_uninstall',
    'Move game installers to external drive, uninstall launchers',
    'A 20-minute reinstall breaks the impulse. Controller goes in a drawer in another room.',
  ),
  FrictionStep(
    'dns',
    'NextDNS or CleanBrowsing with adult category blocked',
    'Set the password by typing random characters you do not look at. Seal it in an envelope.',
    url: 'https://my.nextdns.io/',
  ),
  FrictionStep(
    'grayscale',
    'Phone grayscale 10 PM to 8 AM',
    'Android: Digital Wellbeing > Bedtime mode. iPhone: Shortcuts automation on Color Filters.',
  ),
  FrictionStep(
    'charge_outside',
    'Phone charges outside the bedroom',
    'This single move kills most midnight planning sessions.',
  ),
  FrictionStep(
    'build_profile',
    'Create a browser profile called Build',
    'Only the tabs you need. Pin this app in it.',
  ),
  FrictionStep(
    'clothes',
    'Workout clothes on the floor where you step out of bed',
    'Shoes by the door.',
  ),
];

/// Side-hustle scaffolding: 6 weeks, 7 micro-actions each.
class HustleWeek {
  const HustleWeek(this.title, this.goal, this.days);
  final String title;
  final String goal;
  final List<String> days;
}

const hustleWeeks = [
  HustleWeek('Week 1: Inventory', 'Collect 21 raw data points about what you could sell.', [
    'Write 3 skills you already have from work.',
    'Write 3 problems you have solved for yourself.',
    'Write 3 things people ask you for help with.',
    'Write 3 topics you read about for fun.',
    'Write 3 tools or workflows you know better than most.',
    'Write 3 things you would do for free.',
    'Reread all 18 lines. Star the 5 that felt alive.',
  ]),
  HustleWeek('Week 2: Market scan', 'Does anyone pay for this? One real listing a day.', [
    'Pick starred item 1. Search Upwork for it. Note one listing.',
    'Pick starred item 2. Search Fiverr. Note one gig and its price.',
    'Pick starred item 3. Find one Reddit post asking for it.',
    'Pick starred item 4. Search LinkedIn posts. Note one.',
    'Pick starred item 5. Search Upwork or Fiverr. Note one.',
    'Find one person already selling your top item. Note their price.',
    'Write one line: which item had the most paying demand?',
  ]),
  HustleWeek('Week 3: Pick one', 'Choose a direction. Reversible in 90 days.', [
    'Shortlist 3 options from your notes.',
    'Option A: write what a first paid gig looks like.',
    'Option B: write what a first paid gig looks like.',
    'Option C: write what a first paid gig looks like.',
    'Write the biggest fear about each in one line.',
    'Write which one you would be least embarrassed to tell a friend about.',
    'Pick one. Write it at the top of your Next Action file.',
  ]),
  HustleWeek('Week 4: First artifact', 'One rough proof of work. Rough is the standard.', [
    'Decide the artifact: one-pager, template, sample audit, or guide.',
    'Write the title and 3 bullet outline.',
    'Fill section 1.',
    'Fill section 2.',
    'Fill section 3.',
    'Read it once, fix only typos.',
    'Export or publish it somewhere with a link.',
  ]),
  HustleWeek('Week 5: First contact', 'Seven sent. Replies are not the metric.', [
    'Reply helpfully to one Reddit post in your niche.',
    'Send one Upwork proposal.',
    'Send one LinkedIn DM offering your artifact for free feedback.',
    'Reply helpfully to one Reddit or forum post.',
    'Send one Upwork or Fiverr message.',
    'Message one person you already know who might need this.',
    'Post your artifact publicly in one place.',
  ]),
  HustleWeek('Week 6: Review', 'Decide: continue, or rerun Week 3 with a new pick.', [
    'Reread Week 1 and 2 notes.',
    'Count replies received. Write the number.',
    'Write what felt tolerable and what felt awful.',
    'Write what one paying client would need from you next.',
    'Decide: continue or re-pick.',
    'If continue: write the next 7 micro-actions.',
    'If re-pick: reopen Week 3, day 1.',
  ]),
];

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final Map<String, DayLog> logs = {};
  final List<WeightEntry> weights = [];
  final List<GateEvent> gateEvents = [];
  final Set<String> frictionDone = {};
  final Set<String> hustleDone = {}; // "w{week}d{day}"
  final Map<String, String> hustleNotes = {}; // "w{week}d{day}" -> note
  final Map<String, String> reviews = {}; // week key -> JSON of 4 answers
  bool remindersOn = false;
  int morningHour = 7, morningMinute = 30;
  int eveningHour = 21, eveningMinute = 30;
  int buildHour = 19, buildMinute = 0;
  bool loaded = false;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('phase_one_state');
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        (j['logs'] as Map<String, dynamic>? ?? {}).forEach(
          (k, v) => logs[k] = DayLog.fromJson(v as Map<String, dynamic>),
        );
        weights.addAll(
          ((j['weights'] as List?) ?? []).map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)),
        );
        gateEvents.addAll(
          ((j['gate'] as List?) ?? []).map((e) => GateEvent.fromJson(e as Map<String, dynamic>)),
        );
        frictionDone.addAll(((j['friction'] as List?) ?? []).cast<String>());
        hustleDone.addAll(((j['hustle'] as List?) ?? []).cast<String>());
        (j['hustleNotes'] as Map<String, dynamic>? ?? {}).forEach(
          (k, v) => hustleNotes[k] = v as String,
        );
        (j['reviews'] as Map<String, dynamic>? ?? {}).forEach(
          (k, v) => reviews[k] = v as String,
        );
        remindersOn = (j['remindersOn'] as bool?) ?? false;
        morningHour = (j['mh'] as int?) ?? morningHour;
        morningMinute = (j['mm'] as int?) ?? morningMinute;
        eveningHour = (j['eh'] as int?) ?? eveningHour;
        eveningMinute = (j['em'] as int?) ?? eveningMinute;
        buildHour = (j['bh'] as int?) ?? buildHour;
        buildMinute = (j['bm'] as int?) ?? buildMinute;
      } catch (e) {
        debugPrint('state load failed: $e');
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    notifyListeners();
    final j = {
      'logs': logs.map((k, v) => MapEntry(k, v.toJson())),
      'weights': weights.map((w) => w.toJson()).toList(),
      'gate': gateEvents.map((g) => g.toJson()).toList(),
      'friction': frictionDone.toList(),
      'hustle': hustleDone.toList(),
      'hustleNotes': hustleNotes,
      'reviews': reviews,
      'remindersOn': remindersOn,
      'mh': morningHour,
      'mm': morningMinute,
      'eh': eveningHour,
      'em': eveningMinute,
      'bh': buildHour,
      'bm': buildMinute,
    };
    await _prefs?.setString('phase_one_state', jsonEncode(j));
  }

  String exportJson() => _prefs?.getString('phase_one_state') ?? '{}';

  Future<bool> importJson(String raw) async {
    try {
      jsonDecode(raw) as Map<String, dynamic>;
      await _prefs?.setString('phase_one_state', raw);
      logs.clear();
      weights.clear();
      gateEvents.clear();
      frictionDone.clear();
      hustleDone.clear();
      hustleNotes.clear();
      reviews.clear();
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- habits ----
  DayLog logFor(DateTime d) => logs.putIfAbsent(dayKey(d), DayLog.new);
  DayLog get todayLog => logFor(today());

  void toggleHabit(Habit h, {DateTime? on}) {
    final log = logFor(on ?? today());
    if (!log.done.remove(h)) log.done.add(h);
    _save();
  }

  void setNextAction(String text) {
    todayLog.nextAction = text;
    if (text.trim().isNotEmpty) {
      todayLog.done.add(Habit.nextAction);
    } else {
      todayLog.done.remove(Habit.nextAction);
    }
    _save();
  }

  void toggleWorkout20() {
    todayLog.workout20 = !todayLog.workout20;
    _save();
  }

  /// Yesterday's next action is today's task.
  String get todaysBuildTask {
    final y = today().subtract(const Duration(days: 1));
    return logs[dayKey(y)]?.nextAction ?? '';
  }

  /// Consecutive days (ending today or yesterday) on which [h] was done.
  int streak(Habit h) {
    var d = today();
    var n = 0;
    if (!(logs[dayKey(d)]?.done.contains(h) ?? false)) {
      d = d.subtract(const Duration(days: 1));
    }
    while (logs[dayKey(d)]?.done.contains(h) ?? false) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Did the user miss [h] both yesterday and the day before? That is the
  /// "never miss twice" alarm.
  bool missedTwice(Habit h) {
    final y1 = today().subtract(const Duration(days: 1));
    final y2 = today().subtract(const Duration(days: 2));
    final d1 = logs[dayKey(y1)]?.done.contains(h) ?? false;
    final d2 = logs[dayKey(y2)]?.done.contains(h) ?? false;
    // Only alarm once there is history from before those two days.
    final hasHistory = logs.keys.any((k) => k.compareTo(dayKey(y2)) <= 0);
    return !d1 && !d2 && hasHistory;
  }

  /// Days out of the last 7 (including today) on which [h] was done.
  int lastSeven(Habit h) {
    var n = 0;
    for (var i = 0; i < 7; i++) {
      final d = today().subtract(Duration(days: i));
      if (logs[dayKey(d)]?.done.contains(h) ?? false) n++;
    }
    return n;
  }

  /// Floor habits are the two that are never skipped.
  static const floorHabits = [Habit.meditate, Habit.floorMove];

  /// Count of consecutive past weeks where both floor habits hit 5/7.
  int phaseTwoWeeks() {
    var weeks = 0;
    var end = today();
    while (true) {
      var ok = true;
      for (final h in floorHabits) {
        var n = 0;
        for (var i = 0; i < 7; i++) {
          final d = end.subtract(Duration(days: i));
          if (logs[dayKey(d)]?.done.contains(h) ?? false) n++;
        }
        if (n < 5) ok = false;
      }
      if (!ok) break;
      weeks++;
      end = end.subtract(const Duration(days: 7));
      if (weeks > 52) break;
    }
    return weeks;
  }

  // ---- weight ----
  void addWeight(double kg, {DateTime? on}) {
    final d = on ?? today();
    weights.removeWhere((w) => dayKey(w.date) == dayKey(d));
    weights.add(WeightEntry(d, kg));
    weights.sort((a, b) => a.date.compareTo(b.date));
    _save();
  }

  // ---- gate ----
  void recordGate(Escape e, bool wentThrough, String reason) {
    gateEvents.add(GateEvent(DateTime.now(), e.id, wentThrough, reason));
    if (gateEvents.length > 500) gateEvents.removeRange(0, gateEvents.length - 500);
    _save();
  }

  int gateCount({required bool wentThrough, int days = 7}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return gateEvents.where((g) => g.at.isAfter(since) && g.wentThrough == wentThrough).length;
  }

  // ---- friction ----
  void toggleFriction(String id) {
    if (!frictionDone.remove(id)) frictionDone.add(id);
    _save();
  }

  // ---- hustle ----
  String hustleKey(int w, int d) => 'w${w}d$d';
  void toggleHustle(int w, int d) {
    final k = hustleKey(w, d);
    if (!hustleDone.remove(k)) hustleDone.add(k);
    _save();
  }

  void setHustleNote(int w, int d, String note) {
    hustleNotes[hustleKey(w, d)] = note;
    _save();
  }

  /// First week with an unfinished day, 0-based.
  int get currentHustleWeek {
    for (var w = 0; w < hustleWeeks.length; w++) {
      for (var d = 0; d < 7; d++) {
        if (!hustleDone.contains(hustleKey(w, d))) return w;
      }
    }
    return hustleWeeks.length - 1;
  }

  (int, int)? get nextHustleAction {
    for (var w = 0; w < hustleWeeks.length; w++) {
      for (var d = 0; d < 7; d++) {
        if (!hustleDone.contains(hustleKey(w, d))) return (w, d);
      }
    }
    return null;
  }

  // ---- review ----
  /// Key for the week containing [d], using the Sunday that ends it.
  String reviewKey(DateTime d) {
    final daysToSunday = (7 - d.weekday) % 7;
    return dayKey(d.add(Duration(days: daysToSunday)));
  }

  void saveReview(String key, List<String> answers) {
    reviews[key] = jsonEncode(answers);
    _save();
  }

  List<String> reviewAnswers(String key) {
    final raw = reviews[key];
    if (raw == null) return ['', '', '', ''];
    return (jsonDecode(raw) as List).cast<String>();
  }

  // ---- settings ----
  void setReminders({bool? on, int? mh, int? mm, int? eh, int? em, int? bh, int? bm}) {
    remindersOn = on ?? remindersOn;
    morningHour = mh ?? morningHour;
    morningMinute = mm ?? morningMinute;
    eveningHour = eh ?? eveningHour;
    eveningMinute = em ?? eveningMinute;
    buildHour = bh ?? buildHour;
    buildMinute = bm ?? buildMinute;
    _save();
  }

  /// After 10 PM the app is in night mode: only the one-line box is shown.
  bool get isNight {
    final h = DateTime.now().hour;
    return h >= 22 || h < 5;
  }
}
