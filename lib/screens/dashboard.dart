import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design_tokens.dart';
import '../main.dart';
import '../models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    if (s.isNight) return const NightMode();
    final c = context.pc;
    final log = s.todayLog;
    final floorDone = AppState.floorHabits.every(log.done.contains);
    final missed = Habit.values.where(s.missedTwice).toList();

    return AppPage(
      title: _greeting(),
      subtitle: _dateLine(),
      hero: _Hero(log: log, floorDone: floorDone),
      children: [
        if (missed.isNotEmpty)
          Callout(
            color: c.alarmSoft,
            foreground: c.alarmForeground,
            icon: Icons.warning_amber_rounded,
            text:
                'Never miss twice. Two days without ${missed.map((h) => h.label.toLowerCase()).join(', ')}. '
                'Smallest version today. One breath. One squat.',
          ),
        Section(
          title: 'Today\'s floor',
          icon: Icons.layers_outlined,
          trailing: Pill('${log.done.length}/${Habit.values.length}'),
          child: Column(
            children: [
              for (final h in Habit.values)
                if (h != Habit.nextAction) _HabitTile(h: h, log: log),
              const SizedBox(height: Prim.space2),
              _OptionalRow(log: log),
            ],
          ),
        ),
        Section(
          title: 'Build: today\'s 15 minutes',
          icon: Icons.rocket_launch_outlined,
          tint: c.momentum,
          child: _BuildBlock(),
        ),
        Section(
          title: 'Pause Gate',
          icon: Icons.hourglass_top_rounded,
          tint: c.alarm,
          trailing: Pill('${s.gateCount(wentThrough: false)} walked away · 7d', color: c.alarm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Want an escape? Come through here, not the address bar. Delay, name the reason, then decide.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: Prim.space3),
              LayoutBuilder(
                builder: (context, bc) {
                  final cols = bc.maxWidth > 680 ? 4 : 2;
                  final w = (bc.maxWidth - (cols - 1) * Prim.space2) / cols;
                  return Wrap(
                    spacing: Prim.space2,
                    runSpacing: Prim.space2,
                    children: [for (final e in escapes) SizedBox(width: w, child: _GateButton(e: e))],
                  );
                },
              ),
            ],
          ),
        ),
        Section(
          title: 'Last 7 days',
          icon: Icons.grid_view_rounded,
          child: _WeekGrid(),
        ),
        Section(
          title: 'Tomorrow\'s line',
          icon: Icons.edit_note_rounded,
          tint: c.night,
          child: _NextActionField(),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning. Floor first.';
    if (h < 17) return 'Afternoon.';
    return 'Evening. Walk, then one line.';
  }

  String _dateLine() {
    final d = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }
}

/// Gradient hero with an animated progress ring and the Phase 2 counter.
class _Hero extends StatelessWidget {
  const _Hero({required this.log, required this.floorDone});
  final DayLog log;
  final bool floorDone;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final s = AppState.instance;
    final total = Habit.values.length;
    final done = log.done.length;
    final weeks = s.phaseTwoWeeks();
    final best = Habit.values.map(s.streak).fold(0, math.max);
    final t = Theme.of(context).textTheme;
    final onHero = Colors.white;

    final headline = floorDone
        ? (done == total ? 'Clean sweep.' : 'Floor done.')
        : done == 0
            ? 'Start with one breath.'
            : 'Keep going.';
    final sub = floorDone
        ? 'Everything else today is a bonus, not the standard.'
        : 'Meditate and the movement floor are the only two that count.';

