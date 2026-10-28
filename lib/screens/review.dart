import 'package:flutter/material.dart';

import '../main.dart';
import '../models.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _kg = TextEditingController();

  static const _questions = [
    'Meditation and movement floor: how many of 7 days?',
    'Did I use Script 1 before any apology?',
    'Did I do 15 minutes of Build at least 5 of 7 days?',
    'What one piece of friction do I adjust this week?',
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    final cs = Theme.of(context).colorScheme;
    final key = s.reviewKey(today());
    final answers = s.reviewAnswers(key);
    final weeks = s.phaseTwoWeeks();
    final last = s.weights.isEmpty ? null : s.weights.last;

    return AppPage(
      title: 'Review',
      subtitle: 'Sunday, 10 minutes, four questions. Weight, income and relationship quality are lagging indicators.',
      children: [
        Section(
          title: 'Phase 2 gate',
          icon: Icons.flag_rounded,
          trailing: Text('$weeks/4 weeks'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: (weeks / 4).clamp(0, 1), minHeight: 8),
              const SizedBox(height: 10),
              Text(
                weeks >= 4
                    ? 'Four consecutive weeks at 5/7 on both floor habits. You are allowed to move to Phase 2.'
                    : 'Move to Phase 2 only after 4 consecutive weeks at 5/7 on meditation and movement floor. '
                        'Not before, no matter how motivated you feel at midnight.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final h in Habit.values)
                    Chip(
                      avatar: Icon(
                        s.lastSeven(h) >= 5 ? Icons.check_circle : Icons.circle_outlined,
                        size: 18,
                        color: s.lastSeven(h) >= 5 ? cs.primary : cs.outline,
                      ),
                      label: Text('${h.label} ${s.lastSeven(h)}/7'),
                    ),
                ],
              ),
            ],
          ),
        ),
        Section(
          title: 'This week\'s four questions',
          icon: Icons.quiz_outlined,
          trailing: Text('wk ending $key'),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    key: ValueKey('$key-$i'),
                    initialValue: answers[i],
                    decoration: InputDecoration(labelText: _questions[i]),
                    onChanged: (v) {
                      final a = s.reviewAnswers(key);
                      a[i] = v;
                      s.saveReview(key, a);
                    },
                  ),
                ),
            ],
          ),
        ),
        Section(
          title: 'Weight, once a week',
          icon: Icons.monitor_weight_outlined,
          trailing: last == null ? null : Text('${last.kg.toStringAsFixed(1)} kg'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _kg,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'kg'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      final v = double.tryParse(_kg.text.replaceAll(',', '.'));
                      if (v != null && v > 30 && v < 250) {
                        s.addWeight(v);
                        _kg.clear();
                      }
                    },
                    child: const Text('Log'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Same day, same time. Write it down. Do not react to it for 8 weeks.'),
              if (s.weights.length >= 2) ...[
                const SizedBox(height: 12),
                SizedBox(height: 90, child: CustomPaint(painter: _Spark(s.weights, cs.primary), size: Size.infinite)),
                Text(
                  '${s.weights.first.kg.toStringAsFixed(1)} → ${s.weights.last.kg.toStringAsFixed(1)} kg over ${s.weights.length} entries',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Section(
          title: 'Past reviews',
          icon: Icons.history_rounded,
          child: s.reviews.length <= 1
              ? const Text('They will stack up here.')
              : Column(
                  children: [
                    for (final e in (s.reviews.keys.toList()..sort()).reversed.where((k) => k != key))
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text('Week ending $e'),
                        children: [
                          for (var i = 0; i < 4; i++)
                            ListTile(
                              dense: true,
                              title: Text(_questions[i], style: Theme.of(context).textTheme.bodySmall),
                              subtitle: Text(s.reviewAnswers(e)[i].isEmpty ? '—' : s.reviewAnswers(e)[i]),
                            ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Spark extends CustomPainter {
  _Spark(this.w, this.color);
  final List<WeightEntry> w;
  final Color color;
  @override
  void paint(Canvas c, Size size) {
    final min = w.map((e) => e.kg).reduce((a, b) => a < b ? a : b) - 0.5;
    final max = w.map((e) => e.kg).reduce((a, b) => a > b ? a : b) + 0.5;
    final p = Path();
    for (var i = 0; i < w.length; i++) {
      final x = i / (w.length - 1) * size.width;
      final y = size.height - (w[i].kg - min) / (max - min) * size.height;
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    c.drawPath(
      p,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Spark old) => old.w != w;
}