    return Container(
      padding: const EdgeInsets.all(Prim.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: c.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(CardTokens.radius),
      ),
      child: Row(
        children: [
          _Ring(value: done / total, label: '$done', sub: 'of $total'),
          const SizedBox(width: Prim.space5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: t.headlineSmall?.copyWith(color: onHero)),
                const SizedBox(height: Prim.space1),
                Text(sub, style: t.bodySmall?.copyWith(color: onHero.withValues(alpha: 0.85))),
                const SizedBox(height: Prim.space4),
                Wrap(
                  spacing: Prim.space2,
                  runSpacing: Prim.space2,
                  children: [
                    _HeroStat(icon: Icons.local_fire_department_rounded, text: '$best day streak'),
                    _HeroStat(icon: Icons.flag_rounded, text: '$weeks/4 wks to Phase 2'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: Prim.space3, vertical: Prim.space1 + 2),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(Prim.radiusFull),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: Prim.space1 + 2),
        Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
      ],
    ),
  );
}

class _Ring extends StatelessWidget {
  const _Ring({required this.value, required this.label, required this.sub});
  final double value;
  final String label, sub;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Prim.durSlow,
      curve: Prim.easeOut,
      builder: (context, v, _) => SizedBox(
        width: RingTokens.size * 0.8,
        height: RingTokens.size * 0.8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _RingPainter(v)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: t.headlineMedium?.copyWith(color: Colors.white, height: 1)),
                  Text(sub, style: t.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v);
  final double v;
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - RingTokens.stroke / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = RingTokens.stroke * 0.8
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = RingTokens.stroke * 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, 2 * math.pi * v, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.v != v;
}

/// Habit row styled as a tappable tile with an animated check.
class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.h, required this.log});
  final Habit h;
  final DayLog log;
  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final c = context.pc;
    final done = log.done.contains(h);
    final streak = s.streak(h);
    final isFloor = AppState.floorHabits.contains(h);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Prim.space2),
      child: Material(
        color: done ? c.primarySoft : c.surfaceRaised,
        borderRadius: BorderRadius.circular(HabitTileTokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(HabitTileTokens.radius),
          onTap: () => s.toggleHabit(h),
          child: AnimatedContainer(
            duration: Prim.durFast,
            padding: HabitTileTokens.padding,
            child: Row(
              children: [
                _Check(done: done),
                const SizedBox(width: Prim.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            h.label,
                            style: t.titleSmall?.copyWith(
                              decoration: done ? TextDecoration.lineThrough : null,
                              color: done ? c.muted : c.foreground,
                            ),
                          ),
                          if (isFloor) ...[
                            const SizedBox(width: Prim.space2),
                            Pill('floor', color: c.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(h.hint, style: t.bodySmall),
                    ],
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(width: Prim.space2),
                  Pill('$streak', icon: Icons.local_fire_department_rounded, color: c.momentum),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.done});
  final bool done;
  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return AnimatedContainer(
      duration: Prim.durBase,
      curve: Prim.easeOut,
      width: HabitTileTokens.checkSize,
      height: HabitTileTokens.checkSize,
      decoration: BoxDecoration(
        color: done ? c.primary : Colors.transparent,
        border: Border.all(color: done ? c.primary : c.muted, width: 1.5),
        borderRadius: BorderRadius.circular(Prim.radiusFull),
      ),
      child: AnimatedScale(
        scale: done ? 1 : 0,
        duration: Prim.durBase,
        curve: Curves.easeOutBack,
        child: Icon(Icons.check_rounded, size: 18, color: c.primaryForeground),
      ),
    );
  }
}

class _OptionalRow extends StatelessWidget {
  const _OptionalRow({required this.log});
  final DayLog log;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('20-minute home session', style: t.titleSmall),
              Text('Optional, 3x a week. Squats, push-ups, lunges, plank. On paper, not YouTube.', style: t.bodySmall),
            ],
          ),
        ),
        Switch(value: log.workout20, onChanged: (_) => AppState.instance.toggleWorkout20()),
      ],
    );
  }
}

class _GateButton extends StatelessWidget {
  const _GateButton({required this.e});
  final Escape e;
  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final icon = switch (e.id) {
      'yt' => Icons.play_circle_outline,
      'reddit' => Icons.forum_outlined,
      'insta' => Icons.photo_camera_outlined,
      _ => Icons.sports_esports_outlined,
    };
    return Material(
      color: c.surfaceRaised,
      borderRadius: BorderRadius.circular(GateTokens.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(GateTokens.radius),
        onTap: () => showDialog(context: context, builder: (_) => PauseGateDialog(escape: e)),
        child: Padding(
          padding: GateTokens.padding,
          child: Row(
            children: [
              Icon(icon, size: 20, color: c.alarm),
              const SizedBox(width: Prim.space2),
              Expanded(child: Text(e.label, style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
              Text('${e.waitSeconds}s', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildBlock extends StatefulWidget {
  @override
  State<_BuildBlock> createState() => _BuildBlockState();
}

class _BuildBlockState extends State<_BuildBlock> {
  static const _total = 15 * 60;
  Timer? _t;
  int _left = _total;
  bool _running = false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _t?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 1) {
        _t?.cancel();
        setState(() {
          _running = false;
          _left = 0;
        });
        if (!AppState.instance.todayLog.done.contains(Habit.build)) {
          AppState.instance.toggleHabit(Habit.build);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timer done. Stop now, even mid-flow. Tomorrow starts easier.')),
          );
        }
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final c = context.pc;
    final t = Theme.of(context).textTheme;
    final task = s.todaysBuildTask;
    final next = s.nextHustleAction;
    final mm = (_left ~/ 60).toString().padLeft(2, '0');
    final ss = (_left % 60).toString().padLeft(2, '0');
    final progress = 1 - _left / _total;

    final taskText = task.isNotEmpty
        ? task
        : next != null
            ? '${hustleWeeks[next.$1].title}, day ${next.$2 + 1}: ${hustleWeeks[next.$1].days[next.$2]}'
            : 'No line written last night. Pick the next Build step and go.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(Prim.space4),
          decoration: BoxDecoration(
            color: c.momentumSoft,
            borderRadius: BorderRadius.circular(Prim.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: c.momentum),
              const SizedBox(width: Prim.space3),
              Expanded(child: Text(taskText, style: t.titleSmall)),
            ],
          ),
        ),
        const SizedBox(height: Prim.space4),
        Row(
          children: [
            Text(
              '$mm:$ss',
              style: t.displaySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _left == 0 ? null : _toggle,
              icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(_running ? 'Pause' : 'Start'),
            ),
            const SizedBox(width: Prim.space2),
            IconButton(
              tooltip: 'Reset',
              onPressed: () {
                _t?.cancel();
                setState(() {
                  _running = false;
                  _left = _total;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: Prim.space3),
        ClipRRect(
          borderRadius: BorderRadius.circular(Prim.radiusFull),
          child: LinearProgressIndicator(value: progress, minHeight: 6, color: c.momentum),
        ),
      ],
    );
  }
}

class _WeekGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final c = context.pc;
    final t = Theme.of(context).textTheme;
    final days = List.generate(7, (i) => today().subtract(Duration(days: 6 - i)));
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final labelW = MediaQuery.sizeOf(context).width < 420 ? 86.0 : 120.0;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: labelW),
            for (final d in days)
              Expanded(
                child: Center(
                  child: Text(
                    letters[d.weekday - 1],
                    style: t.labelSmall?.copyWith(
                      color: dayKey(d) == dayKey(today()) ? c.primary : c.muted,
                      fontWeight: dayKey(d) == dayKey(today()) ? FontWeight.w800 : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Prim.space1),
        for (final h in Habit.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: labelW,
                  child: Text(h.label, style: t.labelSmall, overflow: TextOverflow.ellipsis),
                ),
                for (final d in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Prim.radiusSm),
                        onTap: () => s.toggleHabit(h, on: d),
                        child: AnimatedContainer(
                          duration: Prim.durFast,
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Prim.radiusSm),
                            color: (s.logs[dayKey(d)]?.done.contains(h) ?? false) ? c.primary : c.surfaceRaised,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: Prim.space2),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Tap a cell to back-fill a day you forgot to log.', style: t.labelSmall),
        ),
      ],
    );
  }
}

class _NextActionField extends StatefulWidget {
  @override
  State<_NextActionField> createState() => _NextActionFieldState();
}

class _NextActionFieldState extends State<_NextActionField> {
  late final _c = TextEditingController(text: AppState.instance.todayLog.nextAction);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      maxLines: 2,
      minLines: 1,
      decoration: const InputDecoration(
        hintText: 'Tomorrow\'s 15 minutes is: ...',
        helperText: 'One line. No planning. Midnight you is an overexcited colleague.',
      ),
      onChanged: AppState.instance.setNextAction,
    );
  }
}

/// After 10 PM the dashboard collapses to the one-line box.
class NightMode extends StatelessWidget {
  const NightMode({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final t = Theme.of(context).textTheme;
    return AppPage(
      title: 'It\'s late.',
      subtitle: 'You are not allowed to plan right now.',
      hero: Container(
        padding: const EdgeInsets.all(Prim.space5),
        decoration: BoxDecoration(
          color: c.nightSoft,
          borderRadius: BorderRadius.circular(CardTokens.radius),
        ),
        child: Row(
          children: [
            Icon(Icons.nightlight_round, color: c.night, size: 32),
            const SizedBox(width: Prim.space4),
            Expanded(
              child: Text(
                'One line, then the phone goes outside the bedroom. Everything else is hidden until 5 AM on purpose.',
                style: t.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      children: [
        Section(title: 'Tomorrow\'s 15 minutes is:', icon: Icons.edit_note_rounded, tint: c.night, child: _NextActionField()),
        Text(
          'Midnight motivation is a different brain. Review its ideas in the morning.',
          style: t.bodySmall,
        ),
      ],
    );
  }
}

/// The friction the app itself enforces: a countdown, a reason, a choice.
class PauseGateDialog extends StatefulWidget {
  const PauseGateDialog({super.key, required this.escape});
  final Escape escape;
  @override
  State<PauseGateDialog> createState() => _PauseGateDialogState();
}

class _PauseGateDialogState extends State<PauseGateDialog> {
  late int _left = widget.escape.waitSeconds;
  Timer? _t;
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 0) {
        _t?.cancel();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    AppState.instance.recordGate(widget.escape, true, _reason.text);
    if (mounted) Navigator.pop(context);
    if (widget.escape.url.isNotEmpty) {
      await launchUrl(Uri.parse(widget.escape.url), mode: LaunchMode.externalApplication);
    }
  }

  void _walkAway() {
    AppState.instance.recordGate(widget.escape, false, _reason.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final c = context.pc;
    final t = Theme.of(context).textTheme;
    final floorMissing = AppState.floorHabits.where((h) => !s.todayLog.done.contains(h)).toList();
    final total = widget.escape.waitSeconds;
    final ready = _left == 0;
    return AlertDialog(
      title: Text('Pause: ${widget.escape.label}'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1 - _left / total,
                      strokeWidth: 8,
                      color: ready ? c.primary : c.alarm,
                      backgroundColor: c.surfaceRaised,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        ready ? '✓' : '$_left',
                        style: t.headlineMedium?.copyWith(color: ready ? c.primary : c.alarm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Prim.space4),
            Text(
              ready ? 'Delay done. Your call.' : 'Breathe. The urge peaks and drops.',
              style: t.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (floorMissing.isNotEmpty) ...[
              const SizedBox(height: Prim.space3),
              Container(
                padding: const EdgeInsets.all(Prim.space3),
                decoration: BoxDecoration(color: c.alarmSoft, borderRadius: BorderRadius.circular(Prim.radiusSm)),
                child: Text(
                  'Floor not done: ${floorMissing.map((h) => h.label.toLowerCase()).join(', ')}. '
                  '90 seconds buys you a clean escape.',
                  style: t.bodySmall?.copyWith(color: c.alarmForeground),
                ),
              ),
            ],
            const SizedBox(height: Prim.space4),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'What am I escaping from right now?',
                hintText: 'Name the task, not the feeling.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _walkAway, child: const Text('Walk away')),
        FilledButton(
          onPressed: ready ? _go : null,
          child: Text(ready ? 'Go anyway' : 'Wait $_left s'),
        ),
      ],
    );
  }
}
